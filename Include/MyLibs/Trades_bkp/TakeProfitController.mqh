//+------------------------------------------------------------------+
//|                                         TakeProfitController.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Frederico Benevides"
#property link      "fredbene@gmail.com"

#include <MyLibs\Trades\TakeProfitOrder.mqh>

#include <MyLibs\Trades\TradesControllerInjection.mqh>
//+------------------------------------------------------------------+
//| Controller of Take Profit Orders
//+------------------------------------------------------------------+
class CTakeProfitController
  {
   CTakeProfitOrder *m_take_profit_order;

public:
                     CTakeProfitController(string tradeName,CTradesControllerInjection tradesControllerInjection);
                    ~CTakeProfitController();

   void              InitTrade(double takeProfitPoints,int maxTakeProfitOperations);

   bool              VerifyIfPlaceTakeProfitOrder();
   bool              VerifyIfDeleteTakeProfitOrder();
   bool              VerifyIfDestroyTakeProfitExecutedByMetatrader(ulong ticket);

   void              VerifyIfLoadTakeProfitTicket();
   
   void              ResetToDefault();
  };
//+------------------------------------------------------------------+
//| Constructor
//+------------------------------------------------------------------+
CTakeProfitController::CTakeProfitController(string tradeName,CTradesControllerInjection tradesControllerInjection)
  {
   m_take_profit_order=new CTakeProfitController(tradeName,tradesControllerInjection);
  }
//+------------------------------------------------------------------+
//| Destructor
//+------------------------------------------------------------------+
CTakeProfitController::~CTakeProfitController()
  {
   delete m_take_profit_order;
  }
//+------------------------------------------------------------------+
//| Init CTrades
//+------------------------------------------------------------------+
CTradesController::InitTrade(double takeProfitPoints,int maxTakeProfitOperations)
  {
   m_take_profit_order.InitPoints(takeProfitPoints,maxTakeProfitOperations);
  }
//+------------------------------------------------------------------+
//| Place Take Profit Order
//+------------------------------------------------------------------+
bool CTakeProfitController::VerifyIfPlaceTakeProfitOrder()
  {
   if(!m_take_profit_order.IsValidToPlacedOrder())
      return false;

   string name=m_take_profit_order.BuySellOpenName();
   double positionVolume=m_position_order.Volume();
   double takeProfitPrice=m_take_profit_order.CalculateTakeProfitPrice(m_trades_service);

   PrintFormat("%s will be executed the take profit with price: %.2f",name,takeProfitPrice);

   bool result=false;
   if(m_trades_service.ExecuteBuySellLimit(m_position_order.IsOnBuyTrade(),positionVolume,takeProfitPrice,name))
     {
      PrintFormat("%s operation executed: true",name);
      m_take_profit_order.ExecutedPlaceTakeProfitOrder();

      result=true;
     }
   else
      PrintFormat("%s operation executed: false",name);

   return result;
  }
//+------------------------------------------------------------------+
//| Delete the take profit ticket
//+------------------------------------------------------------------+
bool CTakeProfitController::VerifyIfDeleteTakeProfitOrder()
  {
   if(!m_take_profit_order.IsOrderNeedToBeRemoved())
      return false;

   string name=m_take_profit_order.BuySellCloseName();
   ulong ticket=m_take_profit_order.Ticket();

   PrintFormat("%s will delete take profit order with the ticket: %d",name,ticket);

   bool result=false;
   if(m_trades_service.ExecuteOrderDelete(ticket,name))
     {
      PrintFormat("%s operation executed: true",name);

      if(m_take_profit_order.IsBuyTakeProfit())
         m_trades_service.PlaySellSound();
      if(m_take_profit_order.IsSellTakeProfit())
         m_trades_service.PlayBuySound();

      m_take_profit_order.ExecutedDeleteTakeProfitOrder();
      result=true;
     }
   else
      PrintFormat("%s operation executed: false",name);

   return result;
  }
//+------------------------------------------------------------------+
//| Destroy the tick of Take Profit if was executed
//+------------------------------------------------------------------+
bool CTakeProfitController::VerifyIfDestroyTakeProfitExecutedByMetatrader(ulong ticket)
  {
   bool existTakeProfitTicket=m_take_profit_order.VerifyIfExistTicket(ticket);

   if(existTakeProfitTicket)
     {
      m_take_profit_order.ExecutedDeleteTakeProfitOrder();
      //m_stop_loss_order.SetToBeDeleted();

      m_take_profit_order.UpdateTakeProfitOperations();
      m_take_profit_order.DisablePositionOnMaxTakeProfitOperations();

      m_position_order.ResetNextVolumeToInitialVolume();

      m_position_order.ResetVolumeToZero();
      m_position_order.ExecutedBuyCloseOperation();
      m_position_order.ExecutedSellCloseOperation();

      return true;
     }

   return false;
  }
//+------------------------------------------------------------------+
//| Try to load take profit ticket
//+------------------------------------------------------------------+
void CTakeProfitController::VerifyIfLoadTakeProfitTicket()
  {
   if(m_position_order.IsOnTradeOperation() && !m_take_profit_order.IsTicketLoaded())
     {
      string name=m_take_profit_order.BuySellOpenName();

      ulong ticket=m_trades_service.TryToLoadOrderTicket(name);
      if(ticket!=0)
         m_take_profit_order.LoadTicket(ticket);
     }
  }
//+------------------------------------------------------------------+
//| Reset everything to Default
//+------------------------------------------------------------------+
void CTakeProfitController::ResetToDefault()
  {
   m_take_profit_order.ResetToDefault();
  }
//+------------------------------------------------------------------+
