function [data] = readNDData1_0( filename )

% Original readNDData if you're having issues with an old script switch to this version and the associated write function
NDD_UNIFORMITY_BIT = 0;
NDD_POSITION_BIT = 1;
NDD_MATRIX_ORDER_BIT = 2;


fid = fopen(filename,'r');
if(fid == -1)
    error('could not open file');
end
display(['Opening ' filename]);

data.version = fread(fid, 1, 'int32');
if (data.version > 1)
    data.format = fread(fid, 1, 'uint32');
else
    format = (fread(fid, 4, '*char'))';
    if( strcmp(format, 'UNI1' ) )
        data.format = uint32(0);
    elseif( strcmp(format, 'NON1'))
        data.format =  uint32(1);
    else
        error('Unknown type formating');
    end
end
    
%data.type = (fread(fid, 4, '*char'));
data.date.sec = fread(fid, 1, 'int32');
data.date.min = fread(fid, 1, 'int32');
data.date.hour = fread(fid, 1, 'int32');
data.date.day = fread(fid,1,'int32');
data.date.month = fread(fid,1,'int32');
data.date.year = fread(fid,1,'int32');
dummyChar = (fread(fid,256, '*char'))';
dummyInt = fread(fid,4,'int32');
dummyDouble = fread(fid,4, 'double');
data.bytePerElement = fread(fid, 1, 'uint32');
data.nDim = fread(fid,1,'uint32');
data.dimSize = fread(fid,data.nDim,'uint32')';

data.dimSize


if( bitand(data.format,1 ))  % non uniform spacing
    data.posS =fread(fid, data.nDim, 'int32');
    for i=1:length(data.posS)
        
        data.pos{i} = fread(fid, data.posS(i), 'double');
        
        data.start(i) = data.pos{i}(1);
    end
    data.pitch = -1;
    
else % uniform spacing

    data.pitch = fread(fid, data.nDim, 'double');
    data.start = fread(fid, data.nDim, 'double');
    
    %pitch = Bx-Ax, Cy-Ay, ...
    %start = Ax, Ay, ...
    %  A---B
    %  |   |
    %  C---D+    
    
end
    

    
    
data.n = prod(data.dimSize);


if( data.bytePerElement == 1 )
    data.type = 'int8';
elseif(data.bytePerElement == 2 )
    data.type = 'short';
elseif(data.bytePerElement == 4 )
    data.type = 'single';
elseif(data.bytePerElement == 8 )
    data.type = 'double';
else
    error('unknown type');
end
display(['Type: ' data.type]);


if( data.version > 1 )
    tmp=fread(fid, 1, 'int64');
    if(tmp > 0 )
        tmpstr=fread(fid, tmp, '*char')';
        posStr = strfind(tmpstr,':');
        for i=1:length(posStr)
            data.units{i}=tmpstr(1:posStr-1);
            tmpstr = tmpstr(posStr+1:length(tmpstr));
            if( i==length(posStr))
                data.units{i+1}=tmpstr;
            end
        end
    else
        data.units{1}='';
    end
end


data.mat =fread(fid, data.n,  data.type);

display('Casting data to single.. mod code to turn off.')
data.mat = cast(data.mat,'single');



if( length(data.dimSize) > 1) 
    
        
    if( bitand(data.format,2^NDD_MATRIX_ORDER_BIT )>0) %if COL major
        
        data.mat = reshape(data.mat, (data.dimSize));

    else%if ROW MAJOR
        data.mat= reshape( data.mat, fliplr(data.dimSize));

        ind = fliplr(1:data.nDim);


%        %this is just so that we have data how matlab likes to show images
%         tmp =ind(1);
%         ind(1)=ind(2);
%         ind(2)=tmp;
        data.mat = permute(data.mat, (ind));
    end

    
end

%for 3d data is y,x,z  for 2d y,x  

fclose(fid);
%data.elements = fread(fid, 


