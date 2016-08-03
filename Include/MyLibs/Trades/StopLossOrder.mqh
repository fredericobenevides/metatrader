//+------------------------------------------------------------------+
//|                                                StopLossOrder.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Frederico Benevides"
#property link      "fredbene@gmail.com"

#include <MyLibs\Trades\PositionOrder.mqh>

#include <MyLibs\Trades\TradesService.mqh>
//+------------------------------------------------------------------+
//| Class to map take profit order
//+------------------------------------------------------------------+
class CStopLossOrder
  {
   CPositionOrder   *m_position_order;

   string            m_buy_open_name;
   string            m_sell_open_name;
   string            m_buy_close_name;
   string            m_sell_close_name;

   bool              m_open_on_buy_trade;
   bool              m_open_on_sell_trade;

   double            m_points;

   bool              m_order_placed;
   bool              m_order_need_to_be_deleted;
   bool              m_ticket_loaded;
   ulong             m_ticket_value;

public:

                     CStopLossOrder(string tradeName,CPositionOrder *positionOrder);
                    ~CStopLossOrder();
   void              InitPoints(double points) { m_points=points; }

   void              ExecutedPlaceStopLossOrder();
   void              ExecutedDeleteStopLossOrder();

   double            CalculateStopLossPrice(CTradesService *tradesService);

   bool              IsValidToPlacedOrder();
   bool              IsOrderNeedToBeRemoved() { return m_order_need_to_be_deleted; }
   void              SetToBeDeleted();

   string            BuySellOpenName();
   string            BuySellCloseName();
   bool              IsBuyStopLoss()  { return m_open_on_buy_trade; }
   bool              IsSellStopLoss() { return m_open_on_sell_trade; }

   double            Points() { return m_points; }
   bool              IsOrderPlaced() { return m_order_placed; }
   bool              IsTicketLoaded() { return m_ticket_loaded; }
   ulong             Ticket()         { return m_ticket_value; }
   void              LoadTicket(ulong ticket);
   bool              VerifyIfExistTicket(ulong ticket) { return m_ticket_value==ticket; }

   void              ResetToDefault();
  };
//+------------------------------------------------------------------+
//| Constructor
//+------------------------------------------------------------------+
CStopLossOrder::CStopLossOrder(string tradeName,CPositionOrder *positionOrder)
  {
   m_buy_open_name=tradeName+"::TradeBuyOpen::SL()";
   m_sell_open_name=tradeName+"::TradeSellOpen::SL()";
   m_buy_close_name=tradeName+"::TradeBuyClose::DSL()";
   m_sell_close_name=tradeName+"::TradeSellClose::DSL()";

   m_position_order=positionOrder;
  }
//+------------------------------------------------------------------+
//| Destructor
//+------------------------------------------------------------------+
CStopLossOrder::~CStopLossOrder()
  {
   delete m_position_order;
  }
//+------------------------------------------------------------------+
//| Executed the place take profit order
//+------------------------------------------------------------------+
void CStopLossOrder::ExecutedPlaceStopLossOrder()
  {
   m_order_placed=true;
  }
//+------------------------------------------------------------------+
//| Executed the place take profit order
//+------------------------------------------------------------------+
void CStopLossOrder::ExecutedDeleteStopLossOrder()
  {
   m_open_on_buy_trade=false;
   m_open_on_sell_trade=false;

   m_order_placed=false;
   m_order_need_to_be_deleted=false;
   m_ticket_loaded=false;
   m_ticket_value=0;
  }
//+------------------------------------------------------------------+
//| Calculate the stop loss price using the current price
//+------------------------------------------------------------------+
double CStopLossOrder::CalculateStopLossPrice(CTradesService *tradesService)
  {
   double openPrice=m_position_order.Price();
   double stopLossPrice=0;

   if(m_position_order.IsOnBuyTrade())
     {
      stopLossPrice=openPrice-m_points;
      m_open_on_buy_trade=true;
     }
   else
     {
      stopLossPrice=openPrice+m_points;
      m_open_on_sell_trade=true;
     }

   return stopLossPrice;
  }
//+------------------------------------------------------------------+
//| Verify if if valid to place a take profit order
//+------------------------------------------------------------------+
bool CStopLossOrder::IsValidToPlacedOrder()
  {
   if(m_points==0.0)
      return false;

   if(IsOrderPlaced())
      return false;

   if(!m_position_order.IsOrderPlaced())
      return false;

   if(!m_position_order.IsOnTradeOperation())
      return false;

   return true;
  }
//+------------------------------------------------------------------+
//| Set to be deleted the stop loss
//+------------------------------------------------------------------+
void CStopLossOrder::SetToBeDeleted(void)
  {
   if(!IsOrderPlaced())
      return;

   m_order_need_to_be_deleted=true;
  }
//+------------------------------------------------------------------+
//| Returns the Buy or Sell Open Name
//+------------------------------------------------------------------+
string CStopLossOrder::BuySellOpenName()
  {
   if(m_position_order.IsOnBuyTrade())
     {
      m_open_on_buy_trade=true;
      m_open_on_sell_trade=false;

      return m_buy_open_name;
     }
   else
     {
      m_open_on_buy_trade=false;
      m_open_on_sell_trade=true;

      return m_sell_open_name;
     }
  }
//+------------------------------------------------------------------+
//| Returns the Buy or Sell Open Name
//+------------------------------------------------------------------+
string CStopLossOrder::BuySellCloseName()
  {
   if(m_open_on_buy_trade)
      return m_buy_close_name;
   else
      return m_sell_close_name;
  }
//+------------------------------------------------------------------+
//| Load the current ticket
//+------------------------------------------------------------------+
void CStopLossOrder::LoadTicket(ulong ticket)
  {
   m_ticket_loaded=true;
   m_ticket_value=ticket;
  }
//+------------------------------------------------------------------+
//| Reset everything to Default
//+------------------------------------------------------------------+
void CStopLossOrder::ResetToDefault()
  {
   m_open_on_buy_trade=false;
   m_open_on_sell_trade=false;

   m_order_placed=false;
   m_order_need_to_be_deleted=false;
   m_ticket_loaded=false;
   m_ticket_value=0;
  }
//+------------------------------------------------------------------+
