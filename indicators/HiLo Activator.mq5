//+------------------------------------------------------------------+
//|                                               HiLo Activator.mq5 |
//|                                              Frederico Benevides |
//|                                               fredbene@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Frederico Benevides"
#property link      "fredbene@gmail.com"
#property version   "1.20"
#property indicator_chart_window
#property indicator_buffers 13
#property indicator_plots   10
//--- plot Continuous High
#property indicator_label1  "Continuous High HiLo (Sell)"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrOrangeRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot Continuous Low
#property indicator_label2  "Continuous Low HiLo (Buy)"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrLimeGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
//--- plot First High
#property indicator_label3  "First High HiLo (Sell)"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrOrangeRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  3
//--- plot First Low
#property indicator_label4  "First Low HiLo (Buy)"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrLimeGreen
#property indicator_style4  STYLE_SOLID
#property indicator_width4  3
//--- plot Second High
#property indicator_label5  "Second High HiLo (Sell)"
#property indicator_type5   DRAW_ARROW
#property indicator_color5  clrChocolate
#property indicator_style5  STYLE_SOLID
#property indicator_width5  1
//--- plot Second Low
#property indicator_label6  "Second Low HiLo (Buy)"
#property indicator_type6   DRAW_ARROW
#property indicator_color6  clrDarkGreen
#property indicator_style6  STYLE_SOLID
#property indicator_width6  1
//--- plot Current High
#property indicator_label7  "Current High HiLo (Sell)"
#property indicator_type7   DRAW_ARROW
#property indicator_color7  clrDarkGray
#property indicator_style7  STYLE_SOLID
#property indicator_width7  3
//--- plot Current Low
#property indicator_label8  "Current Low HiLo (Buy)"
#property indicator_type8   DRAW_ARROW
#property indicator_color8  clrDarkGray
#property indicator_style8  STYLE_SOLID
#property indicator_width8  3
//--- plot Continuous High
#property indicator_label9  "Continuous High No Line for HiLo (Sell)"
#property indicator_type9   DRAW_NONE
//--- plot Continuous Low
#property indicator_label10  "Continuous Low HiLo No Line for HiLo (Buy)"
#property indicator_type10   DRAW_NONE


//--- input parameters
input string         InpHiLoData="------------------------------";    // --------------- HiLo ---------------
input int            InpPeriod=1;                                     // Period
input ENUM_MA_METHOD InpMaMethod=MODE_SMMA;                           // Method
input bool           InpArrowInFirstHiLo=false;                       // Add an arrow to the first HiLo
input bool           InpArrowInSecondHiLo=true;                       // Add an arrow to the second HiLo
input bool           InpArrowInCurrentCandle=true;                    // Add an arrow to the current candle
input bool           InpShowHiLoLine=false;                           // Show the line of HiLo

//--- indicator buffers
double HiLoHighBuffer[];
double HiLoLowBuffer[];
double HiLoFirstHighBuffer[];
double HiLoFirstLowBuffer[];
double HiLoSecondHighBuffer[];
double HiLoSecondLowBuffer[];
double HiLoCurrentHighBuffer[];
double HiLoCurrentLowBuffer[];
double HiLoHighNoLineBuffer[];
double HiLoLowNoLineBuffer[];
double MaHighBuffer[];
double MaLowBuffer[];
double TrendBuffer[];

