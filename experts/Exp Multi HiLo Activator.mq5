//+------------------------------------------------------------------+
//|                                     Exp Multi HiLo Activator.mq5 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Frederico Benevides"
#property link      "fredbene@gmail.com"
#property version   "1.00"

#resource "\\Indicators\\HiLo MA Activator.ex5"

#include <MyLibs\Trades\TradesController.mqh>

#include <MyLibs\HiLoMulti\Models\HiLoMaHandle.mqh>
#include <MyLibs\HiLoMulti\Controllers\HiLoController.mqh>

#include <MyLibs\Test\HiLoMultiTest.mqh>

#include <MyLibs\Utils\Logger.mqh>


//--- input parameters for All Trades
input string          InpAllHiLoData="------------------------------"; // ------- Trade HiLo Config for All Trades -------
input bool            InpAllArrowInFirstHiLo=true;                    // Add an arrow to the first HiLo
input bool            InpAllArrowInSecondHiLo=true;                   // Add an arrow to the second HiLo
input bool            InpAllArrowInCurrentCandle=true;                // Add an arrow to the current candle
input bool            InpAllShowHiLoLine=false;                       // Show the line of HiLo

//--- input parameters for All Trades Sound
input string          InpAllTradesSoundData="------------------------------"; // -------------- Trades Sound --------------
input bool            InpAllSetTradeSound=false;                        // Play sound for each operation on Buy or Sell trades.
input string          InpAllSellTradeSound="dinkdink";                  // The Sound's name for Sell trade operations.
input string          InpAllBuyTradeSound="dingdong";                   // The Sound's name for Buy trade operations.




//--- input parameters for Trade 1 (Trade Config)
input string          InpTrade1Data="------------------------------"; // ------- Trade 1 (Trade's Config) -------
input bool            InpTrade1Enabled=false;                          // Default to true to enable the Trade
input ENUM_TIMEFRAMES InpTrade1TimeFrame=PERIOD_M5;                   // Default TimeFrame for Trade
input double          InpTrade1Volume=1;                              // Default volume to do trades operations
input double          InpTrade1TakeProfit=120.0;                      // Default Take Profit (0 disable)
input int             InpTrade1MaxTakeProfit=1;                       // Default Max Take Profit  (0 disable)
input double          InpTrade1StopLoss=200;                            // Default Stop Loss  (0 disable)
input int             InpTrade1MaxStopLoss=0;                         // Default Max Stop Loss  (0 disable)
input int             InpTrade1StopLossProfile=0;                     // Default Stop Loss Profile (0 disable)
input int             InpTrade1Martingale=2;                          // Default trade martingale for all trades
input int             InpTrade1MaxMartingaleOperations=5;             // Default max operations  (0 disable)

//--- input parameters for Trade 1 (HiLo and Ma Config)
input string          InpTrade1HiLoMaData="------------------------------"; // ------- Trade 1 (HiLo Config) -------
input int             InpTrade1HiLoPeriod=4;                          // HiLo Period
input ENUM_MA_METHOD  InpTrade1HiLoMethod=MODE_SMMA;                  // HiLo Method
input int             InpTrade1MaPeriod=6;                           // Ma Period                     
input ENUM_MA_METHOD  InpTrade1MaMethod=MODE_SMA;                     // Ma Method

//--- input parameters for Trade 1 (Time Control)
input string          InpTrade1TimeControlData="-------------------------"; // ------- Trade 1 (Time Control) -------
input int             InpTrade1TimeStartHour=9;                       // Default hour time to start the operation
input int             InpTrade1TimeStartMinute=5;                     // Default minute time to start the operation
input int             InpTrade1TimeEndHour=12;                        // Default hour time to end the operation
input int             InpTrade1TimeEndMinute=0;                       // Default minute time to end the operation
input string          InpTrade1EndData="------------------------------"; // ------- End of Trade 1 -------

//--- input parameters for Trade 2 (Trade Config)
input string          InpTrade2Data="------------------------------"; // ------- Trade 2 (Trade's Config) -------
input bool            InpTrade2Enabled=false;                          // Default to true to enable the Trade
input ENUM_TIMEFRAMES InpTrade2TimeFrame=PERIOD_M5;                   // Default TimeFrame for Trade
input double          InpTrade2Volume=1;                              // Default volume to do trades operations
input double          InpTrade2TakeProfit=110.0;                      // Default Take Profit (0 disable)
input int             InpTrade2MaxTakeProfit=2;                       // Default Max Take Profit  (0 disable)
input double          InpTrade2StopLoss=0;                            // Default Stop Loss  (0 disable)
input int             InpTrade2MaxStopLoss=0;                         // Default Max Stop Loss  (0 disable)
input int             InpTrade2StopLossProfile=0;                     // Default Stop Loss Profile (0 disable)
input int             InpTrade2Martingale=2;                          // Default trade martingale for all trades
input int             InpTrade2MaxMartingaleOperations=5;             // Default max operations  (0 disable)

