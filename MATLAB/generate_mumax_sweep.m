function generate_mumax_sweep(dr_ohf,dr_mx3,filename,f,CPW_thickness,dx,dy,dz,Nx,Ny,Nz,PBY)
    [~,~] = mkdir(dr_ohf);  % create folder if needed
    [~,~] = mkdir(dr_mx3);  % create folder if needed
    % keywords to be replaced
    keywords = {'@f_exc','@file_re','@file_im','@Nx','@Ny','@Nz','@dx','@dy','@dz','@PBC'};  
    lines = readlines('template.mx3');  % load template file
    for k = 1:length(keywords)
        line_idx(k) = find(contains(lines,keywords{k}),1); % find keyword line number
    end
        assignment = { ...
            "f_exc := " + string(num2str(f/1e9)) + "e9", ...
            "file_re := """ + string(dr_ohf) + "/CPW_Real_" + string(num2str(f/1e6)) + "MHz_" + string(num2str(CPW_thickness)) + "nm.ohf""", ...
            "file_im := """ + string(dr_ohf) + "/CPW_Imag_" + string(num2str(f/1e6)) + "MHz_" + string(num2str(CPW_thickness)) + "nm.ohf""", ...
            "Nx := " + string(num2str(Nx)), ...
            "Ny := " + string(num2str(Ny)), ...
            "Nz := " + string(num2str(Nz)), ...
            "dx := " + string(num2str(dx)), ...
            "dy := " + string(num2str(dy)), ...
            "dz := " + string(num2str(dz)),...
            "setPBC(0,"+PBY+",0)"
        };
        newfile = [filename,'.mx3'];    % new filename with index

        lines(line_idx) = cellstr(assignment);   % replace full line with assignment
        
        writelines(lines,fullfile(dr_mx3,newfile)); % write file
end