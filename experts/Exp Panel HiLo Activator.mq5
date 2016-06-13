//+------------------------------------------------------------------+
//|                                     Exp Panel HiLo Activator.mq5 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Frederico Benevides"
#property link      "fredbene@gmail.com"
#property version   "2.00"

#resource "\\Indicators\\HiLo MA Activator.ex5"

#include <MyLibs\HiLo\HiLoDialog.mqh>
#include <MyLibs\HiLo\HiLoMALoader.mqh>
#include <MyLibs\HiLo\HiLoTrades.mqh>
#include <MyLibs\Trade\BreakEven.mqh>
#include <MyLibs\Trade\MyTrade.mqh>
#include <MyLibs\Utils\Time.mqh>

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
input double          InpTradeVolumeFactor=2;                         // Default trade factor (martingale)
input bool            InpTradeVolumeFactorBreakEvenEnabled=true;      // Default to enable calculation based on breakeven points
input double          InpTradeVolumeFactorBreakEvenPoints=50;         // Volume Factor calculation on breakeven points
input double          InpTradeTakeProfit=200.0;                       // Default Take Profit
input double          InpTradeStopLoss=0.0;                           // Default Stop Loss
input double          InpTradePricePerVolume=0;                       // Default Price Per Volume
//--- input parameters for Trades Sound
input string          InpTradesSoundData="------------------------------"; // ------------ Trades Sound ------------
input bool            InpSetTradeSound=false;                         // Play sound for each operation on Buy or Sell trades.
input string          InpSellTradeSound="dinkdink";                   // The Sound's name for Sell trade operations.
input string          InpBuyTradeSound="dingdong";                    // The Sound's name for Buy trade operations.

//--- input parameters for Time Control
input string          InpTimeControlData="-------------------------"; // --------------- Time Control ---------------
input bool            InpTimeEnabled=true;                            // Enable the Time Control
input string          InpTimeStart="09:30";                           // Default time to start the operation
input string          InpTimeEnd="18:00";                             // Default time to end the operation

//--- global vars
int first_initialization=true; // flag indicate if is the first initialization

CHiLoDialog HiLoDialog;
CHiLoMALoader HiLoMALoader;
CHiLoTrades HiLoTrades;
CBreakEven BreakEven;
CMyTrade MyTrade;
CTime Time;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create application dialog   

   if(first_initialization)
     {
      int y1=int(ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS)-250);
      int y2=int(ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS)-20);

      if(!HiLoDialog.Create(0,"",0,20,y1,335,y2))
         return(INIT_FAILED);
      //--- run application

      if(!HiLoMALoader.Init())
         return(INIT_FAILED);

      HiLoDialog.Run();

      if(InpSetTradeSound)
         MyTrade.EnableSoundOnOperation(InpSellTradeSound,InpBuyTradeSound);
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
      HiLoDialog.Destroy(reason);
      HiLoMALoader.Destroy();

      first_initialization=true;
     }
   else
      first_initialization=false;

// hide breakEven
   BreakEven.Hide();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   HiLoMALoader.OnTick();
  }
//+------------------------------------------------------------------+
//| Expert chart event function                                      |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,         // event ID  
                  const long& lparam,   // event parameter of the long type
                  const double& dparam, // event parameter of the double type
                  const string& sparam) // event parameter of the string type
  {
   HiLoDialog.ChartEvent(id,lparam,dparam,sparam);
  }
//+------------------------------------------------------------------+
//| Event onTradeTransaction to find a trade runned by a Take Profit or Stop Loss
//+------------------------------------------------------------------+
void OnTradeTransaction(
                        const MqlTradeTransaction& trans,        // trade transaction structure
                        const MqlTradeRequest&     request,      // request structure
                        const MqlTradeResult&      result        // result structure
                        )
  {
   HiLoTrades.OnTradeTransaction(trans.type);
  }
//+------------------------------------------------------------------+
