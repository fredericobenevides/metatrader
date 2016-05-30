//+------------------------------------------------------------------+
//|                                     Exp Panel HiLo Activator.mq5 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Frederico Benevides"
#property link      "fredbene@gmail.com"
#property version   "1.00"

#resource "\\Indicators\\HiLo MA Activator.ex5"

#include <PanelHiLoDialog.mqh>
#include <PanelHiLoLoader.mqh>
#include <PanelHiLoTrades.mqh>
#include <MyTrades.mqh>

//--- input parameters
input string         InpHiLoData="------------------------------";    // --------------- HiLo ---------------
input int            InpPeriod=1;                                     // Period
input ENUM_MA_METHOD InpMaMethod=MODE_SMMA;                           // Method
input bool           InpArrowInFirstHiLo=false;                       // Add an arrow to the first HiLo
input bool           InpArrowInSecondHiLo=true;                       // Add an arrow to the second HiLo
input bool           InpArrowInCurrentCandle=true;                    // Add an arrow to the current candle
input bool           InpShowHiLoLine=false;                           // Show the line of HiLo

//--- input parameters for  Moving Average
input string         InpCmaData="------------------------------";     // ---------- Moving Average ----------
input int            InpCmaPeriod=13;                                 // Period                     
input ENUM_MA_METHOD InpCmaMethod=MODE_SMA;                           // Method

//--- input parameters for Trades
input string          InpTradesData="------------------------------"; // --------------- Trades ---------------
input ENUM_TIMEFRAMES InpTradeTimeFrame=PERIOD_CURRENT;               // Default TimeFrame
input int             InpTradeVolume=1;                               // Default volume to do trades operations
input bool            InpSetTradeSound=false;                         // Play sound for each operation on Buy or Sell trades.
input string          InpSellTradeSound="dinkdink";                   // The Sound's name for Sell trade operations.
input string          InpBuyTradeSound="dingdong";                    // The Sound's name for Buy trade operations.


//--- global vars
int first_initialization=true; // flag indicate if is the first initialization

CPanelHiLoDialog PanelHiLoDialog;
CHiLoLoader HiLoLoader;
CHiLoTrades HiLoTrades;
CMyTrade myTrade;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create application dialog   

   if(first_initialization)
     {
      int y1=int(ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS)-200);
      int y2=int(ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS)-20);

      if(!PanelHiLoDialog.Create(0,"",0,20,y1,320,y2))
         return(INIT_FAILED);
      //--- run application

      if(!HiLoLoader.Init())
         return(INIT_FAILED);

      PanelHiLoDialog.Run();

      if(InpSetTradeSound)
         myTrade.enableSoundOnOperation(InpSellTradeSound,InpBuyTradeSound);
     }

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
//--- destroy dialog
   if(reason!=REASON_CHARTCHANGE)
     {
      PanelHiLoDialog.Destroy(reason);
      HiLoLoader.Destroy();

      first_initialization=true;
     }
   else
      first_initialization=false;

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   HiLoLoader.OnTick();
  }
//+------------------------------------------------------------------+
//| Expert chart event function                                      |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,         // event ID  
                  const long& lparam,   // event parameter of the long type
                  const double& dparam, // event parameter of the double type
                  const string& sparam) // event parameter of the string type
  {
   PanelHiLoDialog.ChartEvent(id,lparam,dparam,sparam);
  }
//+------------------------------------------------------------------+
