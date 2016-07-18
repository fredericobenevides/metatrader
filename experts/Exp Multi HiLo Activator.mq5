//+------------------------------------------------------------------+
//|                                     Exp Multi HiLo Activator.mq5 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Frederico Benevides"
#property link      "fredbene@gmail.com"
#property version   "1.00"

#resource "\\Indicators\\HiLo MA Activator.ex5"

//#include <MyLibs\HiLoMulti\HiLoMultiDialog.mqh>
//#include <MyLibs\HiLoMulti\HiLoMultiMALoader.mqh>
//#include <MyLibs\HiLoMulti\HiLoMultiTrades.mqh>
//#include <MyLibs\Trade\BreakEven.mqh>
//#include <MyLibs\Trade\MyTrade.mqh>
//#include <MyLibs\Utils\Time.mqh>

//#include <MyLibs\Test\Test.mqh>

#include <MyLibs\HiLoMulti\Models\HiLoMa.mqh>
#include <MyLibs\HiLoMulti\Controllers\HiLoController.mqh>

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
input double          InpTrade1StopLoss=50.0;                         // Default Stop Loss

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

CHiLoController HiLoController;
//CHiLoMultiDialog HiLoMultiDialog;
//CHiLoMultiMALoader HiLoMultiMALoader;
//CHiLoMultiTrades HiLoMultiTrades;
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
   if(first_initialization)
     {
      CHiLoMa *hiloMaTrade1 = new CHiLoMa();
      hiloMaTrade1.InitHiLoConfig(InpTrade1HiLoPeriod,InpTrade1HiLoMethod);
      hiloMaTrade1.InitMaConfig(InpTrade1MaPeriod,InpTrade1MaMethod);
      hiloMaTrade1.InitTradesConfig(InpTrade1Enabled, InpTrade1TimeFrame,
                                    InpTrade1Volume,InpTrade1MaxFactorOperations,
                                    InpTrade1TakeProfit,InpTrade1StopLoss);
      hiloMaTrade1.InitIndicatorHandleConfig(InpAllArrowInFirstHiLo,InpAllArrowInSecondHiLo,
                                             InpAllArrowInCurrentCandle,InpAllShowHiLoLine);

      HiLoController.AddModel(hiloMaTrade1);

      return HiLoController.InitAll();
     }

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(reason!=REASON_CHARTCHANGE)
     {
      HiLoController.Destroy(reason);
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
//   if(InpTestEnabled)
//      Test.RunEnvTest();
//
//HiLoMultiMALoader.OnTick();
   HiLoController.OnTick();
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
