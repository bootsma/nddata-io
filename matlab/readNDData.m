function [data] = readNDData( filename, castData2Type )
% READNDDATA - reads n-dimensional data from the file FILENAME
%   [DATA]=READNDDATA(FILENAME) reads in the n-d data into the struct DATA
%        DATA contains members:
%               DATA.DATE    time data was created)
%               DATA.MAT     the matrix containing the data
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
%    [DATA]=READNDDATA(FILENAME,CASTDATA2TYPE) is same as
%    READNDDATA(FILENAME) except DATA.MAT is cast to the specified type
%    DATA.TYPE will contain the type of the original data
%       
%   AUTHOR: Gregory J. Bootsma

%
% make sure valid type if specified so as to not wait
% till end of load to fail
if( exist('castData2Type', 'var') )
    cast(0,castData2Type);
end

NDD_UNIFORMITY_BIT = 0;
NDD_POSITION_BIT = 1;
NDD_MATRIX_ORDER_BIT = 2;

[data, readbytes]=readNDDataHeader(filename);


fid = fopen(filename,'r');
if(fid == -1)
    error(['Could not open file: ' filename]);
end
display(['Opening ' filename]);

fseek(fid, readbytes, -1); %-1 BOF
data.mat =fread(fid, data.n,  data.type);



if ( exist('castData2Type','var') && ~strcmp(data.type, castData2Type) )
    display(['Casting data to from type ' data.type ' to ' castData2Type]);
    data.mat = cast(data.mat, castData2Type);
end
    


if( length(data.dimSize) > 1) 
    
        
    if( bitand(data.format,2^NDD_MATRIX_ORDER_BIT )) %if COL major
        

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