//--- global vars
int MaHighHandle;
int MaLowHandle;
int Period;
int MinRatesTotal;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,HiLoHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,HiLoLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,HiLoFirstHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,HiLoFirstLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(4,HiLoSecondHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(5,HiLoSecondLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(6,HiLoCurrentHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(7,HiLoCurrentLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(8,HiLoHighNoLineBuffer,INDICATOR_DATA);
   SetIndexBuffer(9,HiLoLowNoLineBuffer,INDICATOR_DATA);
   SetIndexBuffer(10,MaHighBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(11,MaLowBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(12,TrendBuffer,INDICATOR_CALCULATIONS);

//--- set the type of arrow
   PlotIndexSetInteger(2,PLOT_ARROW,167); // First High
   PlotIndexSetInteger(3,PLOT_ARROW,167); // First Low
   PlotIndexSetInteger(4,PLOT_ARROW,162); // Second High
   PlotIndexSetInteger(5,PLOT_ARROW,162); // Second Low
   PlotIndexSetInteger(6,PLOT_ARROW,167); // Current High
   PlotIndexSetInteger(7,PLOT_ARROW,167); // Current Low

//--- set direction
   ArraySetAsSeries(HiLoHighBuffer,true);
   ArraySetAsSeries(HiLoLowBuffer,true);
   ArraySetAsSeries(HiLoFirstHighBuffer,true);
   ArraySetAsSeries(HiLoFirstLowBuffer,true);
   ArraySetAsSeries(HiLoSecondHighBuffer,true);
   ArraySetAsSeries(HiLoSecondLowBuffer,true);
   ArraySetAsSeries(HiLoCurrentHighBuffer,true);
   ArraySetAsSeries(HiLoCurrentLowBuffer,true);
   ArraySetAsSeries(HiLoHighNoLineBuffer,true);
   ArraySetAsSeries(HiLoLowNoLineBuffer,true);
   ArraySetAsSeries(MaHighBuffer,true);
   ArraySetAsSeries(MaLowBuffer,true);
   ArraySetAsSeries(TrendBuffer,true);

//--- check Period
   Period=(int)fmax(InpPeriod,2);
   MaHighHandle=iMA(NULL,0,Period,0,InpMaMethod,PRICE_HIGH);
   MaLowHandle=iMA(NULL,0,Period,0,InpMaMethod,PRICE_LOW);

   if(MaHighHandle==INVALID_HANDLE || MaLowHandle==INVALID_HANDLE)
     {
      Print("Unable to create handle for iMA");
      return(INIT_FAILED);
     }

   MinRatesTotal=InpPeriod+1; // Period + current candle
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &High[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
// 14 MinRates
// -> If MinRates has more than the rates to calculate, stop!
// It's not possible to calculate the HiLo if doesn't have enough candle
// -> If the bars calculated using the Handle has more than the rates total, stop!
   int t=BarsCalculated(MaHighHandle);
   if(MinRatesTotal>rates_total
      || BarsCalculated(MaHighHandle)>rates_total
      || BarsCalculated(MaLowHandle)>rates_total)
      return 0;

   ArraySetAsSeries(MaHighBuffer,true);
   ArraySetAsSeries(MaLowBuffer,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(time,true);

   int limit=0;
   if(prev_calculated>rates_total || prev_calculated<=0)
     {
      // Set the limit to calculate.
      // 100 candles
      // 13 Period
      // 14 MinRatesTotal
      // = 85 Index array
      limit=rates_total-MinRatesTotal-1;
     }
   else
     {
      limit=rates_total-prev_calculated;
     }

// Copy all the 87 elements less than candles that
// will not be part of the hilo.
// 85 limit
// 2 plus candles
// = 87 (13 candles of Period away)
   int toCopy=limit+2;

//---- copy newly appeared data into the arrays
   if(CopyBuffer(MaHighHandle,0,0,toCopy,MaHighBuffer)<=0) return(0);
   if(CopyBuffer(MaLowHandle,0,0,toCopy,MaLowBuffer)<=0) return(0);

   for(int i=limit; i>=0; i--)
     {
      cleanAllBuffers(i);
      calculateTrendBuffer(close[i],i);

      cleanLastCurrentHiLo(i);
      showHighHiLo(i);
      showLowHiLo(i);

      includeArrowInFirstHilo(i);
      includeArrowInSecondHilo(i,open[i]);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Clean all buffers setting EMPTY_VALUE on the index
//+------------------------------------------------------------------+
void cleanAllBuffers(int index)
  {
   HiLoHighBuffer[index]=EMPTY_VALUE;
   HiLoLowBuffer[index]=EMPTY_VALUE;
   HiLoFirstHighBuffer[index]=EMPTY_VALUE;
   HiLoFirstLowBuffer[index]=EMPTY_VALUE;
   HiLoSecondHighBuffer[index]=EMPTY_VALUE;
   HiLoSecondLowBuffer[index]=EMPTY_VALUE;
   HiLoCurrentHighBuffer[index]=EMPTY_VALUE;
   HiLoCurrentLowBuffer[index]=EMPTY_VALUE;
   HiLoHighNoLineBuffer[index]=EMPTY_VALUE;
   HiLoLowNoLineBuffer[index]=EMPTY_VALUE;
  }
//+------------------------------------------------------------------+
//| Calculate the Trend Buffer.
//| Verify if is a Trend of High HiLo or Low HiLo
//+------------------------------------------------------------------+
void calculateTrendBuffer(double closeCandleIndex,int index)
  {
// Verify if the closed candle is greater than High Buffer of the before Candle
   if(closeCandleIndex>MaHighBuffer[index+1])
     {
      // if is greater, is still on buying
      TrendBuffer[index]=1;
     }
   else if(closeCandleIndex<MaLowBuffer[index+1])
     {
      // else if less, is still on selling
      TrendBuffer[index]=-1;
     }
   else
     {
      // otherwise, get the value of the next candle, to see if keeps the buying or selling trend
      TrendBuffer[index]=TrendBuffer[index+1];
     }
  }
//+------------------------------------------------------------------+
//| Clean the last current HiLo in the Last Candle.
//+------------------------------------------------------------------+
void cleanLastCurrentHiLo(int index)
  {
   if(!InpArrowInCurrentCandle)
      return;

   if(HiLoCurrentHighBuffer[index+1]!=EMPTY_VALUE)
      HiLoCurrentHighBuffer[index+1]=EMPTY_VALUE;

   if(HiLoCurrentLowBuffer[index+1]!=EMPTY_VALUE)
      HiLoCurrentLowBuffer[index+1]=EMPTY_VALUE;
  }
//+------------------------------------------------------------------+
//|  Show the High HiLo which means the force is selling.                                                                |
//+------------------------------------------------------------------+
void showHighHiLo(int index)
  {
   if(TrendBuffer[index]<0)
     {
      HiLoHighNoLineBuffer[index]=MaHighBuffer[index];

      if(InpShowHiLoLine)
         HiLoHighBuffer[index]=HiLoHighNoLineBuffer[index];

      if(InpArrowInCurrentCandle)
         HiLoCurrentHighBuffer[index]=HiLoHighNoLineBuffer[index];
     }
  }
//+------------------------------------------------------------------+
//|  Show the Low HiLo which means the force is buying.                                                                 |
//+------------------------------------------------------------------+
void showLowHiLo(int index)
  {
   if(TrendBuffer[index]>0)
     {
      HiLoLowNoLineBuffer[index]=MaLowBuffer[index];

      if(InpShowHiLoLine)
         HiLoLowBuffer[index]=HiLoLowNoLineBuffer[index];

      if(InpArrowInCurrentCandle)
         HiLoCurrentLowBuffer[index]=HiLoLowNoLineBuffer[index];
     }
  }
//+------------------------------------------------------------------+
//| Include the arrow in the first HiLo if HiLo is changing the direction
//| of a sell/buy to buy/sell.
//+------------------------------------------------------------------+
void includeArrowInFirstHilo(int index)
  {
   if(!InpArrowInFirstHiLo)
      return;

   if(!isFirstHighHilo(index) && !isFirstLowHilo(index))
      return;
   else if(isFirstHighHilo(index))
      HiLoFirstHighBuffer[index]=HiLoHighNoLineBuffer[index];
   else
      HiLoFirstLowBuffer[index]=HiLoLowNoLineBuffer[index];
  }
//+------------------------------------------------------------------+
//| Include the arrow in the second HiLo if there is a First HiLo
//+------------------------------------------------------------------+
void includeArrowInSecondHilo(int index,double openValue)
  {
   if(!InpArrowInSecondHiLo)
      return;

   if(isSecondHighHilo(index))
      HiLoSecondHighBuffer[index]=openValue;

   if(isSecondLowHilo(index))
      HiLoSecondLowBuffer[index]=openValue;

  }
//+------------------------------------------------------------------+
//| Verify if the current index is the First High HiLo (Sell)                                                                 |
//+------------------------------------------------------------------+
bool isFirstHighHilo(int index)
  {
   if(HiLoHighNoLineBuffer[index+1]==EMPTY_VALUE && HiLoHighNoLineBuffer[index]!=EMPTY_VALUE)
      return true;
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Verify if the current index is the First Low HiLo (Buy)                                                                 |
//+------------------------------------------------------------------+
bool isFirstLowHilo(int index)
  {
   if(HiLoLowNoLineBuffer[index+1]==EMPTY_VALUE && HiLoLowNoLineBuffer[index]!=EMPTY_VALUE)
      return true;
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Verify if the current index is the Second candle of the First High HiLo (Sell)                                                                 |
//+------------------------------------------------------------------+
bool isSecondHighHilo(int index)
  {
   if(HiLoHighNoLineBuffer[index+2]==EMPTY_VALUE && HiLoHighNoLineBuffer[index+1]!=EMPTY_VALUE)
      return true;
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Verify if the current index is the Second candle of the First Low HiLo (Buy)                                                                |
//+------------------------------------------------------------------+
bool isSecondLowHilo(int index)
  {
   if(HiLoLowNoLineBuffer[index+2]==EMPTY_VALUE && HiLoLowNoLineBuffer[index+1]!=EMPTY_VALUE)
      return true;
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Verify if the time is on Current Candle or is still loading the History.
//+------------------------------------------------------------------+
bool isOnCurrentCandle(datetime timeCandle)
  {
// timeCandle can be 09:05. So plus PeriodSeconds to get 09:10
// since a currentTime can be 09:08
   int timePlusPeriod=int(timeCandle)+PeriodSeconds();
   int currentTime=int(TimeTradeServer());

   if(timePlusPeriod>=currentTime)
      return true;
   else
      return false;
  }
//+------------------------------------------------------------------+
