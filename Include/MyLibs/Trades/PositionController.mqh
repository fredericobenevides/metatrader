//+------------------------------------------------------------------+
//|                                           PositionController.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Frederico Benevides"
#property link      "fredbene@gmail.com"

#include <MyLibs\Trades\PositionOrder.mqh>

#include <MyLibs\Utils\Time.mqh>

#include <MyLibs\Trades\TakeProfitController.mqh>
#include <MyLibs\Trades\StopLossController.mqh>
//+------------------------------------------------------------------+
//| Controller of Position Orders
//+------------------------------------------------------------------+
class CPositionController
  {
   CTakeProfitController *m_take_profit_controller;
   CStopLossController *m_stop_loss_controller;
   CTradesService   *m_trades_service;

   CPositionOrder   *m_position_order;
   CTime             m_time;

   // trades time
   int               m_time_start_hour;
   int               m_time_start_minute;
   int               m_time_end_hour;
   int               m_time_end_minute;

public:
                     CPositionController(string tradeName);
                    ~CPositionController();

   void              InitTrade(bool enableTrade,double initialVolume);
   void              InitMartingale(int martingale,int maxMartingaleOperations);
   void              InitTradesTime(int startHour,int startMinute,int endHour,int endMinute);
   void              InitTradesControllers(CTakeProfitController *takeProfitController,CStopLossController *stopLossController);

   void              AddTradesService(CTradesService *tradesService) { m_trades_service=tradesService; }

   CPositionOrder    *PositionOrder() { return m_position_order; }

   bool              BuyOpen();
   bool              SellOpen();
   bool              BuyClose();
   bool              SellClose();

   void              ResetToDefault();

private:

   bool              isTimeToOpenOperation();
  };
//+------------------------------------------------------------------+
//| Constructor
//+------------------------------------------------------------------+
CPositionController::CPositionController(string tradeName)
  {
   m_position_order=new CPositionOrder(tradeName);
  }
//+------------------------------------------------------------------+
//| Destructor
//+------------------------------------------------------------------+
CPositionController::~CPositionController()
  {
//delete m_trades_service;
   delete m_position_order;
  }
//+------------------------------------------------------------------+
//| Init CTrades
//+------------------------------------------------------------------+
CPositionController::InitTrade(bool enableTrade,double initialVolume)
  {
   m_position_order.InitTrade(enableTrade,initialVolume);
  }
//+------------------------------------------------------------------+
//| Init the trades martingale
//+------------------------------------------------------------------+
void CPositionController::InitMartingale(int martingale,int maxMartingaleOperations)
  {
   m_position_order.InitMartingale(martingale,maxMartingaleOperations);
  }
//+------------------------------------------------------------------+
//| Init Trade's Time
//+------------------------------------------------------------------+
void CPositionController::InitTradesTime(int startHour,int startMinute,int endHour,int endMinute)
  {
   m_time_start_hour=startHour;
   m_time_start_minute=startMinute;
   m_time_end_hour=endHour;
   m_time_end_minute=endMinute;
  }
//+------------------------------------------------------------------+
//| Init controllers
//+------------------------------------------------------------------+
void CPositionController::InitTradesControllers(CTakeProfitController *takeProfitController,CStopLossController *stopLossController)
  {
   m_take_profit_controller=takeProfitController;
   m_stop_loss_controller=stopLossController;
  }
//+------------------------------------------------------------------+
//| Open a Buy Position Order
//+------------------------------------------------------------------+
bool CPositionController::BuyOpen()
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

      //m_stop_loss_order.RestartProfile();

      result=true;
     }
   else
      PrintFormat("%s operation executed: false",name);

   return result;
  }
//+------------------------------------------------------------------+
//| Open a Sell Position Order
//+------------------------------------------------------------------+
bool CPositionController::SellOpen()
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

      //m_stop_loss_order.RestartProfile();

      result=true;
     }
   else
      PrintFormat("%s operation executed: false",name);

   return result;
  }
//+------------------------------------------------------------------+
//| Close a Buy Position Order
//+------------------------------------------------------------------+
bool CPositionController::BuyClose()
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
      //m_take_profit_order.SetToBeDeleted();
      //m_stop_loss_order.SetToBeDeleted();

      result=true;
     }
   else
      PrintFormat("%s operation executed: false",name);

   return result;
  }
//+------------------------------------------------------------------+
//| Close a Sell Position Order
//+------------------------------------------------------------------+
bool CPositionController::SellClose()
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
      //m_take_profit_order.SetToBeDeleted();
      //m_stop_loss_order.SetToBeDeleted();

      result=true;
     }
   else
      PrintFormat("%s operation executed: false",name);

   return result;
  }
//+------------------------------------------------------------------+
//| Reset everything to Default
//+------------------------------------------------------------------+
void CPositionController::ResetToDefault()
  {
   m_position_order.ResetToDefault();
  }
//+------------------------------------------------------------------+
//| Verify if can start to open new operations
//+------------------------------------------------------------------+
bool CPositionController::isTimeToOpenOperation()
  {
   datetime start=m_time.IntToDatetime(m_time_start_hour,m_time_start_minute);
   datetime end=m_time.IntToDatetime(m_time_end_hour,m_time_end_minute);

   return m_time.TimeTradeServerBetween(start,end);
  }
//+------------------------------------------------------------------+
