function [data, readbytes] = readNDDataHeader( filename )
% READNDDATAHEADER - reads n-dimensional data header from the file FILENAME
%   [DATA,FILEPOS]=READNDDATAHEADER(FILENAME) reads in the n-d data into the 
%        struct DATA, it is similar to READNDDATA except the matrix
%        DATA.MAT is not read in. READBYTES is the number of bytes read
%        by this file, used to determin offset to data.
%        DATA contains members:
%               DATA.DATE    time data was created)
%               DATA.TYPE    class type of DATA.MAT (e.g. single, double)
%               DATA.DIMSIZE size of each dimension
%               DATA.POS     a cell of positions on the outer boundary of
%               each axis only used in non-uniform data
%               DATA.CENTERED_AXIS if 1 positional data is oriented around
%                                  center of data, only for uniform data
%
%               DATA.START   indicates the referenc position, if 
%                            DATA.CENTERED_AXIS is 1 this is the middle of
%                            the data otherwise it is the top left
%                            pixel/voxel
%               DATA.PITCH   the size of a voxel/pixel in each dimension
%                           only in uniform data
%               DATA.UNITS  a cell array of strings specifying each
%                           dimensions unit
%        
%       
%   AUTHOR: Gregory J. Bootsma

%


NDD_UNIFORMITY_BIT = 0;
NDD_POSITION_BIT = 1;
NDD_MATRIX_ORDER_BIT = 2;


fid = fopen(filename,'r');
if(fid == -1)
    error('could not open file');
end
%display(['Opening ' filename]);

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
        prevPos=0;
        for i=1:length(posStr)
            
            data.units{i}=tmpstr(prevPos+1:posStr(i)-1);
            prevPos=posStr(i);
            
        end
        data.units{i+1}=tmpstr(prevPos+1:length(tmpstr));
    else
        for i=1:data.nDim
            data.units{i}='unknown';
        end
        
    end
end

readbytes=ftell(fid);
fclose(fid);

