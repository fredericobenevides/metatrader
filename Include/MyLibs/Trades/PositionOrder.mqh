//+------------------------------------------------------------------+
//|                                                   TradeOrder.mqh |
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
   double            m_current_volume;
   double            m_next_volume;

   bool              m_order_placed;
   bool              m_ticket_loaded;
   ulong             m_ticket_value;

   //--- type of operation
   bool              m_is_on_buy_trade;
   bool              m_is_on_sell_trade;

   // trades time
   int               m_time_start_hour;
   int               m_time_start_minute;
   int               m_time_end_hour;
   int               m_time_end_minute;

public:
   bool              BuyOpen(string methodName);
   bool              SellOpen(string methodName);
   bool              BuyClose(string methodName);
   bool              SellClose(string methodName);

   bool              IsOrderPlaced() { return m_order_placed; }

   bool              IsOnBuyTrade() { return m_is_on_buy_trade; }
   bool              IsOnSellTrade() { return m_is_on_sell_trade; }

   string            Name() { return m_name; }
   double            CurrentVolume() { return m_current_volume; }
   double            NextVolume() { return m_next_volume; }
  };
//+------------------------------------------------------------------+
//| Open a BUY operation
//+------------------------------------------------------------------+
bool CPositionOrder::BuyOpen()
  {
   if(IsOrderPlaced())
      return false;

   string methodName=m_name+"::BuyOpen()";
   PrintFormat("%s will be executed with volume: %.2f",methodName,m_current_volume);

   bool result=false;
   if(m_trades_service.ExecuteBuyTrade(m_current_volume,methodName))
     {
      PrintFormat("%s operation executed: true",methodName);
      m_is_on_buy_trade=true;
      m_open_position_placed=true;

      result=true;
     }
   else
      PrintFormat("%s operation executed: false",methodName);

   return result;
  }
//+------------------------------------------------------------------+
//| Open a SELL operation
//+------------------------------------------------------------------+
bool CPositionOrder::SellOpen()
  {
   if(IsOrderPlaced())
      return false;

   string methodName=m_name+"::SellOpen()";
   PrintFormat("%s will be executed with volume: %.2f",methodName,m_current_volume);

   bool result=false;
   if(m_trades_service.ExecuteSellTrade(m_current_volume,methodName))
     {
      PrintFormat("%s operation executed: true",methodName);
      m_is_on_sell_trade=true;
      m_open_position_placed=true;

      result=true;
     }
   else
      PrintFormat("%s operation executed: false",methodName);

   return result;
  }
//+------------------------------------------------------------------+
//| Close a BUY operation
//+------------------------------------------------------------------+
bool CPositionOrder::BuyClose()
  {
   if(!IsOnBuyTrade())
      return false;

   string methodName=m_name+"::BuyClose()";
   PrintFormat("%s will be executed with volume: %.2f",methodName,m_current_volume);

   bool result=false;
   if(m_trades_service.ExecuteSellTrade(m_current_volume,methodName))
     {
      PrintFormat("%s operation executed: true",methodName);
      m_is_on_buy_trade=false;
      m_open_position_placed=false;
      ResetPositionTicketData();

      result=true;
     }
   else
      PrintFormat("%s operation executed: false",methodName);

   return result;
  }
//+------------------------------------------------------------------+
//| Close a SELL operation
//+------------------------------------------------------------------+
bool CPositionOrder::SellClose()
  {
   if(!IsOnSellTrade())
      return false;

   string methodName=m_name+"::SellClose()";
   PrintFormat("%s will be executed with volume: %.2f",methodName,m_current_volume);

   bool result=false;
   if(m_trades_service.ExecuteBuyTrade(m_current_volume,methodName))
     {
      PrintFormat("%s operation executed: true",methodName);
      m_is_on_sell_trade=false;
      m_open_position_placed=false;
      ResetPositionTicketData();

      result=true;
     }
   else
      PrintFormat("%s operation executed: false",methodName);

   return result;
  }
//+------------------------------------------------------------------+
