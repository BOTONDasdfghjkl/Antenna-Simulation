drbase='6360MHz';
load([drbase '/param.mat']);

timesteps=100;
command = sprintf('./batch.sh "%s"', dr2);
[status, output] = system(command);
if status~=0
    error("Problem with mumax3: %s", output);
end
loadMumax_Compress(timesteps,CPW_thickness,dr2,dr4);
antenna_vector_potential(timesteps,CPW_thickness,f,dr4,drbase,PBY);
Radiation_resistance(drbase,CPW_thickness);
disp('Finished!');