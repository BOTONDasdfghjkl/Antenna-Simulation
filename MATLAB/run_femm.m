function run_femm(dr_ohf,dr_femm,dr_data,filename,f,CPW_thickness,dx,dy,dz,Nx,Nz,PBY)
PBY=PBY*2;
    [~,~] = mkdir(dr_ohf);  % create folder if needed
    [~,~] = mkdir(dr_femm);  % create folder if needed
    %% locate FEMM installation
    width_ground = 1; %ground antennák szélessége
    width_signal = 1; %source-nak a szélessége(jelet adó antennáé)
    width_gap = 4;%antennák közötti távolság
    
    %% enclosure dimensions in micrometers
    encH = 1000;
    encV = 1000;
    YIG_width = 100;
    
    %% dimensions in mumax
    YIG_thickness = Nz*dz*1e6;
    newdocument(0);

    %define the striplines
    %első antenna: ground
    p_left = [0,0
              width_ground,0
              width_ground,CPW_thickness
              0,CPW_thickness];
    %második antenna source
    p_middle = [width_ground + width_gap,0
                width_ground + width_signal + width_gap,0
                width_ground + width_signal + width_gap,CPW_thickness
                width_ground + width_gap,CPW_thickness];
    %harmadik antenna szintén ground
    p_right = [width_ground + width_signal + 2.0*width_gap,0
                2*width_ground + width_signal + 2.0*width_gap,0
                2*width_ground + width_signal + 2.0*width_gap,CPW_thickness
                width_ground + width_signal + 2.0*width_gap,CPW_thickness];
    %Az alja a cuccnak
    YIG = [-YIG_width,0-YIG_thickness/10 % the top line touching the conductors resulted in asymmetric behavior, move by 10%
           YIG_width,0-YIG_thickness/10
           YIG_width,-YIG_thickness
           -YIG_width,-YIG_thickness];
    %megrajzolja a pontokat és az éleket
    DrawClosedPolygon(p_left);
    DrawClosedPolygon(p_middle);
    DrawClosedPolygon(p_right);
    DrawClosedPolygon(YIG);
    
    %add materials
    %A copper igazából aluminium?
    mi_getmaterial('Copper')
    mi_modifymaterial( 'Copper', 5, 37.7); % Aluminum conductivity (Felix data) A magveszteség beállítását jelenti az 5-ös
    mi_getmaterial('Air');
    % define circuits: név, áram, ellenállás
    mi_addcircprop('Ground',5.0e-4,1);
    mi_addcircprop('Source',1.0e-3,1);

    %Source antenna
    addMaterialLabel( ...
        width_ground + width_gap + 0.5*width_signal, ...
        CPW_thickness/2, ...
        'Copper','Source',0.1,1)
    %Ground antennas:
    addMaterialLabel( ...
        width_ground/2.0, ...
        CPW_thickness/2, ...
        'Copper','Ground',0.1,-1)
    addMaterialLabel( ...
        2.0*width_gap + 1.5*width_ground + width_signal, ...
        CPW_thickness/2, ...
        'Copper','Ground',0.1,-1)
    % add YIG material label
    addMaterialLabel(width_ground/2.0,-YIG_thickness/2, ...
        'Air','None',dx*1e6,0)
    %Just Air around
    addMaterialLabel( ...
        width_gap + 0.5*width_signal + width_ground, ...
        6.0*CPW_thickness, ...
        'Air','None',0,0);
    
    % add boundary condition: a modellezet tér határa, dirichlet alapján
    % semmi sincs rajta
    mi_addboundprop('Zero_A',0,0,0,0,0,0,0,0,0,0,0);
    
    % draw enclosure: az egész térész megrajzolása
    enc = [-encH, -encV
            encH, -encV
            encH,  encV
           -encH,  encV]/2;
    DrawClosedPolygon(enc); 
    enc = [enc;enc(1,:)]; %Csak hozzáadja a végére az első elemet
    for i = 1:4
        enc_mid = (enc(i,:) + enc(i+1,:))/2;
        mi_selectsegment(enc_mid(1),enc_mid(2));
    end
    mi_setsegmentprop('Zero_A',0,0,0,0);
    mi_clearselected();
    
    mi_probdef(f,'micrometers','planar',1e-8,PBY,30,0);
    mi_saveas(char(strrep(cd +"\"+ dr_femm+"\"+filename+".fem", '\', '\\')));
    mi_analyze(1);
end

%% function to draw the polygons
function DrawClosedPolygon(p)
    for i = 1:size(p,1)
        mi_addnode(p(i,1),p(i,2));
    end
    
    for i = 1:size(p,1)-1
        mi_addsegment(p(i,1),p(i,2),p(i+1,1),p(i+1,2));
    end
    mi_addsegment(p(size(p,1),1),p(size(p,1),2),p(1,1),p(1,2));
end

%% function to add materials easyly
function addMaterialLabel(x,y,material,circuit_name,meshsize,turns)
    mi_addblocklabel(x,y);
    mi_selectlabel(x,y);
    mi_setblockprop(material, 0, meshsize, circuit_name, 0, 0, turns);
    mi_clearselected();
end