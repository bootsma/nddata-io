/* 
 * File:   cnddataio.cpp
 * Author: cbct
 * 
 * Created on November 17, 2011, 2:45 PM
 */

#include "cnddataio.h"

#include <time.h>
#include <fstream>
#include <iostream>
#include <assert.h>
#include <numeric>
#include <string>

using namespace std;


CNDDataIO::CNDDataIO() {
}

CNDDataIO::~CNDDataIO() {
}




CNDDataIO::eNDDataIOErr CNDDataIO::readData(const std::string& i_filename,
                                            CNDData &data )
{
   ifstream file;
   file.open(i_filename.c_str(), ios::binary);
   if(!file.is_open())
   {
      assert(false);
      return FILE_OPEN_ERR;
   }



   file.read((char*)&data.Version, sizeof(int));

   char type[5];
   file.read(type, 4);
   type[4]='\0';
   data.Type = std::string(type);

   //ignore date etc.. for now
   int date[6];
   file.read((char*)&date,6*sizeof(int));

   char dummyChar[256];
   file.read(dummyChar, 256);

   int  dummyInt[4];
   file.read((char*)&dummyInt, 4*sizeof(int));

   double dummyDouble[4];
   file.read((char*)&dummyDouble, 4*sizeof(double));


   file.read((char*)&data.BytePerElement,sizeof(int));

   file.read((char*)&data.nDim, sizeof(int));

   data.Dim.resize(data.nDim,0);
   file.read((char*)&data.Dim[0],sizeof(unsigned int)*data.nDim);

   
   if( data.Type == std::string("UNI1"))
   {
      data.Pitch.resize(data.nDim,0);
      file.read((char*)&data.Pitch[0],sizeof(double)*data.nDim);
      data.Center.resize(data.nDim,0);
      file.read((char*)&data.Center[0],sizeof(double)*data.nDim);

   }
   else if(data.Type == std::string("NON1"))
   {
      int *posSize = new int[data.nDim];
      file.read((char*)posSize, sizeof(int)*data.nDim);
      data.Pos.resize(data.nDim);
      for(int i=0; i<data.nDim;i++)
      {
         data.Pos[i].resize(posSize[i],0);
         file.read((char*)&data.Pos[i][0], sizeof(double)*posSize[i]);
      }


      delete [] posSize;
   }
   else
   {
      assert(false);
      return UNKNOWN_FORMAT;
   }

   long byte_size=0;
   long size = 1;
   for( int i=0; i<data.nDim; i++)
   {
      size*=data.Dim[i];
   }
   if( data.nDim ==0)
      size=0;

   switch( data.BytePerElement)
   {
      case 1:
      {
         data.Data = new char[size];
         byte_size=size;
      }break;
      case 2:
      {
         data.Data = new short[size];
         byte_size = 2*size;
      }break;
      case 4:
      {
         data.Data = new float[size];
         byte_size = 4*size;
      }break;
      case 8:
      {
         data.Data = new double[size];
         byte_size = 8*size;

      }break;
      default:
      {
         assert(false);
         return UNSUPPORTED_BPE;
      }
   }
   data.nSize = size;
   file.read((char*)data.Data, byte_size);

   return(SUCCESS);
}



/**
 * @function writeData
 * @description This function will write any n-dimensional data structure of
 *              any type to the specified file. There is a few extra
 *              spaces left for future parameters:
 *                      4 - double values
 *                      4 - integer values
 *                      256 chars
 */
