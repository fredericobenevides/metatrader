//+------------------------------------------------------------------+
//|                                                PositionOrder.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Frederico Benevides"
#property link      "fredbene@gmail.com"
//+------------------------------------------------------------------+
//| Class to map the position order
//+------------------------------------------------------------------+
class CPositionOrder
  {
   string            m_name;
   string            m_buy_open_name;
   string            m_buy_close_name;
   string            m_sell_open_name;
   string            m_sell_close_name;

   bool              m_trade_enable;
   bool              m_initial_trade_enable;
   double            m_initial_volume;
   double            m_volume;
   double            m_next_volume;
   double            m_price;

   // martingale
   int               m_martingale;
   int               m_max_martingale_operations;
   double            m_max_volume_martingale_operations;

   bool              m_order_placed;

   //--- type of operation
   bool              m_is_on_buy_trade;
   bool              m_is_on_sell_trade;

public:

   double            OpenNewVolume();
   double            CloseVolume()          { return m_volume; }
   double            Volume()               { return m_volume; }
   double            NextVolume()           { return m_next_volume; }
   double            Price()                { return m_price; }
   void              SetPrice(double price) {  m_price=price; }
  };
//+------------------------------------------------------------------+
