//+------------------------------------------------------------------+
//|                                                StopLossOrder.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Frederico Benevides"
#property link      "fredbene@gmail.com"
//+------------------------------------------------------------------+
//| Class to map take profit order
//+------------------------------------------------------------------+
class CStopLossOrder
  {
   string            m_name;
   double            m_points;

   bool              m_order_placed;
   bool              m_ticket_loaded;
   ulong             m_ticket_value;
  };
//+------------------------------------------------------------------+
//| Place Stop Loss Order
//+------------------------------------------------------------------+
bool CTrades::PlaceStopLossOrder(string methodName)
  {
   if(m_stop_loss_points==0.0)
      return false;

   if(!IsPositionTicketLoaded())
      return false;

   if(IsStopLossPlaced())
      return false;

   double stopLossPrice=CalculateStopLossPrice();
   PrintFormat("%s will be executed the stop loss with price: %.2f",methodName,stopLossPrice);

   bool result=false;
   if(m_trades_service.ExecuteBuySellStop(m_is_on_buy_trade,m_current_volume,stopLossPrice,methodName))
     {
      PrintFormat("%s operation executed: true",methodName);
      m_stop_loss_placed=true;

      result=true;
     }
   else
      PrintFormat("%s operation executed: false",methodName);

   return result;
  }
//+------------------------------------------------------------------+
