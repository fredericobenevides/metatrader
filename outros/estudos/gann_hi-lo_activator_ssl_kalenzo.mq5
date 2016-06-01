//+------------------------------------------------------------------+
//|                                     Gann_Hi-lo_Activator_SSL.mq5 |
//|                                        Copyright © 2007, Kalenzo |
//|                                      bartlomiej.gorski@gmail.com |                                      
//+------------------------------------------------------------------+
//---- Copyright
#property copyright "Copyright © 2007, Kalenzo"
//---- link to the website of the author
#property link      "bartlomiej.gorski@gmail.com"
//---- Indicator version number
#property version   "1.00"
//---- Drawing the indicator in the main window
#property indicator_chart_window
//---- 4 buffers are used for calculation and drawing the indicator
#property indicator_buffers 4
//---- 4 plots are used
#property indicator_plots   4
//+----------------------------------------------+
//|  Bullish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing indicator 1 as a line
#property indicator_type1   DRAW_LINE
//---- MediumTurquoise is used for the color of the indicator line
#property indicator_color1  clrMediumTurquoise
//---- Indicator line is a solid one
#property indicator_style1  STYLE_SOLID
//---- indicator 1 line width is equal to 2
#property indicator_width1  2
//---- displaying of the the indicator label
#property indicator_label1  "Upper Gann_Hi-lo_Activator_SSL"
//+----------------------------------------------+
//|  Parameters of drawing the bearish indicator |
//+----------------------------------------------+
//---- dawing the indicator 2 as a line
#property indicator_type2   DRAW_LINE
//---- MediumOrchid color is used for the indicator line
#property indicator_color2  clrMediumOrchid
//---- Indicator line is a solid one
#property indicator_style2  STYLE_SOLID
//---- indicator 2 line width is equal to 2
#property indicator_width2  2
//---- displaying of the the indicator label
#property indicator_label2  "Lower Gann_Hi-lo_Activator_SSL"
//+----------------------------------------------+
//|  Bullish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 3 as a label
#property indicator_type3   DRAW_ARROW
//---- DeepSkyBlue color is used for the indicator
#property indicator_color3  clrDeepSkyBlue
//---- indicator 3 width is equal to 4
#property indicator_width3  4
//---- displaying the indicator label
#property indicator_label3  "Buy Gann_Hi-lo_Activator_SSL"
//+----------------------------------------------+
//|  Parameters of drawing the bearish indicator |
//+----------------------------------------------+
//---- drawing the indicator 4 as a label
#property indicator_type4   DRAW_ARROW
//---- DarkOrange color is used for the indicator line
#property indicator_color4  clrDarkOrange
//---- indicator 4 width is equal to 4
#property indicator_width4  4
//---- displaying the indicator label
#property indicator_label4  "Sell Gann_Hi-lo_Activator_SSL"
//+----------------------------------------------+
//|  declaring constants                         |
//+----------------------------------------------+
#define RESET  0 // the constant for getting the command for the indicator recalculation back to the terminal
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input uint              MAPeriod=13;
input  ENUM_MA_METHOD   MAType=MODE_EMA;
input int               Shift=0;             // Horizontal shift of the indicator in bars
//+----------------------------------------------+
//---- declaration of dynamic arrays that
//---- will be used as indicator buffers
double ExtMapBufferUp[];
double ExtMapBufferDown[];
double ExtMapBufferUp1[];
double ExtMapBufferDown1[];
//---- declaration of integer variables for indicators handles
int HMA_Handle,LMA_Handle;
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- getting handle of the MA indicator
   HMA_Handle=iMA(NULL,0,MAPeriod,0,MAType,PRICE_HIGH);
   if(HMA_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get the handle of MA");
      return(1);
     }

   LMA_Handle=iMA(NULL,0,MAPeriod,0,MAType,PRICE_LOW);
   if(LMA_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get the handle of MA");
      return(1);
     }

//---- Initialization of variables of the start of data calculation
   min_rates_total=int(MAPeriod+1);

