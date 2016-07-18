//+------------------------------------------------------------------+
//|                                                     BarUtils.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Frederico Benevides"
#property link      "fredbene@gmail.com"
//+------------------------------------------------------------------+
//| Chart utilities
//+------------------------------------------------------------------+
class CChartUtils
  {
   datetime          m_dt_old_bar;
public:
   bool              IsNewBar(ENUM_TIMEFRAMES currentTimeFrame);
  };
//+------------------------------------------------------------------+
//| Verify if the Chart has a New Bar                                                                  
//+------------------------------------------------------------------+
bool CChartUtils::IsNewBar(ENUM_TIMEFRAMES currentTimeFrame)
  {
   datetime dtNewBar[1];
   if(CopyTime(_Symbol,currentTimeFrame,0,1,dtNewBar))
     {
      if(m_dt_old_bar!=dtNewBar[0])
        {
         m_dt_old_bar=dtNewBar[0];
         return true;
        }
     }
   else
     {
      Print("Error in copying historical times data, error =",GetLastError());
      ResetLastError();
     }

   return false;
  }
//+------------------------------------------------------------------+
