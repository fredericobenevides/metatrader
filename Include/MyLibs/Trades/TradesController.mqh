//+------------------------------------------------------------------+
//|                                                TradesManager.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Frederico Benevides"
#property link      "fredbene@gmail.com"

#include <MyLibs\Trades\PositionOrder.mqh>
#include <MyLibs\Trades\TakeProfitOrder.mqh>
#include <MyLibs\Trades\StopLossOrder.mqh>

#include <MyLibs\Trades\TradesService.mqh>

#include <MyLibs\Utils\Time.mqh>
//+------------------------------------------------------------------+
//| Class to Map Trades Order
//+------------------------------------------------------------------+
class CTradesController
  {
   CTradesService   *m_trades_service;
   CTime             m_time;

   CPositionOrder   *m_position_order;
   CTakeProfitOrder *m_take_profit_order;
   CStopLossOrder   *m_stop_loss_order;

   // trades time
   int               m_time_start_hour;
   int               m_time_start_minute;
   int               m_time_end_hour;
   int               m_time_end_minute;

public:

                     CTradesController(string tradeName);
                    ~CTradesController();

   void              InitTrade(bool enableTrade,double initialVolume,double takeProfitPoints,int maxTakeProfitOperations,
                               double stopLossPoints);
   void              InitMartingale(int martingale,int maxMartingaleOperations);
   void              InitTradesTime(int startHour,int startMinute,int endHour,int endMinute);

   void              AddTradesService(CTradesService *tradesService) { m_trades_service=tradesService; }

   bool              PositionBuyOpen();
   bool              PositionSellOpen();
   bool              PositionBuyClose();
   bool              PositionSellClose();

   bool              VerifyIfPlaceTakeProfitOrder();
   bool              VerifyIfPlaceStopLossOrder();
   bool              VerifyIfDeleteTakeProfitOrder();
   bool              VerifyIfDeleteStopLossOrder();
   bool              VerifyIfDestroyTpSlWhenExecutedByMetatrader(ulong ticketOrder);

   void              VerifyIfLoadTakeProfitTicket();
   void              VerifyIfLoadStopLossTicket();

   CPositionOrder    *PositionOrder() { return m_position_order; }
   CTakeProfitOrder  *TakeProfitOrder() { return m_take_profit_order; }
   CStopLossOrder    *StopLossOrder() { return m_stop_loss_order; }

   void              ResetToDefault();

private:

   bool              isTimeToOpenOperation();
  };
//+------------------------------------------------------------------+
//| Constructor
//+------------------------------------------------------------------+
CTradesController::CTradesController(string tradeName)
  {
   m_position_order=new CPositionOrder(tradeName);
   m_take_profit_order=new CTakeProfitOrder(tradeName,m_position_order);
   m_stop_loss_order=new CStopLossOrder(tradeName,m_position_order);
  }
//+------------------------------------------------------------------+
//| Destructor
//+------------------------------------------------------------------+
CTradesController::~CTradesController()
  {
   delete m_trades_service;
   delete m_position_order;
   delete m_take_profit_order;
   delete m_stop_loss_order;
  }
//+------------------------------------------------------------------+
//| Init CTrades
//+------------------------------------------------------------------+
CTradesController::InitTrade(bool enableTrade,double initialVolume,double takeProfitPoints,int maxTakeProfitOperations,
                             double stopLossPoints)
  {
   m_position_order.InitTrade(enableTrade,initialVolume);
   m_take_profit_order.InitPoints(takeProfitPoints,maxTakeProfitOperations);
   m_stop_loss_order.InitPoints(stopLossPoints);
  }
//+------------------------------------------------------------------+
//| Init the trades martingale
//+------------------------------------------------------------------+
void CTradesController::InitMartingale(int martingale,int maxMartingaleOperations)
  {
   m_position_order.InitMartingale(martingale,maxMartingaleOperations);
  }
//+------------------------------------------------------------------+
//| Init Trade's Time
//+------------------------------------------------------------------+
void CTradesController::InitTradesTime(int startHour,int startMinute,int endHour,int endMinute)
  {
   m_time_start_hour=startHour;
   m_time_start_minute=startMinute;
   m_time_end_hour=endHour;
   m_time_end_minute=endMinute;
  }