//---- Set ExtMapBufferUp[] dynamic array as an indicator buffer
   SetIndexBuffer(0,ExtMapBufferUp,INDICATOR_DATA);
//---- shifting the indicator 1 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- Shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing the elements in buffers as time series   
   ArraySetAsSeries(ExtMapBufferUp,true);
//---- Setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- Set ExtMapBufferDown[] dynamic array as an indicator buffer
   SetIndexBuffer(1,ExtMapBufferDown,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- shifting the starting point of calculation of drawing of the indicator 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing the elements in buffers as time series   
   ArraySetAsSeries(ExtMapBufferDown,true);
//---- Setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- Set ExtMapBufferUp1[] dynamic array as an indicator buffer
   SetIndexBuffer(2,ExtMapBufferUp1,INDICATOR_DATA);
//---- shifting the indicator 1 horizontally by Shift
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- shifting the start of drawing of the indicator 3
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing the elements in buffers as time series   
   ArraySetAsSeries(ExtMapBufferUp1,true);
//---- Setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indicator symbol
   PlotIndexSetInteger(2,PLOT_ARROW,167);

//---- Set ExtMapBufferDown1[] dynamic array as an indicator buffer
   SetIndexBuffer(3,ExtMapBufferDown1,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
//---- shifting the start of drawing of the indicator 4
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing the elements in buffers as time series   
   ArraySetAsSeries(ExtMapBufferDown1,true);
//---- Setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indicator symbol
   PlotIndexSetInteger(3,PLOT_ARROW,167);

//---- Initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"Gann_Hi-lo_Activator_SSL(",MAPeriod,", ",EnumToString(MAType),", ",Shift,")");
//--- Creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- Determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double& high[],     // price array of price maximums for the indicator calculation
                const double& low[],      // price array of minimums of price for the indicator calculation
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- checking the number of bars to be enough for the calculation
   if(BarsCalculated(HMA_Handle)<rates_total
      || BarsCalculated(LMA_Handle)<rates_total
      || rates_total<min_rates_total)
      return(RESET);

//---- declaration of local variables 
   double HMA[],LMA[],Hld,Hlv;
   int limit,to_copy,bar;
   static double Hlv_;

//---- Indexing elements in arrays as time series  
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(HMA,true);
   ArraySetAsSeries(LMA,true);

//---- calculation of the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
     {
      limit=rates_total-min_rates_total-1;               // starting index for calculation of all bars
      Hlv_=0;
     }
   else
     {
      limit=rates_total-prev_calculated;                 // starting index for calculation of new bars
     }

   to_copy=int(limit+2);
//---- copy newly appeared data into the arrays
   if(CopyBuffer(HMA_Handle,0,0,to_copy,HMA)<=0) return(RESET);
   if(CopyBuffer(LMA_Handle,0,0,to_copy,LMA)<=0) return(RESET);
   
   Hlv=Hlv_;

//---- The main loop of the indicator calculation
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      ExtMapBufferUp[bar]=EMPTY_VALUE;
      ExtMapBufferDown[bar]=EMPTY_VALUE;
      ExtMapBufferUp1[bar]=EMPTY_VALUE;
      ExtMapBufferDown1[bar]=EMPTY_VALUE;
      
      if(close[bar]>HMA[bar+1]) Hld=+1;
      else if(close[bar]<LMA[bar+1]) Hld=-1;
      else Hld=0;
      
      if(Hld) Hlv=Hld;
      
      if(Hlv>0) ExtMapBufferUp[bar]=LMA[bar+1];
      if(Hlv<0) ExtMapBufferDown[bar]=HMA[bar+1];
      
      if(bar) Hlv_=Hlv;

      if(ExtMapBufferUp[bar+1]==EMPTY_VALUE && ExtMapBufferUp[bar]!=EMPTY_VALUE) ExtMapBufferUp1[bar]=ExtMapBufferUp[bar];
      if(ExtMapBufferDown[bar+1]==EMPTY_VALUE && ExtMapBufferDown[bar]!=EMPTY_VALUE) ExtMapBufferDown1[bar]=ExtMapBufferDown[bar];
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
