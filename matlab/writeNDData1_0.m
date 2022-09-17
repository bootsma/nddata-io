
function writeNDData1_0( filename, data, start, pitch )
% WRITENDDATA1_0 original of WRITENDDATA only use this if you are using old data/scripts. Writes N-dimesional data with uniform sampling
%   WRITENDDATA(FILENAME, DATA, START, PITCH) writes the N-dimensional data
%   matrix DATA to the file named FILENAME. The starting positions 
%   (START vector) is written to th file along with the pitch of each 
%   dimension (PITCH vector)
%   If the data has non-uniform sampling in any of the dimension another 
%   format is available, see NON1 in readNDData and update this function 
%   accordingly.


nDim = length(size(data));
if( nDim >=2)
    ind = [1:1:nDim];
    ind(1)=2;
    ind(2)=1;
    data = permute(data,ind);
end

fid = fopen(filename, 'wb');
if(fid == -1)
    error('could not open file');
end



fwrite(fid, 1, 'int32');
fwrite(fid, 'UNI1', '*char');

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
    dimSize =size(data)
end

fwrite(fid, dimSize, 'int32');

%todo allow for pitch input
%pitch
if( length(pitch)~=nDim )
    error('Insufficient pitch data');
end
fwrite(fid, pitch, 'double');

%todo allow for pitch input
%pitch
if( length(start)~=nDim )
    error('Insufficient pitch data');
end
fwrite(fid, start, 'double');


fwrite(fid, start, 'double');
if( nDim > 1 )
    ind = fliplr([1:1:nDim]);
    data = permute(data, ind);
end
fwrite(fid, data, type);
fclose(fid);
