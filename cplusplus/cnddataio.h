/* 
 * File:   cnddataio.h
 * Author: cbct
 *
 * Created on November 17, 2011, 2:45 PM
 */

#ifndef _CNDDATAIO_H
#define	_CNDDATAIO_H

#include "common.h"
#include <cstring>
class CNDData;



class CNDDataIO{
public:

   enum eNDDataIOErr
   {
      SUCCESS=0,
      UNKNOWN_ERR=1,
      FILE_OPEN_ERR=2,
      UNKNOWN_FORMAT=3,
      UNSUPPORTED_BPE=4,
      BAD_INPUT=5

   };

   CNDDataIO();
   virtual ~CNDDataIO();

   /** Writes uniformly spaced data (more compact) */
   static eNDDataIOErr writeData( const std::string &i_filename,
                                  const void        *i_pData,
                                  const int         &i_bytePerElement,
                                  const UIntVec     &i_dim,
                                  const DoubleVec   &i_pitch,
                                  const DoubleVec   &i_center );

   /** Writes non-uniform data */
   static eNDDataIOErr writeData( const std::string  &i_filename,
                                  const void         *i_data,
                                  const int          &i_bytePerElement,
                                  const UIntVec      &i_dim,
                                  const DoubleVecVec &i_pos );

   /* reads CNDData ... you must handle deletion of data */
   static eNDDataIOErr  readData( const std::string &i_filename,
                                  CNDData &o_data );

private:

   static eNDDataIOErr writeHeader( std::ofstream &o_file,
                                    const int &i_bytePerElement,
                                    const UIntVec &i_dim);

   static const int Version=0;

};

class CNDData
{

public:

   friend class CNDDataIO;

   CNDData()
           :
            BytePerElement(0),
            nDim(0),
            nSize(0),
            Data(NULL),
            Type(""),
            Version(0)
            
   {
      Version=0;
      Type = std::string("");

   };

   CNDData(const CNDData & orig)
   {
      printf("Copy Constructor()\n");
      this->BytePerElement = orig.BytePerElement;
      this->Center         = orig.Center;
      this->Dim            = orig.Dim;
      this->Pitch          = orig.Pitch;
      this->Pos            = orig.Pos;
      this->Type           = orig.Type;
      this->Version        = orig.Version;
      this->nDim           = orig.nDim;
      this->nSize          = orig.nSize;
      //allocate data
      allocateData();
      //copy data
      std::memcpy(this->Data, orig.Data, this->BytePerElement*orig.nSize);
   }

   CNDData& operator = ( const CNDData &orig)
   {
      printf("Operator =..\n");
      this->BytePerElement = orig.BytePerElement;
      this->Center         = orig.Center;
      this->Dim            = orig.Dim;
      this->Pitch          = orig.Pitch;
      this->Pos            = orig.Pos;
      this->Type           = orig.Type;
      this->Version        = orig.Version;
      this->nDim           = orig.nDim;
      this->nSize          = orig.nSize;
      //allocate data
      allocateData();
      //copy data
      std::memcpy(this->Data, orig.Data, this->BytePerElement*orig.nSize);
      return *this;
   }


   ~CNDData()
   {
      deleteData();
   }


   int            BytePerElement;
   int            nDim;
   long           nSize;
   UIntVec        Dim;
   DoubleVec      Pitch;
   DoubleVec      Center;
   DoubleVecVec   Pos;
   void*          Data;
   std::string    Type;

protected:

   
   int            Version;

private:

   void deleteData()
   {
      if( Data!=NULL)
      {
         switch( BytePerElement )
         {
            case 1:
            {
               delete [] (char*)Data;
            }break;
            case 2:
            {
               delete [] (short*)Data;
            }break;
            case 4:
            {
               delete [] (float*)Data;
            }break;
            case 8:
            {

               delete [] (double*)Data;
            }break;
            default:
            {
               printf("ERROR Memory Leak!!!\n");
            }break;
            

         }
         printf("deleted Data.\n");
      }
   }

   //pre condition - BytePerElement and nSize set
   void allocateData()
   {
      deleteData();
      switch( BytePerElement )
      {
         case 1:
         {
            Data = new char[nSize];
         }break;
         case 2:
         {
            Data = new short[nSize];
         }break;
         case 4:
         {
            Data = new float[nSize];
         }break;
         case 8:
         {
            Data = new double[nSize];
         }break;
         default:
         {
            printf("Unkown Type\n");
         }break;

      }
   }


};

#endif	/* _CNDDATAIO_H */

