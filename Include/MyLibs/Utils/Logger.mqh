//+------------------------------------------------------------------+
//|                                                       Logger.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Frederico Benevides"
#property link      "fredbene@gmail.com"

// Max size of cache (quantity)
#define MAX_CACHE_SIZE 10000

// Max file size in megabytes
#define MAX_FILE_SIZEMB 10
//+------------------------------------------------------------------+
//| Util class for Log
//+------------------------------------------------------------------+
class CLogger
  {
private:

   string            m_exp_name;
   string            m_symbol;
   string            m_filename;

   string            m_log_cache[MAX_CACHE_SIZE]; // Cache max size
   int               m_size_cache;                // Cache counter
   int               m_cache_time_limit;          // Caching time
   datetime          m_cache_time;                // Time of cache last flush into file

   int               m_handle_file;               // Handle of log file
   string            m_default_category;

public:

   void              CLogger(void);
   void             ~CLogger(void);

   void              SetSetting(string expName,string fileName,string defaultCategory="",int cacheTimeLimit=0);
   void              Init();
   void              DeInit();

   void              Write(string msg,string category="");
   void              Write(string msg,string category,color colorOfMsg,string file="",int line=0);
   void              Write(string msg,string category,uchar red,uchar green,uchar blue,string file="",int line=0);
   void              Flush(void);

private:

   void              writeLog(string logMsg);
  };
//+------------------------------------------------------------------+
//| Default Constructor                                                                 
//+------------------------------------------------------------------+
CLogger::CLogger(void)
  {
   m_cache_time_limit=0;
   m_cache_time=0;
   m_size_cache=0;
  }
//+------------------------------------------------------------------+
//| Default Destructor                                                                 
//+------------------------------------------------------------------+
CLogger::~CLogger(void)
  {
  }
//+------------------------------------------------------------------+
//| Settings the default configs
//+------------------------------------------------------------------+
void CLogger::SetSetting(string expName,string fileName,string defaultCategory="",int cacheTimeLimit=0)
  {
   m_exp_name=expName;
   m_filename=fileName;
   m_cache_time_limit=cacheTimeLimit;

   m_exp_name=expName;
   m_filename=fileName;
   m_cache_time_limit=cacheTimeLimit;

   if(defaultCategory=="")
      m_default_category="Comment";
   else
      m_default_category=defaultCategory;
  }
//+------------------------------------------------------------------+
//| Init after set the default configs
//+------------------------------------------------------------------+
void CLogger::Init(void)
  {
   string filePath;
   MqlDateTime date;
   int i=0;
   TimeToStruct(TimeCurrent(),date);
   StringConcatenate(filePath,"logs\\log_",m_exp_name,"\\log_",m_filename,"_",
                     date.year,date.mon,date.day);

   m_handle_file=FileOpen(filePath+".txt",FILE_WRITE|FILE_READ|
                          FILE_UNICODE|FILE_TXT|FILE_SHARE_READ);  // Open or create new file
   while(FileSize(m_handle_file)>(MAX_FILE_SIZEMB*1000000)) // Check file size
     {
      // Open or create new log file
      i++;
      FileClose(m_handle_file);
      m_handle_file=FileOpen(filePath+"_"+(string)i+".txt",
                             FILE_WRITE|FILE_READ|FILE_UNICODE|FILE_TXT|FILE_SHARE_READ);
     }
   FileSeek(m_handle_file,0,SEEK_END); // Set pointer to the end of file
  }
//+------------------------------------------------------------------+
//|   Deinitialization                                               |
//+------------------------------------------------------------------+
void CLogger::DeInit(void)
  {
   Flush();
   FileClose(m_handle_file); // Close file
  }
//+------------------------------------------------------------------+
//|   Generate message and write into log                            |
//+------------------------------------------------------------------+
void CLogger::Write(string msg,string category="")
  {
   string msgLog;
   if(category=="")
      category=m_default_category;

// Generate line and call method of writing message
   StringConcatenate(msgLog,category,":|:",TimeToString(TimeCurrent(),TIME_SECONDS),"    ",msg);
   writeLog(msgLog);
  }
//+------------------------------------------------------------------+
//|    Generate message and write into log                           |
//+------------------------------------------------------------------+
void CLogger::Write(string msg,string category,color colorOfMsg,string file="",int line=0)
  {
   string msgLog;
   int red,green,blue;
   red=(colorOfMsg  &Red);           // Select red color from constant
   green=(colorOfMsg  &0x00FF00)>>8; // Select green color from constant
   blue=(colorOfMsg  &Blue)>>16;     // Select blue color from constant
                                     // Check if file or line are passed, generate line and call method of writing message
   if(file!="" && line!=0)
     {
      StringConcatenate(msgLog,category,":|:",red,",",green,",",blue,
                        ":|:",TimeToString(TimeCurrent(),TIME_SECONDS),"    ",
                        "file: ",file,"   line: ",line,"   ",msg);
     }
   else
     {
      StringConcatenate(msgLog,category,":|:",red,",",green,",",blue,
                        ":|:",TimeToString(TimeCurrent(),TIME_SECONDS),"    ",msg);
     }
   writeLog(msgLog);
  }
//+------------------------------------------------------------------+
//|    Generate message and write into log                           |
//+------------------------------------------------------------------+
void CLogger::Write(string msg,string category,uchar red,uchar green,uchar blue,string file="",int line=0)
  {
   string msgLog;

// Check if file or line are passed, generate line and call method of writing message
   if(file!="" && line!=0)
     {
      StringConcatenate(msgLog,category,":|:",red,",",green,",",blue,
                        ":|:",TimeToString(TimeCurrent(),TIME_SECONDS),"    ",
                        "file: ",file,"   line: ",line,"   ",msg);
     }
   else
     {
      StringConcatenate(msgLog,category,":|:",red,",",green,",",blue,
                        ":|:",TimeToString(TimeCurrent(),TIME_SECONDS),"    ",msg);
     }
   writeLog(msgLog);
  }
//+------------------------------------------------------------------+
//| Flush cache into file
//+------------------------------------------------------------------+
void CLogger::Flush(void)
  {
   for(int i=0;i<m_size_cache;i++)
      FileWrite(m_handle_file,m_log_cache[i]);

   m_size_cache=0;             // Reset cache counter
   m_cache_time=TimeCurrent(); // Set time of reseting cache
  }
//+------------------------------------------------------------------+
//| Write message into file or cache
//+------------------------------------------------------------------+
void CLogger::writeLog(string logMsg)
  {
   if(m_cache_time_limit!=0) // Check if cache is enabled
     {
      if((m_size_cache<MAX_CACHE_SIZE-1 && TimeCurrent()-m_cache_time<m_cache_time_limit)
         || m_size_cache==0) // Check if cache time is out or if cache limit is reached
        {
         // Write message into cache
         m_log_cache[m_size_cache++]=logMsg;
        }
      else
        {
         // Write message into cache and flush cache into file
         m_log_cache[m_size_cache++]=logMsg;
         Flush();
        }
     }
   else
     {
      // Cache is disabled, immediately write into file
      FileWrite(m_handle_file,logMsg);
     }
   if(FileTell(m_handle_file)>(MAX_FILE_SIZEMB*1000000)) // Check current file size
     {
      // File size exceeds allowed limit, close current file and open new
      DeInit();
      Init();
     }
  }
//+------------------------------------------------------------------+