//+------------------------------------------------------------------+
//| Open a Buy Position Order
//+------------------------------------------------------------------+
bool CTradesController::PositionBuyOpen()
  {
   if(!m_position_order.IsTradeEnable())
      return false;

   if(m_position_order.IsOrderPlaced())
      return false;

   if(!isTimeToOpenOperation())
      return false;

   string name=m_position_order.BuyOpenName();
   double volume=m_position_order.OpenNewVolume();
   PrintFormat("%s will be executed with volume: %.2f",name,volume);

   bool result=false;
   if(m_trades_service.ExecuteBuyTrade(volume,name))
     {
      PrintFormat("%s operation executed: true",name);
      m_position_order.ExecutedBuyOpenOperation();
      m_position_order.SetPrice(m_trades_service.RequestPrice());

      result=true;
     }
   else
      PrintFormat("%s operation executed: false",name);

   return result;
  }
//+------------------------------------------------------------------+
//| Open a Sell Position Order
//+------------------------------------------------------------------+
bool CTradesController::PositionSellOpen()
  {
   if(!m_position_order.IsTradeEnable())
      return false;

   if(m_position_order.IsOrderPlaced())
      return false;

   if(!isTimeToOpenOperation())
      return false;

   string name=m_position_order.SellOpenName();
   double volume=m_position_order.OpenNewVolume();
   PrintFormat("%s will be executed with volume: %.2f",name,volume);

   bool result=false;
   if(m_trades_service.ExecuteSellTrade(volume,name))
     {
      PrintFormat("%s operation executed: true",name);
      m_position_order.ExecutedSellOpenOperation();
      m_position_order.SetPrice(m_trades_service.RequestPrice());

      result=true;
     }
   else
      PrintFormat("%s operation executed: false",name);

   return result;
  }
//+------------------------------------------------------------------+
//| Close a Buy Position Order
//+------------------------------------------------------------------+
bool CTradesController::PositionBuyClose()
  {
   if(!m_position_order.IsOnBuyTrade())
      return false;

   string name=m_position_order.BuyCloseName();
   double volume=m_position_order.CloseVolume();
   PrintFormat("%s will be executed with volume: %.2f",name,volume);

   bool result=false;
   if(m_trades_service.ExecuteSellTrade(volume,name))
     {
      PrintFormat("%s operation executed: true",name);
      m_position_order.ExecutedBuyCloseOperation();
      m_take_profit_order.SetToBeDeleted();
      m_stop_loss_order.SetToBeDeleted();

      result=true;
     }
   else
      PrintFormat("%s operation executed: false",name);

   return result;
  }
//+------------------------------------------------------------------+
//| Close a Sell Position Order
//+------------------------------------------------------------------+
bool CTradesController::PositionSellClose()
  {
   if(!m_position_order.IsOnSellTrade())
      return false;

   string name=m_position_order.SellCloseName();
   double volume=m_position_order.CloseVolume();
   PrintFormat("%s will be executed with volume: %.2f",name,volume);

   bool result=false;
   if(m_trades_service.ExecuteBuyTrade(volume,name))
     {
      PrintFormat("%s operation executed: true",name);
      m_position_order.ExecutedSellCloseOperation();
      m_take_profit_order.SetToBeDeleted();
      m_stop_loss_order.SetToBeDeleted();

      result=true;
     }
   else
      PrintFormat("%s operation executed: false",name);

   return result;
  }
//+------------------------------------------------------------------+
//| Place Take Profit Order
//+------------------------------------------------------------------+
bool CTradesController::VerifyIfPlaceTakeProfitOrder()
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
//| Place Stop Loss Order
//+------------------------------------------------------------------+
bool CTradesController::VerifyIfPlaceStopLossOrder()
  {
   if(!m_stop_loss_order.IsValidToPlacedOrder())
      return false;

   string name=m_stop_loss_order.BuySellOpenName();
   double positionVolume=m_position_order.Volume();
   double stopLossPrice=m_stop_loss_order.CalculateStopLossPrice(m_trades_service);

   PrintFormat("%s will be executed the stop loss with price: %.2f",name,stopLossPrice);

   bool result=false;
   if(m_trades_service.ExecuteBuySellStop(m_position_order.IsOnBuyTrade(),positionVolume,stopLossPrice,name))
     {
      PrintFormat("%s operation executed: true",name);
      m_stop_loss_order.ExecutedPlaceStopLossOrder();

      result=true;
     }
   else
      PrintFormat("%s operation executed: false",name);

   return result;
  }
