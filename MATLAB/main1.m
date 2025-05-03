drbase = '6360MHz';  % folder for new files
dr1=drbase+"/ohf";
dr2=drbase+"/mumaxfiles";
dr3=drbase+"/femm_codes";
dr4=drbase+"/mumax_compressed";
dr5=drbase+"/images";

f=6360*1e6; %frequencies in Hz
CPW_thickness = 150:150:900;
dx = 0.2e-6;
dy = 1.0e-6;
dz = 0.04e-6;
Nx = 500;
Ny = 1;
Nz = 20;
PBY=50;
mkdir(drbase)
save([drbase '/param.mat'],"drbase","dr1","dr2","dr3","dr4","dr5","f","CPW_thickness","dx","dy","dz","Nx","Ny","Nz","PBY");
addpath('C:\femm42\mfiles');
openfemm(1);
for i = 1:length(CPW_thickness)
    generate_mumax_sweep(dr1,dr2,['mumax_f',num2str(i)],f,CPW_thickness(i),dx,dy,dz,Nx,Ny,Nz,PBY);
    
    run_femm(dr1,dr3,drbase,"CPW_design_"+i,f,CPW_thickness(i)/1000,dx,dy,dz,Nx,Nz,PBY);
    [Is(i),Vs(i),Ig(i),Vg(i)]=analyze_femm(dr1,cd +"\"+ dr3+"\CPW_design_"+i+".fem",f,CPW_thickness(i)/1000,dx,dy,dz,Nx,Nz);
end

%plot:
figure(101)
plot(CPW_thickness, real(Vg./Ig))
hold on
plot(CPW_thickness, real(Vs./Is))
plot(CPW_thickness, real(Vs./Is)+real(Vg./Ig))
hold off
R_ohm_real = real(Vs./Is)+real(Vg./Ig);
R_ohm_imag = imag(Vs./Is)+imag(Vg./Ig);
save([drbase '/R_Ohmplot.mat'],"CPW_thickness","Vg","Ig");
save([drbase '/R_Ohm.mat'],"CPW_thickness","R_ohm_real","R_ohm_imag");



disp('Finished!');