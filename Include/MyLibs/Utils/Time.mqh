//+------------------------------------------------------------------+
//|                                              PanelHiloTrades.mq5 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Frederico Benevides"
#property link      "fredbene@gmail.com"
//+------------------------------------------------------------------+
//| Util class for Time
//+------------------------------------------------------------------+
class CTime
  {
private:
   datetime          m_last_time;
public:
                     CTime(void);
   datetime          StrToDatetime(string hourMinute);
   datetime          IntToDatetime(int hour,int minute);

   bool              TimeTradeServerBetween(datetime start,datetime end);
   bool              TimeTradeServerGtEnd(datetime end);

   bool              HasPassedTime(int timeToPass);

   void              PrintCurrentTimeServer();
  };
//+------------------------------------------------------------------+
//| Default Constructor                                                                 
//+------------------------------------------------------------------+
CTime::CTime(void)
  {
   m_last_time=TimeTradeServer();
  }
//+------------------------------------------------------------------+
//| StrToDateTime transform a string "09:00" to datetime as "yyyy.mm.dd 09:00:00"
//+------------------------------------------------------------------+
datetime CTime::StrToDatetime(string hourMinute)
  {
   string currentDateStr=TimeToString(TimeTradeServer(),TIME_DATE);
   string currentDateWithHour=currentDateStr+" "+hourMinute+":00";
   return StringToTime(currentDateWithHour);
  }
//+------------------------------------------------------------------+
//| IntToDatetime transform a int 09, 30 to datetime as "yyyy.mm.dd 09:30:00"
//+------------------------------------------------------------------+
datetime CTime::IntToDatetime(int hour,int minute)
  {
   string currentDateStr=TimeToString(TimeTradeServer(),TIME_DATE);

   string sHour=""+IntegerToString(hour);
   string sMinute=""+IntegerToString(minute);
   if(hour<10)
      sHour="0"+sHour;
   if(minute<10)
      sMinute="0"+sMinute;

   string currentDateWithHour=currentDateStr+" "+sHour+":"+sMinute+":00";
   return StringToTime(currentDateWithHour);
  }
//+------------------------------------------------------------------+
//| Verify if the time of Server are between start and end datetime
//+------------------------------------------------------------------+
bool CTime::TimeTradeServerBetween(datetime start,datetime end)
  {
   datetime timeServer=TimeTradeServer();                              // current time of server
   if(start<end) if(timeServer>=start && timeServer<end) return(true); // check if we are in the range
   if(start>=end) if(timeServer>=start|| timeServer<end) return(true);
   return(false);
  };
//+------------------------------------------------------------------+
//| Verify if the time of Server are greater than endtime
//+------------------------------------------------------------------+
bool CTime::TimeTradeServerGtEnd(datetime end)
  {
   datetime timeServer=TimeTradeServer();
   if(timeServer>=end) return(true);
   return(false);
  };
//+------------------------------------------------------------------+
//| Verify if has passed the seconds from the parameter
//+------------------------------------------------------------------+
bool CTime::HasPassedTime(int timeInSeconds)
  {
   datetime timeServer=TimeTradeServer();

   if(timeServer>(m_last_time+timeInSeconds))
     {
      m_last_time=timeServer;
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//| Print the current time of server
//+------------------------------------------------------------------+
void CTime::PrintCurrentTimeServer()
  {
   datetime timeServer=TimeTradeServer();
   Print(timeServer);
  };
//+------------------------------------------------------------------+