//+------------------------------------------------------------------+
//| Delete the take profit ticket
//+------------------------------------------------------------------+
bool CTradesController::VerifyIfDeleteTakeProfitOrder()
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
//| Delete the stop loss ticket
//+------------------------------------------------------------------+
bool CTradesController::VerifyIfDeleteStopLossOrder()
  {
   if(!m_stop_loss_order.IsOrderNeedToBeRemoved())
      return  false;

   string name=m_stop_loss_order.BuySellCloseName();
   ulong ticket=m_stop_loss_order.Ticket();

   PrintFormat("%s will delete stop loss order with the ticket: %d",name,ticket);

   bool result=false;
   if(m_trades_service.ExecuteOrderDelete(ticket,name))
     {
      PrintFormat("%s operation executed: true",name);

      if(m_stop_loss_order.IsBuyStopLoss())
         m_trades_service.PlaySellSound();
      if(m_stop_loss_order.IsSellStopLoss())
         m_trades_service.PlayBuySound();

      m_stop_loss_order.ExecutedDeleteStopLossOrder();
      result=true;
     }
   else
      PrintFormat("%s operation executed: false",name);

   return result;
  }
//+------------------------------------------------------------------+
//| Destroy the tick of Take Profit or Stop Loss if one was executed
//+------------------------------------------------------------------+
bool CTradesController::VerifyIfDestroyTpSlWhenExecutedByMetatrader(ulong ticket)
  {
   bool existTakeProfitTicket=m_take_profit_order.VerifyIfExistTicket(ticket);
   bool existStopLossTicket=m_stop_loss_order.VerifyIfExistTicket(ticket);

   if(existTakeProfitTicket)
     {
      m_take_profit_order.ExecutedDeleteTakeProfitOrder();
      m_stop_loss_order.SetToBeDeleted();

      m_take_profit_order.UpdateTakeProfitOperations();
      m_take_profit_order.DisablePositionOnMaxTakeProfitOperations();
     }

   if(existStopLossTicket)
     {
      m_take_profit_order.SetToBeDeleted();
      m_stop_loss_order.ExecutedDeleteStopLossOrder();
     }

   if(existTakeProfitTicket)
      m_position_order.ResetNextVolumeToInitialVolume();

   if(existTakeProfitTicket || existStopLossTicket)
     {
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
void CTradesController::VerifyIfLoadTakeProfitTicket()
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
//| Try to load stop loss ticket
//+------------------------------------------------------------------+
void CTradesController::VerifyIfLoadStopLossTicket()
  {
   if(m_position_order.IsOnTradeOperation() && !m_stop_loss_order.IsTicketLoaded())
     {
      string name=m_stop_loss_order.BuySellOpenName();

      ulong ticket=m_trades_service.TryToLoadOrderTicket(name);
      if(ticket!=0)
         m_stop_loss_order.LoadTicket(ticket);
     }
  }
//+------------------------------------------------------------------+
//| Reset everything to Default
//+------------------------------------------------------------------+
void CTradesController::ResetToDefault()
  {
   m_position_order.ResetToDefault();
   m_take_profit_order.ResetToDefault();
   m_stop_loss_order.ResetToDefault();
  }
//+------------------------------------------------------------------+
//| Verify if can start to open new operations
//+------------------------------------------------------------------+
bool CTradesController::isTimeToOpenOperation()
  {
   datetime start=m_time.IntToDatetime(m_time_start_hour,m_time_start_minute);
   datetime end=m_time.IntToDatetime(m_time_end_hour,m_time_end_minute);

   return m_time.TimeTradeServerBetween(start,end);
  }
//+------------------------------------------------------------------+