CNDDataIO::eNDDataIOErr CNDDataIO::writeData(const std::string &i_filename,
                                             const void        *i_data,
                                             const int         &i_bytesper,
                                             const UIntVec     &i_dim,
                                             const DoubleVec   &i_pitch,
                                             const DoubleVec   &i_center )
{

   string name =i_filename;
   if( i_filename.find(std::string(".ndd"),0)==string::npos)
   {
      name = i_filename+std::string(".ndd");
   }
   

   //open the file
   ofstream file;
   file.open( name.c_str(), ios::binary);
   if( !file.is_open() )
   {
      assert(false);
      return FILE_OPEN_ERR;
   }
 

   //write the version
   int v = Version;
   file.write( (char*)&v, sizeof(int));


   //write the type
   char type[5]="UNI1";   //uniform spacing
   file.write( type,4);


   writeHeader(file, i_bytesper, i_dim);

   int numDim = i_dim.size();
   //pitch of each element
   file.write( (char*)&i_pitch[0],sizeof(double)*numDim);
   
          
   //center of each element
   file.write( (char*)&i_center[0],sizeof(double)*numDim);
 
   //write chunk of data
   long numElements=1;
   int sz = i_dim.size();
   for(int i=0; i<sz; i++)
      numElements*=i_dim[i];
   
   file.write((char*)i_data, i_bytesper*numElements);

   file.close();

   return SUCCESS;
}

CNDDataIO::eNDDataIOErr CNDDataIO::writeData( const std::string  &i_filename,
                                  const void         *i_data,
                                  const int          &i_bytesper,
                                  const UIntVec      &i_dim,
                                  const DoubleVecVec &i_pos )
{

   string name = i_filename+std::string(".ndd");

   //open the file
   ofstream file;
   file.open( name.c_str(), ios::binary);
   if( !file.is_open() )
   {
      assert(false);
      return FILE_OPEN_ERR;
   }
   
   if(i_pos.size() != i_dim.size())
   {
       assert(false);
       return BAD_INPUT;
   }

   //write the version
   int v = Version;
   file.write( (char*)&v, sizeof(int));

   //write the type
   char type[5]="NON1";   //uniform spacing
   file.write( type, 4);

   writeHeader(file, i_bytesper, i_dim);

   int sz=i_pos.size();
   for(int i=0; i<sz; i++)
   {
      int size = (int)i_pos[i].size();
      file.write((char*)&(size), sizeof(int));
   }
   for(int i=0; i<sz; i++)
   {
       file.write((char*)&(i_pos[i])[0], sizeof(double)*i_pos[i].size());
   }

   //write chunk of data
   long numElements=1;
   sz =i_dim.size();
   for(int i=0; i<sz; i++)
      numElements*=i_dim[i];

   file.write((char*)i_data, i_bytesper*numElements);

   file.close();

   return SUCCESS;

}

CNDDataIO::eNDDataIOErr CNDDataIO::writeHeader( ofstream& io_file,
                                                const int &i_bytesper,
                                                const UIntVec &i_dim )
{

   //write the current date
   time_t rawtime;
   struct tm *tminfo;
   time(&rawtime);
   tminfo = localtime(&rawtime);
   int month = tminfo->tm_mon+1;
   int year = tminfo->tm_year+1900;
   io_file.write((char*)&(tminfo->tm_sec),sizeof(int));
   io_file.write((char*)&(tminfo->tm_min),sizeof(int));
   io_file.write((char*)&(tminfo->tm_hour),sizeof(int));
   io_file.write((char*)&(tminfo->tm_mday), sizeof(int));
   io_file.write((char*)&(month), sizeof(int));
   io_file.write( (char*)&(year), sizeof(int));

   //write dummy variables for future use
   double dummyDouble[4]={0.10,0.2,0.3,0.4};
   int    dummyInt[4]={1,2,3,4};
   char   dummyChar[256]="This is unused space.. use it wisely.";

   io_file.write( dummyChar,256);
   //std::cout<<sizeof(int);
   io_file.write( (char*)&dummyInt, sizeof(int)*4);
   io_file.write( (char*)&dummyDouble, sizeof(double)*4);

   //write data info
   io_file.write( (char*)&i_bytesper, sizeof(int) );
   //file.write( (char*)&g

   //number of dimensions
   int numDim = i_dim.size();
   io_file.write( (char*)&numDim, sizeof(int));

   //number of elements in each dimension
   io_file.write( (char*)&i_dim[0],sizeof(unsigned int)*numDim);

   return SUCCESS;
}
