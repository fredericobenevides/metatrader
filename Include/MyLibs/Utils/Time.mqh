//+------------------------------------------------------------------+
//|                                              PanelHiloTrades.mq5 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Frederico Benevides"
#property link      "fredbene@gmail.com"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CTime
  {
public:
   datetime          StrToDatetime(string hourMinute);
   bool              TimeTradeServerBetween(datetime start,datetime end);
   bool              TimeTradeServerGtEnd(datetime end);
  };
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
