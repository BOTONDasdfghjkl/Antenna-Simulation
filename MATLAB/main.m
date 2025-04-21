drbase = '6360MHz';  % folder for new files
dr1=drbase+"/ohf";
dr2=drbase+"/source";
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
mkdir(drbase)
save([drbase '/param.mat'],"CPW_thickness","drbase")

generate_mumax_sweep(dr1,dr2,f,CPW_thickness,dx,dy,dz,Nx,Ny,Nz);
run_femm(dr1,dr3,drbase,f,CPW_thickness/1000,dx,dy,dz,Nx,Nz);
analyze_femm(dr1,dr3,drbase,f,CPW_thickness/1000,dx,dy,dz,Nx,Nz);

timesteps=100;
command = sprintf('./batch.sh "%s"', dr2);
[status, output] = system(command);
if status~=0
    error("Problem with mumax3: %s", output);
end
loadMumax_Compress(timesteps,CPW_thickness,dr2,dr4);
antenna_vector_potential(timesteps,CPW_thickness,f,dr4,drbase);
Radiation_resistance(drbase,CPW_thickness);
disp('Finished!');