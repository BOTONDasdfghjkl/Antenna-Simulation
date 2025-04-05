drbase = '6360MHz';  % folder for new files
dr1=drbase+"/ohf";
dr2=drbase+"/source";
dr3=drbase+"/femm_codes";
dr4=drbase+"/images";

f=6360*1e6; %frequencies in Hz
CPW_thickness = 150:150:900;
dx = 0.2e-6;
dy = 1.0e-6;
dz = 0.04e-6;
Nx = 500;
Ny = 1;
Nz = 20;

%save([drbase '/param.mat'],"CPW_thickness","drbase")

%generate_mumax_sweep(dr1,dr2,f,CPW_thickness,dx,dy,dz,Nx,Ny,Nz);
%run_femm(dr1,dr3,drbase,f,CPW_thickness/1000,dx,dy,dz,Nx,Nz);
analyze_femm(dr1,dr3,drbase,f,CPW_thickness/1000,dx,dy,dz,Nx,Nz);

disp('Finished!');