//+------------------------------------------------------------------+
//|                                              TakeProfitOrder.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Frederico Benevides"
#property link      "fredbene@gmail.com"
//+------------------------------------------------------------------+
//| Class to map take profit order
//+------------------------------------------------------------------+
class CTakeProfitOrder
  {
   string            m_name;
   double            m_points;

   bool              m_order_placed;
   bool              m_ticket_loaded;
   ulong             m_ticket_value;
  };
//+------------------------------------------------------------------+
//| Place Take Profit Order
//+------------------------------------------------------------------+
bool CTrades::PlaceOrder()
  {
   if(m_take_profit_points==0.0)
      return false;

   if(!IsPositionTicketLoaded())
      return false;

   if(IsTakeProfitPlaced())
      return false;

   double takeProfitPrice=CalculateTakeProfitPrice();
   PrintFormat("%s will be executed the take profit with price: %.2f",methodName,takeProfitPrice);

   bool result=false;
   if(m_trades_service.ExecuteBuySellLimit(m_is_on_buy_trade,m_current_volume,takeProfitPrice,methodName))
     {
      PrintFormat("%s operation executed: true",methodName);
      m_take_profit_placed=true;

      result=true;
     }
   else
      PrintFormat("%s operation executed: false",methodName);

   return result;
  }
//+------------------------------------------------------------------+
