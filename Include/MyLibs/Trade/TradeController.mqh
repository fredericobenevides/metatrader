//+------------------------------------------------------------------+
//|                                              TradeController.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Frederico Benevides"
#property link      "fredbene@gmail.com"

#include <MyLibs\Trade\Trades.mqh>
//+------------------------------------------------------------------+
//| Controller for Trade Operations
//+------------------------------------------------------------------+
class TradeController
  {
public:
   bool              TradeBuyOpen(CTrades *trades,string methodName);
   bool              TradeSellOpen(CTrades *trades,string methodName);
   bool              TradeBuyClose(CTrades *trades,string methodName);
   bool              TradeSellClose(CTrades *trades,string methodName);

   bool              ExecuteBuyTrade(CTrades *trades,string methodName);
   bool              ExecuteSellTrade(CTrades *trades,string methodName);
  };
//+------------------------------------------------------------------+
