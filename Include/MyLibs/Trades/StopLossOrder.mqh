//+------------------------------------------------------------------+
//|                                                StopLossOrder.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Frederico Benevides"
#property link      "fredbene@gmail.com"

#include <MyLibs\Trades\PositionOrder.mqh>
#include <MyLibs\Trades\StopLossProfile.mqh>

#include <MyLibs\Trades\TradesService.mqh>
//+------------------------------------------------------------------+
//| Class to map take profit order
//+------------------------------------------------------------------+
class CStopLossOrder
  {
   CPositionOrder   *m_position_order;

   CStopLossProfile *m_stop_loss_profile;

   string            m_buy_open_name;
   string            m_sell_open_name;
   string            m_buy_close_name;
   string            m_sell_close_name;

   bool              m_open_on_buy_trade;
   bool              m_open_on_sell_trade;

   double            m_points;
   //
   //   bool              m_order_placed;
   //   bool              m_order_need_to_be_deleted;
   //   bool              m_ticket_loaded;
   //   ulong             m_ticket_value;
public:

                     CStopLossOrder(string tradeName,CPositionOrder *positionOrder);
                    ~CStopLossOrder();
   void              InitPoints(double points,int profile);

   //   void              ExecutedPlaceStopLossOrder();
   //   void              ExecutedDeleteStopLossOrder();
   //
   //   double            CalculateStopLossPrice(CTradesService *tradesService);

   bool              IsValidToPlacedOrder();
   //   bool              IsOrderNeedToBeRemoved() { return m_order_need_to_be_deleted; }
   //   void              SetToBeDeleted();
   //
   string            BuySellOpenName();
   string            BuySellCloseName();
   bool              IsBuyStopLoss()  { return m_open_on_buy_trade; }
   bool              IsSellStopLoss() { return m_open_on_sell_trade; }
   //
   double            Points() { return m_points; }
   //   bool              IsOrderPlaced() { return m_order_placed; }
   //   bool              IsTicketLoaded() { return m_ticket_loaded; }
   //   ulong             Ticket()         { return m_ticket_value; }
   //   void              LoadTicket(ulong ticket);
   //   bool              VerifyIfExistTicket(ulong ticket) { return m_ticket_value==ticket; }
   //
   //   void              RestartProfile() { m_stop_loss_profile.Restart(); }
   void              ResetToDefault();
   //
   //   // stop loss profile
   void              VerifyIfNeedToChangeStopBasedOnProfile(double currentMarketPrice);
   void              OrderStopLossProfileMayBePlaced();
   void              OrderStopLossProfileMaybeWasRemoved();
   bool              IsUsingStopProfile() { return m_stop_loss_profile.IsUsingStopProfile(); }
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
   delete m_stop_loss_profile;
  }
//+------------------------------------------------------------------+
//| Init points
//+------------------------------------------------------------------+
void CStopLossOrder::InitPoints(double points,int profile)
  {
   m_points=points;
   m_stop_loss_profile=new CStopLossProfile(profile,m_position_order);
  }
////+------------------------------------------------------------------+
////| Executed the place stop loss order
////+------------------------------------------------------------------+
//void CStopLossOrder::ExecutedPlaceStopLossOrder()
//  {
//   m_order_placed=true;
//
//// profile
//   OrderStopLossProfileMayBePlaced();
//  }
////+------------------------------------------------------------------+
////| Executed the delete stop loss order
////+------------------------------------------------------------------+
//void CStopLossOrder::ExecutedDeleteStopLossOrder()
//  {
//   m_open_on_buy_trade=false;
//   m_open_on_sell_trade=false;
//
//   m_order_placed=false;
//   m_order_need_to_be_deleted=false;
//   m_ticket_loaded=false;
//   m_ticket_value=0;
//
//// profile
//   OrderStopLossProfileMaybeWasRemoved();
//  }
////+------------------------------------------------------------------+
////| Calculate the stop loss price using the current price
////+------------------------------------------------------------------+
////double CStopLossOrder::CalculateStopLossPrice(CTradesService *tradesService)
//  {
//
//   double openPrice=m_position_order.Price();
//   double stopLossPrice=0;
//
//   double points=m_points;
//
//   if(m_stop_loss_profile.IsNeedToChange())
//      points=m_stop_loss_profile.CurrentEnableProfile().NewPoints();
//
//   if(m_position_order.IsOnBuyTrade())
//     {
//      stopLossPrice=openPrice-points;
//      m_open_on_buy_trade=true;
//     }
//   else
//     {
//      stopLossPrice=openPrice+points;
//      m_open_on_sell_trade=true;
//     }
//
//   return stopLossPrice;
////  }
//+------------------------------------------------------------------+
//| Verify if if valid to place a take profit order
//+------------------------------------------------------------------+
bool CStopLossOrder::IsValidToPlacedOrder()
  {
   if(m_points==0.0)
      return false;

//if(IsOrderPlaced())
//   return false;

   if(!m_position_order.IsOrderPlaced())
      return false;

   if(!m_position_order.IsOnTradeOperation())
      return false;

   return true;
  }
////+------------------------------------------------------------------+
////| Set to be deleted the stop loss
////+------------------------------------------------------------------+
//void CStopLossOrder::SetToBeDeleted(void)
//  {
//   if(!IsOrderPlaced())
//      return;
//
//   m_order_need_to_be_deleted=true;
//  }
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
////+------------------------------------------------------------------+
////| Load the current ticket
////+------------------------------------------------------------------+
//void CStopLossOrder::LoadTicket(ulong ticket)
//  {
//   m_ticket_loaded=true;
//   m_ticket_value=ticket;
//  }
//+------------------------------------------------------------------+
//| Reset everything to Default
//+------------------------------------------------------------------+
void CStopLossOrder::ResetToDefault()
  {
   m_open_on_buy_trade=false;
   m_open_on_sell_trade=false;

//   m_order_placed=false;
//   m_order_need_to_be_deleted=false;
//   m_ticket_loaded=false;
//   m_ticket_value=0;

// profile
   m_stop_loss_profile.ResetToDefault();
  }
//+------------------------------------------------------------------+
//| Verify if need to change the stop loss value
//+------------------------------------------------------------------+
void CStopLossOrder::VerifyIfNeedToChangeStopBasedOnProfile(double currentMarketPrice)
  {
   if(m_points==0.0)
      return;

   if(!m_position_order.IsOrderPlaced())
      return;

   if(!m_position_order.IsOnTradeOperation())
      return;

//if(IsOrderPlaced())
//  {
//   m_stop_loss_profile.VerifyIfNeedToChangeStopLoss(currentMarketPrice);
//   if(m_stop_loss_profile.IsNeedToChange())
//      SetToBeDeleted();
//  }
  }
//+------------------------------------------------------------------+
//| Inform that order stop loss based on profile may be placed.
//+------------------------------------------------------------------+
void CStopLossOrder::OrderStopLossProfileMayBePlaced()
  {
   m_stop_loss_profile.StopLossProfileWasPlaced();
  }
//+------------------------------------------------------------------+
//| Inform that order stop loss based on profile maybe was removed.
//+------------------------------------------------------------------+
void CStopLossOrder::OrderStopLossProfileMaybeWasRemoved()
  {
   m_stop_loss_profile.StopLossProfileWasRemoved();
  }

//+------------------------------------------------------------------+