//--- input parameters for Trade 2 (HiLo and Ma Config)
input string          InpTrade2HiLoMaData="------------------------------"; // ------- Trade 2 (HiLo Config) -------
input int             InpTrade2HiLoPeriod=4;                          // HiLo Period
input ENUM_MA_METHOD  InpTrade2HiLoMethod=MODE_SMMA;                  // HiLo Method
input int             InpTrade2MaPeriod=17;                           // Ma Period                     
input ENUM_MA_METHOD  InpTrade2MaMethod=MODE_SMA;                     // Ma Method

//--- input parameters for Trade 2 (Time Control)
input string          InpTrade2TimeControlData="-------------------------"; // ------- Trade 2 (Time Control) -------
input int             InpTrade2TimeStartHour=9;                       // Default hour time to start the operation
input int             InpTrade2TimeStartMinute=5;                     // Default minute time to start the operation
input int             InpTrade2TimeEndHour=12;                        // Default hour time to end the operation
input int             InpTrade2TimeEndMinute=0;                       // Default minute time to end the operation
input string          InpTrade2EndData="------------------------------"; // ------- End of Trade 2 -------

//--- input parameters for Trade 3 (Trade Config)
input string          InpTrade3Data="------------------------------"; // ------- Trade 3 (Trade's Config) -------
input bool            InpTrade3Enabled=true;                          // Default to true to enable the Trade
input ENUM_TIMEFRAMES InpTrade3TimeFrame=PERIOD_M5;                   // Default TimeFrame for Trade
input double          InpTrade3Volume=2;                              // Default volume to do trades operations
input double          InpTrade3TakeProfit=50.0;                       // Default Take Profit (0 disable)
input int             InpTrade3MaxTakeProfit=2;                       // Default Max Take Profit  (0 disable)
input double          InpTrade3StopLoss=100;                            // Default Stop Loss  (0 disable)
input int             InpTrade3MaxStopLoss=0;                         // Default Max Stop Loss  (0 disable)
input int             InpTrade3StopLossProfile=0;                     // Default Stop Loss Profile (0 disable)
input int             InpTrade3Martingale=2;                          // Default trade martingale for all trades
input int             InpTrade3MaxMartingaleOperations=5;             // Default max operations  (0 disable)

//--- input parameters for Trade 3 (HiLo and Ma Config)
input string          InpTrade3HiLoMaData="------------------------------"; // ------- Trade 3 (HiLo Config) -------
input int             InpTrade3HiLoPeriod=2;                          // HiLo Period
input ENUM_MA_METHOD  InpTrade3HiLoMethod=MODE_SMMA;                   // HiLo Method
input int             InpTrade3MaPeriod=6;                            // Ma Period                     
input ENUM_MA_METHOD  InpTrade3MaMethod=MODE_SMA;                     // Ma Method

//--- input parameters for Trade 3 (Time Control)
input string          InpTrade3TimeControlData="-------------------------"; // ------- Trade 3 (Time Control) -------
input int             InpTrade3TimeStartHour=14;                       // Default hour time to start the operation
input int             InpTrade3TimeStartMinute=0;                      // Default minute time to start the operation
input int             InpTrade3TimeEndHour=16;                         // Default hour time to end the operation
input int             InpTrade3TimeEndMinute=30;                        // Default minute time to end the operation
input string          InpTrade3EndData="------------------------------"; // ------- End of Trade 3 -------

//--- input parameters for Trade 4 (Trade Config)
input string          InpTrade4Data="------------------------------"; // ------- Trade 4 (Trade's Config) -------
input bool            InpTrade4Enabled=true;                          // Default to true to enable the Trade
input ENUM_TIMEFRAMES InpTrade4TimeFrame=PERIOD_M5;                   // Default TimeFrame for Trade
input double          InpTrade4Volume=3;                              // Default volume to do trades operations
input double          InpTrade4TakeProfit=150.0;                      // Default Take Profit (0 disable)
input int             InpTrade4MaxTakeProfit=1;                       // Default Max Take Profit  (0 disable)
input double          InpTrade4StopLoss=180;                            // Default Stop Loss  (0 disable)
input int             InpTrade4MaxStopLoss=0;                         // Default Max Stop Loss  (0 disable)
input int             InpTrade4StopLossProfile=1;                     // Default Stop Loss Profile (0 disable)
input int             InpTrade4Martingale=2;                          // Default trade martingale for all trades
input int             InpTrade4MaxMartingaleOperations=5;             // Default max operations  (0 disable)

