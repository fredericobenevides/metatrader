//+------------------------------------------------------------------+
//|                                           StopLossController.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Frederico Benevides"
#property link      "fredbene@gmail.com"

#include <MyLibs\Trades\StopLossOrder.mqh>
//+------------------------------------------------------------------+
//| Controller of Take Profit Orders
//+------------------------------------------------------------------+
class CStopLossController
  {
   CTradesService   *m_trades_service;

   CStopLossOrder   *m_stop_loss_order;
   CPositionOrder   *m_position_order;

public:
                     CStopLossController(string tradeName,CPositionOrder *positionOrder);
                    ~CStopLossController();

   void              InitTrade(double stopLossPoints,int stopLossProfile);

   void              AddTradesService(CTradesService *tradesService) { m_trades_service=tradesService; }
   
   CStopLossOrder   *StopLossOrder() { return m_stop_loss_order; }

   bool              VerifyIfPlaceStopLossOrder();
   bool              VerifyIfDeleteStopLossOrder();
   bool              VerifyIfDestroyStopLossExecutedByMetatrader(ulong ticket);

   bool              VerifyIfChangeStopLossProfile();

   void              VerifyIfLoadStopLossTicket();

   void              ResetToDefault();
  };
//+------------------------------------------------------------------+
//| Constructor
//+------------------------------------------------------------------+
CStopLossController::CStopLossController(string tradeName,CPositionOrder *positionOrder)
  {
   m_stop_loss_order=new CStopLossOrder(tradeName,positionOrder);
   m_position_order=positionOrder;
  }
//+------------------------------------------------------------------+
//| Destructor
//+------------------------------------------------------------------+
CStopLossController::~CStopLossController()
  {
   delete m_stop_loss_order;
  }
//+------------------------------------------------------------------+
//| Init CTrades
//+------------------------------------------------------------------+
CStopLossController::InitTrade(double stopLossPoints,int stopLossProfile)
  {
   m_stop_loss_order.InitPoints(stopLossPoints,stopLossProfile);
  }
//+------------------------------------------------------------------+
//| Place Stop Loss Order
//+------------------------------------------------------------------+
bool CStopLossController::VerifyIfPlaceStopLossOrder()
  {
   if(!m_stop_loss_order.IsValidToPlacedOrder())
      return false;

//   string name=m_stop_loss_order.BuySellOpenName();
//   double positionVolume=m_position_order.Volume();
//   double stopLossPrice=m_stop_loss_order.CalculateStopLossPrice(m_trades_service);
//
//   if(!m_stop_loss_order.IsUsingStopProfile())
//      PrintFormat("%s will be executed the stop loss with price: %.2f",name,stopLossPrice);
//   else
//      PrintFormat("%s will change the stop loss based on profile with price: %.2f",name,stopLossPrice);
//
//   bool result=false;
//   if(m_trades_service.ExecuteBuySellStop(m_position_order.IsOnBuyTrade(),positionVolume,stopLossPrice,name))
//     {
//      PrintFormat("%s operation executed: true",name);
//      m_stop_loss_order.ExecutedPlaceStopLossOrder();
//
//      result=true;
//     }
//   else
//      PrintFormat("%s operation executed: false",name);
//
//   return result;
   return false;
  }
//+------------------------------------------------------------------+
//| Delete the stop loss ticket
//+------------------------------------------------------------------+
bool CStopLossController::VerifyIfDeleteStopLossOrder()
  {
//   if(!m_stop_loss_order.IsOrderNeedToBeRemoved())
//      return  false;
//
//   string name=m_stop_loss_order.BuySellCloseName();
//   ulong ticket=m_stop_loss_order.Ticket();
//
//   PrintFormat("%s will delete stop loss order with the ticket: %d",name,ticket);
//
//   bool result=false;
//   if(m_trades_service.ExecuteOrderDelete(ticket,name))
//     {
//      PrintFormat("%s operation executed: true",name);
//
//      if(m_stop_loss_order.IsBuyStopLoss())
//         m_trades_service.PlaySellSound();
//      if(m_stop_loss_order.IsSellStopLoss())
//         m_trades_service.PlayBuySound();
//
//      m_stop_loss_order.ExecutedDeleteStopLossOrder();
//      result=true;
//     }
//   else
//      PrintFormat("%s operation executed: false",name);
//
//   return result;
   return false;
  }
//+------------------------------------------------------------------+
//| Destroy the tick of Stop Loss if was executed
//+------------------------------------------------------------------+
bool CStopLossController::VerifyIfDestroyStopLossExecutedByMetatrader(ulong ticket)
  {
//   bool existStopLossTicket=m_stop_loss_order.VerifyIfExistTicket(ticket);
//
//   if(existStopLossTicket)
//     {
//      m_take_profit_order.SetToBeDeleted();
//      m_stop_loss_order.ExecutedDeleteStopLossOrder();
//
//      m_position_order.ResetVolumeToZero();
//      m_position_order.ExecutedBuyCloseOperation();
//      m_position_order.ExecutedSellCloseOperation();
//
//      return true;
//     }

   return false;
  }
//+------------------------------------------------------------------+
//| Verify if change the stop loss based on Profile
//+------------------------------------------------------------------+
bool CStopLossController::VerifyIfChangeStopLossProfile()
  {
//   if(m_stop_loss_order.IsOrderPlaced())
//     {
//      MqlTick lastTick;
//      SymbolInfoTick(Symbol(),lastTick);
//      double lastPrice=lastTick.last;
//
//      m_stop_loss_order.VerifyIfNeedToChangeStopBasedOnProfile(lastPrice);
//     }
   return false;
  }
//+------------------------------------------------------------------+
//| Try to load stop loss ticket
//+------------------------------------------------------------------+
void CStopLossController::VerifyIfLoadStopLossTicket()
  {
//   if(m_position_order.IsOnTradeOperation() && !m_stop_loss_order.IsTicketLoaded())
//     {
//      string name=m_stop_loss_order.BuySellOpenName();
//
//      ulong ticket=m_trades_service.TryToLoadOrderTicket(name);
//      if(ticket!=0)
//         m_stop_loss_order.LoadTicket(ticket);
//     }
  }
//+------------------------------------------------------------------+
//| Reset everything to Default
//+------------------------------------------------------------------+
void CStopLossController::ResetToDefault()
  {
   m_stop_loss_order.ResetToDefault();
  }
//+------------------------------------------------------------------+
