//+------------------------------------------------------------------+
//|                                              TradeController.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Frederico Benevides"
#property link      "fredbene@gmail.com"
//+------------------------------------------------------------------+
//| Controller for Trade Operations
//+------------------------------------------------------------------+
class TradeController
  {
   bool              TradeBuyOpen(string methodName,double volume);
   bool              TradeSellOpen(string methodName,double volume);
   bool              TradeBuyClose(string methodName);
   bool              TradeSellClose(string methodName);
  };
//+------------------------------------------------------------------+