//--- input parameters for Trade 4 (HiLo and Ma Config)
input string          InpTrade4HiLoMaData="------------------------------"; // ------- Trade 4 (HiLo Config) -------
input int             InpTrade4HiLoPeriod=4;                          // HiLo Period
input ENUM_MA_METHOD  InpTrade4HiLoMethod=MODE_SMMA;                  // HiLo Method
input int             InpTrade4MaPeriod=6;                            // Ma Period                     
input ENUM_MA_METHOD  InpTrade4MaMethod=MODE_SMA;                     // Ma Method

//--- input parameters for Trade 4 (Time Control)
input string          InpTrade4TimeControlData="-------------------------"; // ------- Trade 4 (Time Control) -------
input int             InpTrade4TimeStartHour=9;                        // Default hour time to start the operation
input int             InpTrade4TimeStartMinute=5;                     // Default minute time to start the operation
input int             InpTrade4TimeEndHour=16;                         // Default hour time to end the operation
input int             InpTrade4TimeEndMinute=0;                        // Default minute time to end the operation
input string          InpTrade4EndData="------------------------------"; // ------- End of Trade 4 -------

//--- input parameters for Trade 5 (Trade Config)
input string          InpTrade5Data="------------------------------"; // ------- Trade 5 (Trade's Config) -------
input bool            InpTrade5Enabled=true;                          // Default to true to enable the Trade
input ENUM_TIMEFRAMES InpTrade5TimeFrame=PERIOD_M5;                   // Default TimeFrame for Trade
input double          InpTrade5Volume=2;                              // Default volume to do trades operations
input double          InpTrade5TakeProfit=50.0;                      // Default Take Profit (0 disable)
input int             InpTrade5MaxTakeProfit=5;                       // Default Max Take Profit  (0 disable)
input double          InpTrade5StopLoss=100;                            // Default Stop Loss  (0 disable)
input int             InpTrade5MaxStopLoss=0;                         // Default Max Stop Loss  (0 disable)
input int             InpTrade5StopLossProfile=0;                     // Default Stop Loss Profile (0 disable)
input int             InpTrade5Martingale=2;                          // Default trade martingale for all trades
input int             InpTrade5MaxMartingaleOperations=5;             // Default max operations  (0 disable)

//--- input parameters for Trade 5 (HiLo and Ma Config)
input string          InpTrade5HiLoMaData="------------------------------"; // ------- Trade 5 (HiLo Config) -------
input int             InpTrade5HiLoPeriod=4;                          // HiLo Period
input ENUM_MA_METHOD  InpTrade5HiLoMethod=MODE_SMMA;                  // HiLo Method
input int             InpTrade5MaPeriod=6;                            // Ma Period                     
input ENUM_MA_METHOD  InpTrade5MaMethod=MODE_SMA;                     // Ma Method

//--- input parameters for Trade 5 (Time Control)
input string          InpTrade5TimeControlData="-------------------------"; // ------- Trade 5 (Time Control) -------
input int             InpTrade5TimeStartHour=10;                       // Default hour time to start the operation
input int             InpTrade5TimeStartMinute=0;                     // Default minute time to start the operation
input int             InpTrade5TimeEndHour=12;                         // Default hour time to end the operation
input int             InpTrade5TimeEndMinute=50;                        // Default minute time to end the operation
input string          InpTrade5EndData="------------------------------"; // ------- End of Trade 5 -------

//--- input parameters for Test
input string          InpTestData="-------------------------";        // -------------- Test --------------
input bool            InpTestGenerateReport=false;                    // Generate the file test.csv on tester folder

//--- global vars
int first_initialization=true; // flag indicate if is the first initialization
datetime last_day_initialized=TimeTradeServer();

CHiLoController *HiLoController;
CLogger Logger;

//--- global vars for test
CHiLoMultiTest Test;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   Logger.SetSetting("HiLoMulti","myLog","Comment",60);
   Logger.Init();
   Logger.Write("Initting log");

   if(first_initialization)
      return InitConfigsForAllTrades();

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
      delete HiLoController;

      first_initialization=true;
     }
   else
      first_initialization=false;

