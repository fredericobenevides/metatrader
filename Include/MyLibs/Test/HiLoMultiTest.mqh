//+------------------------------------------------------------------+
//|                                                    MultiTest.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Frederico Benevides"
#property link      "fredbene@gmail.com"
//+------------------------------------------------------------------+
//| Class to work on test
//+------------------------------------------------------------------+
class CHiLoMultiTest
  {

public:

   void              HistoryReport();
  };
//+------------------------------------------------------------------+
//| Generate the History Report
//+------------------------------------------------------------------+
void CHiLoMultiTest::HistoryReport()
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
