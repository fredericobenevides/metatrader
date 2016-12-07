//+------------------------------------------------------------------+
//|                                           PositionController.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Frederico Benevides"
#property link      "fredbene@gmail.com"

#include <MyLibs\Trades\PositionOrder.mqh>
//+------------------------------------------------------------------+
//| Class to control position orders
//+------------------------------------------------------------------+
class CPositionController
  {
   CPositionOrder   *m_position_order;

public:
   CPositionOrder    *PositionOrder() { return m_position_order; }

  };
//+------------------------------------------------------------------+
