//+------------------------------------------------------------------+
//|                                                         Test.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Frederico Benevides"
#property link      "fredbene@gmail.com"

#include <MyLibs\Test\MdJumper.mqh>
#include <Arrays\List.mqh>
//+------------------------------------------------------------------+
//| Class to work on test
//+------------------------------------------------------------------+
class CTest
  {
private:
   datetime          m_last_time_test;
   bool              m_update_interface_test;

   CList            *m_md_jumpers;

public:
                     CTest();
   void              RunEnvTest(bool useSkipDays=false);
   bool              IsDayValid(MqlDateTime &timeServer);

   void              HistoryReport();
  };
//+------------------------------------------------------------------+
//| Constructor
//+------------------------------------------------------------------+
CTest::CTest(void)
  {
   m_last_time_test=TimeTradeServer();
   m_update_interface_test=true;

   m_md_jumpers=new CList;

   CMdJumper *md=new CMdJumper;
   md.Add(2014,6,2);
   m_md_jumpers.Add(md);
  }
//+------------------------------------------------------------------+
//| Run using the interface for test
//+------------------------------------------------------------------+
void CTest::RunEnvTest(bool useSkipDays=false)
  {
   datetime ts=TimeTradeServer();
   MqlDateTime sts;
   TimeToStruct(ts,sts);

   MqlDateTime slt;
   TimeToStruct(m_last_time_test,slt);

   if(useSkipDays && !IsDayValid(sts))
      return;

   if(sts.year>slt.year || sts.mon>slt.mon || sts.day>slt.day)
     {
      m_last_time_test=ts;
      m_update_interface_test=true;
     }

   if(m_update_interface_test)
     {
      HiLoDialog.InitForTest();
      m_update_interface_test=false;
     }
  }
//+------------------------------------------------------------------+
//| Is a valid day to run
//+------------------------------------------------------------------+
bool CTest::IsDayValid(MqlDateTime &timeServer)
  {
   CMdJumper *currentMd=m_md_jumpers.GetCurrentNode();
   while(currentMd!=NULL)
     {
      int mdYear=currentMd.Year();
      int mdMonth=currentMd.Month();
      int mdDay=currentMd.Day();

      if(timeServer.year==mdYear && timeServer.mon==mdMonth && timeServer.day==mdDay)
         return false;

      currentMd=m_md_jumpers.GetNextNode();
     }

   return true;
  }
//+------------------------------------------------------------------+
//| Generate the History Report
//+------------------------------------------------------------------+
void CTest::HistoryReport()
  {
   ResetLastError();

   int filehandle=FileOpen("test.csv",FILE_WRITE|FILE_CSV,";");
//int filehandle=FileOpen("test.csv",FILE_READ|FILE_WRITE|FILE_CSV,";");

   if(filehandle==INVALID_HANDLE)
      Print("Operation FileOpen failed, error ",GetLastError());
   else
     {
      Print("Creating the file");
      //FileSeek(filehandle,0,SEEK_END);

      datetime end=TimeCurrent();
      datetime start=end-(PeriodSeconds(PERIOD_MN1)*36);
      HistorySelect(start,end);

      int deals=HistoryDealsTotal();
      for(int i=0; i<deals;i++)
        {
         ulong ticket=HistoryDealGetTicket(i);
         if(ticket>0)
           {
            datetime date = (datetime)HistoryDealGetInteger(ticket,DEAL_TIME);
            string symbol = HistoryDealGetString(ticket,DEAL_SYMBOL);
            string type=EnumToString((ENUM_DEAL_TYPE)HistoryDealGetInteger(ticket,DEAL_TYPE));
            string entry=EnumToString((ENUM_DEAL_ENTRY)HistoryDealGetInteger(ticket,DEAL_ENTRY));
            double volume=HistoryDealGetDouble(ticket,DEAL_VOLUME);
            double price=HistoryDealGetDouble(ticket,DEAL_PRICE);
            double profit=HistoryDealGetDouble(ticket,DEAL_PROFIT);

            FileWrite(filehandle,date,symbol,type,entry,volume,price,profit);
           }
        }
      FileClose(filehandle);
      Print("Closing the file");
     }
  }
//+------------------------------------------------------------------+
