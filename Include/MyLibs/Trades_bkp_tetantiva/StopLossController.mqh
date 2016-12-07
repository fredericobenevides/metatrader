//+------------------------------------------------------------------+
//|                                           StopLossController.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Frederico Benevides"
#property link      "fredbene@gmail.com"

#include <MyLibs\Trades\StopLossOrder.mqh>
//+------------------------------------------------------------------+
//| Class to control stop loss orders
//+------------------------------------------------------------------+
class CStopLossController
  {
   CStopLossOrder   *m_stop_loss_order;

public:
   CStopLossOrder    *StopLossOrder() { return m_stop_loss_order; }

  };
//+------------------------------------------------------------------+