// Generate the history report
   if(InpTestGenerateReport)
      Test.HistoryReport();

   ChartRedraw();

   Logger.DeInit();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   verifyIfAnotherDayToReloadTrades();

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
   HiLoController.OnChartEvent(id,lparam,dparam,sparam);
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
   HiLoController.OnTradeTransaction(trans,request,result);
  }
//+------------------------------------------------------------------+
//| Verify if is aother day to reaload all configs
//+------------------------------------------------------------------+
void verifyIfAnotherDayToReloadTrades()
  {
   datetime ts=TimeTradeServer();
   MqlDateTime sts;
   TimeToStruct(ts,sts);

   MqlDateTime ldi;
   TimeToStruct(last_day_initialized,ldi);

   if(sts.year>ldi.year || sts.mon>ldi.mon || sts.day>ldi.day)
     {
      last_day_initialized=ts;
      HiLoController.ReInitTradesToDefault();
     }
  }
//+------------------------------------------------------------------+
//| Init config for all trades
//+------------------------------------------------------------------+
int InitConfigsForAllTrades()
  {
   HiLoController=new CHiLoController();

   InitConfigsForTrade1();
   InitConfigsForTrade2();
   InitConfigsForTrade3();
   InitConfigsForTrade4();
   InitConfigsForTrade5();

   if(InpAllSetTradeSound)
      HiLoController.InitTradeSound(InpAllSellTradeSound,InpAllBuyTradeSound);

   return HiLoController.InitAll();
  }
//+------------------------------------------------------------------+
//| Init configs for trade 1
//+------------------------------------------------------------------+
void InitConfigsForTrade1()
  {
   CHiLoMaHandle *hiloMaTrade1=new CHiLoMaHandle();
   hiloMaTrade1.InitHiLoConfig(InpTrade1HiLoPeriod,InpTrade1HiLoMethod);
   hiloMaTrade1.InitMaConfig(InpTrade1MaPeriod,InpTrade1MaMethod);
   hiloMaTrade1.InitIndicatorHandleConfig(InpTrade1TimeFrame,
                                          InpAllArrowInFirstHiLo,InpAllArrowInSecondHiLo,
                                          InpAllArrowInCurrentCandle,InpAllShowHiLoLine);

   CTradesController *tradesController=new CTradesController("T1");
   tradesController.InitTrade(InpTrade1Enabled,InpTrade1Volume,InpTrade1TakeProfit,InpTrade1MaxTakeProfit,
                              InpTrade1StopLoss,InpTrade1StopLossProfile);
   tradesController.InitMartingale(InpTrade1Martingale,InpTrade1MaxMartingaleOperations);
   tradesController.InitTradesTime(InpTrade1TimeStartHour,InpTrade1TimeStartMinute,
                                   InpTrade1TimeEndHour,InpTrade1TimeEndMinute);

   hiloMaTrade1.AddTradesController(tradesController);
   HiLoController.AddModel(hiloMaTrade1);
  }
//+------------------------------------------------------------------+
//| Init configs for trade 2
//+------------------------------------------------------------------+
void InitConfigsForTrade2()
  {
   CHiLoMaHandle *hiloMaTrade2=new CHiLoMaHandle();
   hiloMaTrade2.InitHiLoConfig(InpTrade2HiLoPeriod,InpTrade2HiLoMethod);
   hiloMaTrade2.InitMaConfig(InpTrade2MaPeriod,InpTrade2MaMethod);
   hiloMaTrade2.InitIndicatorHandleConfig(InpTrade2TimeFrame,
                                          InpAllArrowInFirstHiLo,InpAllArrowInSecondHiLo,
                                          InpAllArrowInCurrentCandle,InpAllShowHiLoLine);

   CTradesController *tradesController=new CTradesController("T2");
   tradesController.InitTrade(InpTrade2Enabled,InpTrade2Volume,InpTrade2TakeProfit,InpTrade2MaxTakeProfit,
                              InpTrade2StopLoss,InpTrade2StopLossProfile);
   tradesController.InitMartingale(InpTrade2Martingale,InpTrade2MaxMartingaleOperations);
   tradesController.InitTradesTime(InpTrade2TimeStartHour,InpTrade2TimeStartMinute,
                                   InpTrade2TimeEndHour,InpTrade2TimeEndMinute);

   hiloMaTrade2.AddTradesController(tradesController);
   HiLoController.AddModel(hiloMaTrade2);
  }
