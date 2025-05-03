function antenna_vector_potential(timesteps,CPW_thickness,freq,dr_compressed,dr_save,PBY)
PBY=PBY*2;
cpw_pos = [1:5 26:30 51:55]+222; % position of CPW lines
% cpw_pos = [1:5 26:30 51:55]+222-105; % position of CPW2

Ms = 1.59E+5;
mu0 = 4*pi*1e-7;
f = freq/1e9; %convert into GHz


%% definitions
n_cpw = length(cpw_pos);

V_real(1:length(CPW_thickness)) = 0;
V_imag(1:length(CPW_thickness)) = 0;

[Mx{timesteps}, My{timesteps}, Mz{timesteps}, Mx_pad, My_pad, Mz_pad]  = deal([]); 

for i_d=1:length(CPW_thickness)         % loop through thicknesses
    metal = CPW_thickness(i_d)*1E-9;    % metallization thickness

    disp(['Processing #',num2str(i_d),'/',num2str(length(CPW_thickness)),' (d=',num2str(CPW_thickness(i_d)),' nm)'])

    load(dr_compressed+'/results_compressed_f'+num2str(i_d),"Mx","My","Mz","dx","dy","dz","I","J","K","time")
    time = time(1:timesteps);
    
    A_ = Ms*mu0/(4*pi)*dx*dy*dz;    % multiplicative factor in vector potential

    %% calculate distance kernel in the plane above YIG, restricted to CPW
    x_ = (1:I+cpw_pos(end)-cpw_pos(1))*dx;
    z_ = (1:K)*dz;
    y_ = (1:J*PBY)*dy;
    dxx = (x_-x_(I-cpw_pos(1)+1)+dx/2);
    dyy = (y_-y_(J*PBY/2));
    dzz = (z_-z_(1) + dz/2 + metal/2);
    [DX, DY, DZ] = meshgrid(dxx,dyy,dzz);

    distance_kernel = 1./sqrt(DX.^2 + DY.^2 + DZ.^2).^3; 
    RTX = DX.*distance_kernel;
    RTZ = DZ.*distance_kernel;
    for i_t = 1:timesteps   % loop through timesteps

        %% repeat for PBC
        Mx_ = repmat(Mx{i_t}(:,:,:),[PBY,1,1]);
        % My_ = repmat(My{i_t}(:,:,:),[YY,1,1]);
        Mz_ = repmat(Mz{i_t}(:,:,:),[PBY,1,1]);

	    %% calculating vector potential (A) with convolution
        A_cross_y = A_ * (convn(RTX,Mz_,'valid') - convn(RTZ,Mx_,'valid'));
        AY(i_t,:) = A_cross_y(cpw_pos-cpw_pos(1)+1);
    end
    figure(1000+i_d)
    imagesc(squeeze(Mz_(1,:,:))')
    %% Approximate time derivative with central differences
    dAY = diff(AY,1,1);

    dtime = diff(time);
    dtc = [dtime(1);dtime]+[dtime;dtime(end)];

    Ey = -([dAY(1,:,:,:);dAY]+[dAY;dAY(end,:,:,:)])./dtc;
   
    %% calculate the induced voltage in CPW
    L_CPW = 100e-6;
    V1 = -sum(Ey(:, 1:5) ,2)/5*L_CPW;
    V2 = -sum(Ey(:, 6:10),2)/5*L_CPW;
    V3 = -sum(Ey(:,11:15),2)/5*L_CPW;
    V = (V1+V3)/2-V2;

    %% fit sine curve
    sin_vec = sin(2*pi*f*1e9*time);
    cos_vec = cos(2*pi*f*1e9*time);
    re = sum(cos_vec.*V)*2/(length(time));
    im = sum(sin_vec.*V)*2/(length(time));

    V_real(i_d) = re;
    V_imag(i_d) = -im;

end

fig_base = 800;

figure(fig_base+2)
plot(CPW_thickness,abs((V_real + 1i*V_imag)*1000),'.-','LineWidth',1)
hold on
plot(CPW_thickness,real((V_real + 1i*V_imag)*1000),'.-','LineWidth',1)
plot(CPW_thickness,imag((V_real + 1i*V_imag)*1000),'.-','LineWidth',1)
hold off
grid on
xlabel('f (GHz)')
ylabel('Z_{11} [\Omega]')
set(gca,'FontSize',16,'LineWidth',1);
legend('abs(Z_{11})','real(Z_{11})','imag(Z_{11})')

R_rad_real = V_real/1e-3;
R_rad_imag = V_imag/1e-3;
save([dr_save '/R_rad.mat'],"CPW_thickness","R_rad_real","R_rad_imag");

