function analyze_femm(dr_ohf,dr_femm,dr_data,f,CPW_thickness,dx,dy,dz,Nx,Nz)
        YIG_thickness = Nz*dz*1e6;
        Ypos = (-YIG_thickness:dz*1e6:-dz*1e6)+dz*1e6/2;
                        [Xx,Yy] = meshgrid(-44.5 + ((1:Nx)-0.5)*dx*1e6,Ypos);
        addpath('C:\femm42\mfiles');
        openfemm(1);
        for ti = 1:length(CPW_thickness)
                opendocument(char(strrep(cd +"\"+ dr_femm+"\CPW_design_"+ti+".fem", '\', '\\')));
                mi_loadsolution();
            
                IVFs=mo_getcircuitproperties('Source');   
                IVFg=mo_getcircuitproperties('Ground');
                Is(ti) = IVFs(1);
                Vs(ti) = IVFs(2);
                Ig(ti) = IVFg(1);
                Vg(ti) = IVFg(2);
            
                %% Query the B field in YIG
                B_CPW = mo_getb(Xx(:),Yy(:));
            
                name = strcat(num2str(f/1e6),'MHz_',num2str(CPW_thickness(ti)*1e3),'nm');
                %% generate the mumax input file for the real part of Bx and Bz
                filename = strcat(dr_ohf,'/CPW_Real_', name,'.ohf');
                X = real(reshape(reshape(B_CPW(:,1),Nz,Nx)',Nx,1,Nz));
                Y = 0*X;
                Z = real(reshape(reshape(B_CPW(:,2),Nz,Nx)',Nx,1,Nz));
                write_ovf(filename,filename,dx,dy,dz,Nx,1,Nz,X,Y,Z,'T','B')
                %% generate the mumax input file for the imaginary part of Bx and Bz
                filename = strcat(dr_ohf,'/CPW_Imag_',name,'.ohf');
                X = imag(reshape(reshape(B_CPW(:,1),Nz,Nx)',Nx,1,Nz));
                Y = 0*X;
                Z = imag(reshape(reshape(B_CPW(:,2),Nz,Nx)',Nx,1,Nz));
                write_ovf(filename,filename,dx,dy,dz,Nx,1,Nz,X,Y,Z,'T','B')
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
            save([dr_data '/R_Ohmplot.mat'],"CPW_thickness","Vg","Ig");
            save([dr_data '/R_Ohm.mat'],"CPW_thickness","R_ohm_real","R_ohm_imag");
end