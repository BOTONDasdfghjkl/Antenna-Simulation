function data = read_ovf(filename)


%% read header
file=fopen(filename);
text = textscan(file,'%s',200);
text = text{1};

fclose(file);

idx=find(ismember(text,'xnodes:'));

data.I = str2double(text{idx+1});
data.J = str2double(text{idx+4});
data.K = str2double(text{idx+7});

idx=find(ismember(text,'xstepsize:'));

data.dx = str2double(text{idx+1});
data.dy = str2double(text{idx+4});
data.dz = str2double(text{idx+7});

idx=find(ismember(text,'time:'));
if(~isempty(idx))
    data.time = str2double(text{idx+1});
end

%% read data
idx=find(ismember(text,'Data'));
if(strcmp(text{idx(1)+1},"Text"))
    file=fopen(filename);
    datacell=textscan(file,'%f %f %f',data.I*data.J*data.K,'commentstyle','#');
    fclose(file);
    
    data.X = permute(reshape(datacell{1}, [data.I data.J data.K]),[2 1 3]);
    data.Y = permute(reshape(datacell{2}, [data.I data.J data.K]),[2 1 3]);
    data.Z = permute(reshape(datacell{3}, [data.I data.J data.K]),[2 1 3]);
elseif(strcmp(text{idx(1)+1},"Binary"))
    file=fopen(filename);
    textLine = fgetl(file);
    while(~strcmp(textLine,"# Begin: Data Binary 4") & textLine~=-1)
        textLine = fgetl(file);
    end
    control = fread(file, 1, 'float', 'ieee-le'); % should be 1234567
    if ~isequal(control,1234567)
        warning('Incorrect control sequence, expected 1234567, received %s.',control)
    end
    floats = fread(file, [3,data.I*data.J*data.K], 'float', 'ieee-le');
    fclose(file);

    data.X = permute(reshape(floats(1,:), [data.I data.J data.K]),[2 1 3]);
    data.Y = permute(reshape(floats(2,:), [data.I data.J data.K]),[2 1 3]);
    data.Z = permute(reshape(floats(3,:), [data.I data.J data.K]),[2 1 3]);
end
