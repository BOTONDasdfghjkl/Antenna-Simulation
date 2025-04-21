function loadMumax_Compress(timesteps,CPW_thickness,dr_mumaxsource,dr_result)
[~,~] = mkdir(dr_result);  % create folder if needed
time=zeros(timesteps,1);
[Mx{timesteps}, My{timesteps}, Mz{timesteps}] = deal(0);
for i_d = 1:length(CPW_thickness)
    for i = 1:timesteps
        num=num2str(i);
        while(size(num,2)<6);num=strcat('0',num);end
        mfile=strcat(dr_mumaxsource,'/mumax_f',num2str(i_d),'.out/','m',num,'.ovf');
        data = read_ovf(mfile);
        time(i) = data.time;
    
        Mx{i}=data.X;
        My{i}=data.Y;
        Mz{i}=data.Z;
    end    
    dx = data.dx;
    dy = data.dy;
    dz = data.dz;
    I = data.I;
    J = data.J;
    K = data.K;
    save(dr_result+'/results_compressed_f'+num2str(i_d),...
          "Mx","My","Mz","dx","dy","dz","I","J","K","time")
    disp([num2str(CPW_thickness(i_d)),' nm'])
end
