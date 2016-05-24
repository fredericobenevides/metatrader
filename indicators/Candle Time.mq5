//+------------------------------------------------------------------+
//|                                                  Candle Time.mq5 |
//|                         Frederico Benevides - fredbene@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Frederico Benevides - fredbene@gmail.com"
#property version   "1.00"
#property indicator_chart_window

#property indicator_buffers 1
#property indicator_plots   1
//--- input parameters
input string textFont="Arial";
input int textFontSize=8;
input color    textColor=clrBlack;
input ENUM_BASE_CORNER corner=CORNER_RIGHT_UPPER;

string objName="candleTime";
string candleText="00:00";
ENUM_ANCHOR_POINT anchor=ANCHOR_RIGHT_LOWER;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Remove the label                                                                  |
//+------------------------------------------------------------------+
void onDeInit(const int r)
  {
   ObjectDelete(0,objName);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spreads[])
  {
//---

   if(!createCandleTime())
     {
      return 0;
     }

   ArraySetAsSeries(time,true);
   datetime timeLastCandle=time[0];

   updateCandleTime(timeLastCandle);

   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Create the Candle Time                                                                 |
//+------------------------------------------------------------------+
bool createCandleTime()
  {
   ResetLastError();
   if(!ObjectCreate(0,objName,OBJ_LABEL,0,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create the Candle Time! Error code = ",GetLastError());
      return false;
     }

   ObjectSetInteger(0,objName,OBJPROP_XDISTANCE,12);
   ObjectSetInteger(0,objName,OBJPROP_YDISTANCE,0);

   switch(corner)
     {
      case CORNER_LEFT_LOWER:
         anchor=ANCHOR_LEFT_LOWER;
         break;
      case CORNER_LEFT_UPPER:
         anchor=ANCHOR_LEFT_UPPER;
         break;
      case CORNER_RIGHT_LOWER:
         anchor=ANCHOR_RIGHT_LOWER;
         break;
      case CORNER_RIGHT_UPPER:
         anchor=ANCHOR_RIGHT_UPPER;
         break;
     }
   ObjectSetInteger(0,objName,OBJPROP_CORNER,corner);
   ObjectSetInteger(0,objName,OBJPROP_ANCHOR,anchor);

   ObjectSetString(0,objName,OBJPROP_TEXT,"00:00");
   ObjectSetString(0,objName,OBJPROP_FONT,textFont);
   ObjectSetInteger(0,objName,OBJPROP_FONTSIZE,textFontSize);
   ObjectSetInteger(0,objName,OBJPROP_COLOR,textColor);

   return true;
  }
//+------------------------------------------------------------------+
//| Update the candle time                                                                  |
//+------------------------------------------------------------------+
void updateCandleTime(datetime timeLastCandle)
  {
   int tlc= int(timeLastCandle);
   int ps = PeriodSeconds();
   int tc = int(TimeTradeServer());

   int totalTimestampInSeconds=tlc+ps-tc;
   int secondsLeft=totalTimestampInSeconds%60;

// Since minutes can be greater than 60, so use module to
// make minutes less than 60
   int minutesLeft=(totalTimestampInSeconds-secondsLeft)/60;
   minutesLeft-=(minutesLeft -(minutesLeft%60));

// Make minutes in seconds, to calculate using seconds
   int hoursLeft=totalTimestampInSeconds-secondsLeft-(minutesLeft*60);
   hoursLeft/=60; // transform to minutes
   hoursLeft/=60; // transform to hour

   string sHoursLeft=IntegerToString(hoursLeft,2,'0');
   string sMinutesLeft=IntegerToString(minutesLeft,2, '0');
   string sSecondsLeft=IntegerToString(secondsLeft,2, '0');
   candleText=sHoursLeft+":"+sMinutesLeft+":"+sSecondsLeft;

   ObjectSetString(0,objName,OBJPROP_TEXT,candleText);
  }
//+------------------------------------------------------------------+
