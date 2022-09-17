
function writeNDDataNU( filename, data, loc, units )
% WRITENDDATA Writes N-dimesional data with uniform sampling
%   WRITENDDATA(FILENAME, DATA, LOC, UNIT) writes the N-dimensional data
%   matrix DATA to the file named FILENAME. The locations of the
%   voxels/pixels is defined by LOC a cell array of arrays. LOC{x}
%   contains an array of the boundaries (edges) or the center point of the 
%   voxels/pixels. If the length of LOC{x} is equal to SIZE(loc,x) then it
%   is the center point else it contains the edges and should be equal to
%   SIZE(loc,x)+1, this constraint on lengths is not checked.
%
%  Author: Gregory J Bootsma
%  Copyright (c) 2019 Gregory J. Bootsma
%
% See also:
%   writeNDData
%% Data format BITS 
SEPERATOR=':';
NDD_UNIFORMITY_BIT=0;
NDD_POSITION_BIT=1;
NDD_MATRIX_ORDER_BIT=2;

NDD_NON_UNIFORM=1;

NDD_POSITION_CENTER=0;
NDD_POSITION_LEFT_CORNER=2^NDD_POSITION_BIT;

NDD_MATRIX_ROW_MAJOR=0;
NDD_MATRIX_COL_MAJOR=2^NDD_MATRIX_ORDER_BIT;


nDim = length(size(data));

%OLD BEFORE we specified row and col major ordering
% if( nDim >=2)
%     ind = [1:1:nDim];
%     ind(1)=2;
%     ind(2)=1;
%     data = permute(data,ind);
% end

fid = fopen(filename, 'wb');
if(fid == -1)
    error('could not open file');
end

WRITE_VER1_FORMAT =0;
if(WRITE_VER1_FORMAT)
    fwrite(fid, 1, 'int32');
    fwrite(fid, 'NON1', '*char');
else % currently on version 2 supports COL-MAJOR and ROW_MAJOR ordering
    fwrite(fid, 2, 'int32');
    dataformat=bitor(NDD_MATRIX_COL_MAJOR , NDD_POSITION_LEFT_CORNER);
    dataformat=cast(bitor(dataformat, NDD_NON_UNIFORM ), 'int32');
    %dataformat=cast(bitor(0, NDD_POSITION_LEFT_CORNER),'int32');
    fwrite(fid,dataformat,'int32');
end
   


% sec min hour day month year
date=int32(fliplr(clock()));
fwrite(fid, date, 'int32');

dummyChar = repmat('a',256,1);
fwrite(fid, dummyChar, '*char');

dummyInt = repmat(1,4,1);
fwrite(fid, dummyInt, 'int32');

dummyDouble = repmat(0.5,4,1);
fwrite(fid, dummyDouble,'double');

%bytes per element
%% determine class the find number of bytes per element
type = class(data);
tmpType=zeros(1,type);
typeBytes = whos('tmpType');

%%
fwrite(fid, typeBytes.bytes, 'int32');

%number of dimensions
nDim = sum(size(data)>1);
fwrite(fid, nDim, 'int32');

%dimensions
if( nDim == 1)
    dimSize= length(data);
else
    dimSize =size(data);
end

fwrite(fid, dimSize, 'int32');

%

if( length(loc)~=nDim )
    error('Insufficient location data');
end
for i=1:length(loc)
    ntmp = length(loc{i});
    fwrite(fid, ntmp, 'int32');
end
for i=1:length(loc)
    fwrite(fid,loc{i},'double');
end
%% need to write out units 
if( exist('units', 'var'))
    if( length(units) ~= nDim)
        error('Insufficient unit information');
    end
    str = units{1};
    for i=2:length(units)
        str=[str SEPERATOR units{i}];
    end
    fwrite(fid, length(str), 'int64');
    fwrite(fid, str, '*char');
    
else % if you units aren't known write out 0
  fwrite(fid, 0, 'int64');
end    

fwrite(fid, data, type);
fclose(fid);
