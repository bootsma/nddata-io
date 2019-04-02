These are the C++ files for reading and writing data in NDD format. 

TODO: update class to be templated on type, current model works by just using a bytes per element model. All data 
with 4 bytes elements are allocated and stored as floats and 8 byte data stored and allocated as double. You are left 
to cast to the appropriate type (e.g. float to int32, double to int64). The real type should be stored in the file.
