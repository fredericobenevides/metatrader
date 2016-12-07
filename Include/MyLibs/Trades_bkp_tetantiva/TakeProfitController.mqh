//+------------------------------------------------------------------+
//|                                         TakeProfitController.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Frederico Benevides"
#property link      "fredbene@gmail.com"

#include <MyLibs\Trades\TakeProfitOrder.mqh>
//+------------------------------------------------------------------+
//| Class to control take profit orders
//+------------------------------------------------------------------+
class CTakeProfitController
  {
   CTakeProfitOrder   *m_take_profit_order;

public:
   CTakeProfitOrder    *TakeProfitOrder() { return m_take_profit_order; }

  };
//+------------------------------------------------------------------+
