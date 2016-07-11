//+------------------------------------------------------------------+
//|                                     Exp Multi HiLo Activator.mq5 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Frederico Benevides"
#property link      "fredbene@gmail.com"
#property version   "2.00"

#resource "\\Indicators\\HiLo MA Activator.ex5"

#include <MyLibs\HiLoMulti\HiLoMultiDialog.mqh>
#include <MyLibs\HiLoMulti\HiLoMultiMALoader.mqh>
#include <MyLibs\HiLoMulti\HiLoMultiTrades.mqh>
//#include <MyLibs\Trade\BreakEven.mqh>
//#include <MyLibs\Trade\MyTrade.mqh>
//#include <MyLibs\Utils\Time.mqh>

//#include <MyLibs\Test\Test.mqh>

//--- input parameters for All Trades
input string          InpAllData="------------------------------";    // --------------- Trade Configs for All Trades ---------------
input double          InpAllVolumeMartingale=2;                       // Default trade martingale for all trades

input string          InpAllHiLoData="------------------------------"; // --------------- Trade HiLo Config for All Trades ---------------
input bool            InpAllArrowInFirstHiLo=true;                    // Add an arrow to the first HiLo
input bool            InpAllArrowInSecondHiLo=true;                   // Add an arrow to the second HiLo
input bool            InpAllArrowInCurrentCandle=true;                // Add an arrow to the current candle
input bool            InpAllShowHiLoLine=false;                       // Show the line of HiLo

//--- input parameters for Trade 1 (Trade Config)
input string          InpTrade1Data="------------------------------"; // --------------- Trade 1 (Trade Config) ---------------
input bool            InpTrade1Enabled=true;                          // Default to true to enable the Trade 1
input ENUM_TIMEFRAMES InpTrade1TimeFrame=PERIOD_CURRENT;              // Default TimeFrame for Trade 1
input double          InpTrade1Volume=5;                              // Default volume to do trades operations
input int             InpTrade1MaxFactorOperations=5;                 // Default max operations (Martingale^MaxOperations)*InitialVolume
input double          InpTrade1TakeProfit=200.0;                      // Default Take Profit

//--- input parameters for Trade 1 (HiLo and Ma Config)
input string          InpTrade1HiLoMaData="------------------------------"; // --------------- Trade 1 (HiLo Config) ---------------
input int             InpTrade1HiLoPeriod=2;                          // HiLo Period
input ENUM_MA_METHOD  InpTrade1HiLoMethod=MODE_SMMA;                  // HiLo Method
input int             InpTrade1MaPeriod=8;                            // Ma Period                     
input ENUM_MA_METHOD  InpTrade1MaMethod=MODE_SMA;                     // Ma Method

//--- input parameters for All Trades Sound
input string          InpAllTradesSoundData="------------------------------"; // ------------ Trades Sound ------------
input bool            InpAllSetTradeSound=false;                       // Play sound for each operation on Buy or Sell trades.
input string          InpAllSellTradeSound="dinkdink";                 // The Sound's name for Sell trade operations.
input string          InpAllBuyTradeSound="dingdong";                   // The Sound's name for Buy trade operations.

//--- input parameters for Test
input string          InpTestData="-------------------------";        // --------------- Test ---------------
input bool            InpTestEnabled=false;                           // Enable operation for test environment
input bool            InpGenerateReport=false;                        // Generate the file test.csv on tester folder

//--- global vars
int first_initialization=true; // flag indicate if is the first initialization

CHiLoMultiDialog HiLoMultiDialog;
CHiLoMultiMALoader HiLoMultiMALoader;
CHiLoMultiTrades HiLoMultiTrades;
//CBreakEven BreakEven;
//CMyTrade MyTrade;
//CTime Time;

//--- global vars for test
//CTest Test;
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

      //if(!HiLoMultiDialog.Create(0,"",0,20,y1,335,y2))
      if(!HiLoMultiDialog.Create(0,"",0,20,y1,440,y2))
         return(INIT_FAILED);
      //--- run application

      //if(!HiLoMALoader.Init())
      //   return(INIT_FAILED);

      HiLoMultiDialog.Run();

      //if(InpAllSetTradeSound)
      //   MyTrade.EnableSoundOnOperation(InpAllSellTradeSound,InpAllBuyTradeSound);
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
      HiLoMultiDialog.Destroy(reason);
      //HiLoMALoader.Destroy();

      first_initialization=true;
     }
   else
      first_initialization=false;

// hide breakEven
//BreakEven.Hide();

// Generate the history report
//if(InpGenerateReport)
//   Test.HistoryReport();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//   if(InpTestEnabled)
//      Test.RunEnvTest();
//
   HiLoMultiMALoader.OnTick();
  }
//+------------------------------------------------------------------+
//| Expert chart event function                                      |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,         // event ID  
                  const long& lparam,   // event parameter of the long type
                  const double& dparam, // event parameter of the double type
                  const string& sparam) // event parameter of the string type
  {
//HiLoDialog.ChartEvent(id,lparam,dparam,sparam);
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
//HiLoTrades.OnTradeTransaction(trans.type);
  }
//+------------------------------------------------------------------+
