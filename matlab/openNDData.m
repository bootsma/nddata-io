% Go to the right directory and display files.
if ~exist('DefaultPathname','var')
    DefaultPathname = [];
end
[NDD_filename, DefaultPathname] = uigetfile([DefaultPathname,'\*.ndd'], 'Pick an NDD-file');
if isequal(NDD_filename,0) | isequal(DefaultPathname,0)
    disp('User pressed cancel')
    return
end

output = readNDData([DefaultPathname NDD_filename]);