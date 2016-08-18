//+------------------------------------------------------------------+
//|                                              TakeProfitOrder.mqh |
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
class CTakeProfitOrder
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

   int               m_max_take_profit_operations;
   int               m_count_take_profit_operations;

public:
                     CTakeProfitOrder(string tradeName,CPositionOrder *positionOrder);
                    ~CTakeProfitOrder();
   void              InitPoints(double points,int maxTakeProfitPoints);

   void              ExecutedPlaceTakeProfitOrder();
   void              ExecutedDeleteTakeProfitOrder();

   double            CalculateTakeProfitPrice(CTradesService *tradesService);

   bool              IsValidToPlacedOrder();
   bool              IsOrderNeedToBeRemoved() { return m_order_need_to_be_deleted; }
   void              SetToBeDeleted();

   string            BuySellOpenName();
   string            BuySellCloseName();
   bool              IsBuyTakeProfit()  { return m_open_on_buy_trade; }
   bool              IsSellTakeProfit() { return m_open_on_sell_trade; }

   double            Points() { return m_points; }
   bool              IsOrderPlaced() { return m_order_placed; }

   bool              IsTicketLoaded() { return m_ticket_loaded; }
   ulong             Ticket()         { return m_ticket_value; }
   void              LoadTicket(ulong ticket);
   bool              VerifyIfExistTicket(ulong ticket) { return m_ticket_value==ticket; }

   void              UpdateTakeProfitOperations();
   void              ResetPositionNextVolumeToInitialVolumeOnMaxTakeProfit();
   void              DisablePositionOnMaxTakeProfitOperations();

   void              ResetToDefault();
  };
//+------------------------------------------------------------------+
//| Constructor
//+------------------------------------------------------------------+
CTakeProfitOrder::CTakeProfitOrder(string tradeName,CPositionOrder *positionOrder)
  {
   m_buy_open_name=tradeName+"::TradeBuyOpen::TP()";
   m_sell_open_name=tradeName+"::TradeSellOpen::TP()";
   m_buy_close_name=tradeName+"::TradeBuyClose::DTP()";
   m_sell_close_name=tradeName+"::TradeSellClose::DTP()";

   m_position_order=positionOrder;
  }
//+------------------------------------------------------------------+
//| Destructor
//+------------------------------------------------------------------+
CTakeProfitOrder::~CTakeProfitOrder()
  {
   delete m_position_order;
  }
//+------------------------------------------------------------------+
//| Init points
//+------------------------------------------------------------------+
void CTakeProfitOrder::InitPoints(double points,int maxTakeProfitPoints)
  {
   m_points=points;
   m_max_take_profit_operations=maxTakeProfitPoints;
  }
//+------------------------------------------------------------------+
//| Executed the place take profit order
//+------------------------------------------------------------------+
void CTakeProfitOrder::ExecutedPlaceTakeProfitOrder()
  {
   m_order_placed=true;
  }
//+------------------------------------------------------------------+
//| Executed the delete take profit order
//+------------------------------------------------------------------+
void CTakeProfitOrder::ExecutedDeleteTakeProfitOrder()
  {
   m_open_on_buy_trade=false;
   m_open_on_sell_trade=false;

   m_order_placed=false;
   m_order_need_to_be_deleted=false;
   m_ticket_loaded=false;
   m_ticket_value=0;
  }
//+------------------------------------------------------------------+
//| Get the take profit price
//+------------------------------------------------------------------+
double CTakeProfitOrder::CalculateTakeProfitPrice(CTradesService *tradesService)
  {
   double openPrice=m_position_order.Price();
   double takeProfitPrice=0;

   if(m_position_order.IsOnBuyTrade())
     {
      takeProfitPrice=openPrice+m_points;
      m_open_on_buy_trade=true;
     }
   else
     {
      takeProfitPrice=openPrice-m_points;
      m_open_on_sell_trade=true;
     }

   return takeProfitPrice;
  }
//+------------------------------------------------------------------+
//| Verify if if valid to place a take profit order
//+------------------------------------------------------------------+
bool CTakeProfitOrder::IsValidToPlacedOrder()
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
//| Set to be deleted the take profit
//+------------------------------------------------------------------+
void CTakeProfitOrder::SetToBeDeleted(void)
  {
   if(!IsOrderPlaced())
      return;

   m_order_need_to_be_deleted=true;
  }
//+------------------------------------------------------------------+
//| Returns the Buy or Sell Open Name
//+------------------------------------------------------------------+
string CTakeProfitOrder::BuySellOpenName()
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
string CTakeProfitOrder::BuySellCloseName()
  {
   if(m_open_on_buy_trade)
      return m_buy_close_name;
   else
      return m_sell_close_name;
  }
//+------------------------------------------------------------------+
//| Load the current ticket
//+------------------------------------------------------------------+
void CTakeProfitOrder::LoadTicket(ulong ticket)
  {
   m_ticket_loaded=true;
   m_ticket_value=ticket;
  }
//+------------------------------------------------------------------+
//| Update the Count of take profit operations
//+------------------------------------------------------------------+
void CTakeProfitOrder::UpdateTakeProfitOperations()
  {
   m_count_take_profit_operations+=1;
  }
//+------------------------------------------------------------------+
//| Reset the position next volume to its initial volume on max take profit
//+------------------------------------------------------------------+
void CTakeProfitOrder::ResetPositionNextVolumeToInitialVolumeOnMaxTakeProfit()
  {
   if(m_count_take_profit_operations>=m_max_take_profit_operations)
      m_position_order.ResetNextVolumeToInitialVolume();
  }
//+------------------------------------------------------------------+
//| Disable Position Order on Max take profit operations
//+------------------------------------------------------------------+
void CTakeProfitOrder::DisablePositionOnMaxTakeProfitOperations()
  {
   if(m_count_take_profit_operations>=m_max_take_profit_operations)
      m_position_order.DisableTrade();
  }
//+------------------------------------------------------------------+
//| Reset everything to Default
//+------------------------------------------------------------------+
void CTakeProfitOrder::ResetToDefault()
  {
   m_open_on_buy_trade=false;
   m_open_on_sell_trade=false;

   m_order_placed=false;
   m_order_need_to_be_deleted=false;
   m_ticket_loaded=false;
   m_ticket_value=0;

   m_count_take_profit_operations=0;
  }
//+------------------------------------------------------------------+