//+------------------------------------------------------------------+
//| Init configs for trade 3
//+------------------------------------------------------------------+
void InitConfigsForTrade3()
  {
   CHiLoMaHandle *hiloMaTrade3=new CHiLoMaHandle();
   hiloMaTrade3.InitHiLoConfig(InpTrade3HiLoPeriod,InpTrade3HiLoMethod);
   hiloMaTrade3.InitMaConfig(InpTrade3MaPeriod,InpTrade3MaMethod);
   hiloMaTrade3.InitIndicatorHandleConfig(InpTrade3TimeFrame,
                                          InpAllArrowInFirstHiLo,InpAllArrowInSecondHiLo,
                                          InpAllArrowInCurrentCandle,InpAllShowHiLoLine);

   CTradesController *tradesController=new CTradesController("T3");
   tradesController.InitTrade(InpTrade3Enabled,InpTrade3Volume,InpTrade3TakeProfit,InpTrade3MaxTakeProfit,
                              InpTrade3StopLoss,InpTrade3StopLossProfile);
   tradesController.InitMartingale(InpTrade3Martingale,InpTrade3MaxMartingaleOperations);
   tradesController.InitTradesTime(InpTrade3TimeStartHour,InpTrade3TimeStartMinute,
                                   InpTrade3TimeEndHour,InpTrade3TimeEndMinute);

   hiloMaTrade3.AddTradesController(tradesController);
   HiLoController.AddModel(hiloMaTrade3);
  }
//+------------------------------------------------------------------+
//| Init configs for trade 4
//+------------------------------------------------------------------+
void InitConfigsForTrade4()
  {
   CHiLoMaHandle *hiloMaTrade4=new CHiLoMaHandle();
   hiloMaTrade4.InitHiLoConfig(InpTrade4HiLoPeriod,InpTrade4HiLoMethod);
   hiloMaTrade4.InitMaConfig(InpTrade4MaPeriod,InpTrade4MaMethod);
   hiloMaTrade4.InitIndicatorHandleConfig(InpTrade4TimeFrame,
                                          InpAllArrowInFirstHiLo,InpAllArrowInSecondHiLo,
                                          InpAllArrowInCurrentCandle,InpAllShowHiLoLine);

   CTradesController *tradesController=new CTradesController("T4");
   tradesController.InitTrade(InpTrade4Enabled,InpTrade4Volume,InpTrade4TakeProfit,InpTrade4MaxTakeProfit,
                              InpTrade4StopLoss,InpTrade4StopLossProfile);
   tradesController.InitMartingale(InpTrade4Martingale,InpTrade4MaxMartingaleOperations);
   tradesController.InitTradesTime(InpTrade4TimeStartHour,InpTrade4TimeStartMinute,
                                   InpTrade4TimeEndHour,InpTrade4TimeEndMinute);

   hiloMaTrade4.AddTradesController(tradesController);
   HiLoController.AddModel(hiloMaTrade4);
  }
//+------------------------------------------------------------------+
//| Init configs for trade 5
//+------------------------------------------------------------------+
void InitConfigsForTrade5()
  {
   CHiLoMaHandle *hiloMaTrade5=new CHiLoMaHandle();
   hiloMaTrade5.InitHiLoConfig(InpTrade5HiLoPeriod,InpTrade5HiLoMethod);
   hiloMaTrade5.InitMaConfig(InpTrade5MaPeriod,InpTrade5MaMethod);
   hiloMaTrade5.InitIndicatorHandleConfig(InpTrade5TimeFrame,
                                          InpAllArrowInFirstHiLo,InpAllArrowInSecondHiLo,
                                          InpAllArrowInCurrentCandle,InpAllShowHiLoLine);

   CTradesController *tradesController=new CTradesController("T5");
   tradesController.InitTrade(InpTrade5Enabled,InpTrade5Volume,InpTrade5TakeProfit,InpTrade5MaxTakeProfit,
                              InpTrade5StopLoss,InpTrade5StopLossProfile);
   tradesController.InitMartingale(InpTrade5Martingale,InpTrade5MaxMartingaleOperations);
   tradesController.InitTradesTime(InpTrade5TimeStartHour,InpTrade5TimeStartMinute,
                                   InpTrade5TimeEndHour,InpTrade5TimeEndMinute);

   hiloMaTrade5.AddTradesController(tradesController);
   HiLoController.AddModel(hiloMaTrade5);
  }
//+------------------------------------------------------------------+
