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
   void              InitTradesControllers(CTakeProfitController *takeProfitController,CStopLossController *stopLossController);

   void              AddTradesService(CTradesService *tradesService) { m_trades_service=tradesService; }

   void              ExecutedClosedOperationByMetatrader();

   CPositionOrder    *PositionOrder() { return m_position_order; }

   bool              BuyOpen(bool initializeTpSl);
   bool              SellOpen(bool initializeTpSl);
   bool              BuyClose();
   bool              SellClose();

   bool              TradeStart();
   bool              TradeStop();
   bool              ModifyTakeProfit();
   bool              ModifyStopLoss();

   void              ResetToDefault();

private:

   bool              isValidToOpenBuyOperation();
   bool              isValidToOpenSellOperation();
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
   delete m_position_order;
  }
//+------------------------------------------------------------------+
//| Init CTrades
//+------------------------------------------------------------------+
CPositionController::InitTrade(bool enableTrade,double initialVolume)
  {
   m_position_order.InitVolume(initialVolume);
  }
//+------------------------------------------------------------------+
//| Init the trades martingale
//+------------------------------------------------------------------+
void CPositionController::InitMartingale(int martingale,int maxMartingaleOperations)
  {
   m_position_order.InitMartingale(martingale,maxMartingaleOperations);
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
//| Executed closed operation by metatrader
//+------------------------------------------------------------------+
void CPositionController::ExecutedClosedOperationByMetatrader()
  {
   m_position_order.ResetVolumeToZero();
   m_position_order.ExecutedBuyCloseOperation();
   m_position_order.ExecutedSellCloseOperation();
  }
//+------------------------------------------------------------------+
//| Open a Buy Position Order
//+------------------------------------------------------------------+
bool CPositionController::BuyOpen(bool initializeTpSl)
  {
   if(!isValidToOpenBuyOperation())
      return false;

   if(initializeTpSl)
     {
      m_take_profit_controller.ResetToDefault();
      m_stop_loss_controller.ResetToDefault();
     }

   string name=m_position_order.BuyOpenName();
   double volume=m_position_order.OpenNewVolume();
   PrintFormat("%s will be executed with volume: %.2f",name,volume);

   bool result=false;
   if(m_trades_service.ExecuteBuyTrade(volume,name))
     {
      PrintFormat("%s operation executed: true",name);
      m_position_order.ExecutedBuyOpenOperation();
      m_position_order.SetPrice(m_trades_service.RequestPrice());

      m_take_profit_controller.SetToCreateNewTakeProfit();
      m_stop_loss_controller.SetToCreateNewStop();

      result=true;
     }
   else
      PrintFormat("%s operation executed: false",name);

   return result;
  }
//+------------------------------------------------------------------+
//| Open a Sell Position Order
//+------------------------------------------------------------------+
bool CPositionController::SellOpen(bool initializeTpSl)
  {
   if(!isValidToOpenSellOperation())
      return false;

   if(initializeTpSl)
     {
      m_take_profit_controller.ResetToDefault();
      m_stop_loss_controller.ResetToDefault();
     }

   string name=m_position_order.SellOpenName();
   double volume=m_position_order.OpenNewVolume();
   PrintFormat("%s will be executed with volume: %.2f",name,volume);

   bool result=false;
   if(m_trades_service.ExecuteSellTrade(volume,name))
     {
      PrintFormat("%s operation executed: true",name);
      m_position_order.ExecutedSellOpenOperation();
      m_position_order.SetPrice(m_trades_service.RequestPrice());

      m_take_profit_controller.SetToCreateNewTakeProfit();
      m_stop_loss_controller.SetToCreateNewStop();

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

      m_take_profit_controller.SetToDeleteAllTakeProfit();
      m_stop_loss_controller.SetToDeleteAllStopLoss();

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

      m_take_profit_controller.SetToDeleteAllTakeProfit();
      m_stop_loss_controller.SetToDeleteAllStopLoss();

      result=true;
     }
   else
      PrintFormat("%s operation executed: false",name);

   return result;
  }
//+------------------------------------------------------------------+
//| Start a trade                                                                
//+------------------------------------------------------------------+
bool CPositionController::TradeStart()
  {
   if(m_position_order.IsOnTradeOperation())
     {
      string warningMsg="START operation was NOT executed. You are already in operation!";
      Print(warningMsg);
      MessageBox(warningMsg,"Warning",MB_OK);
      return false;
     }

   if(m_position_order.IsBuyTradeEnable() && m_position_order.IsSellTradeEnable())
     {
      string warningMsg="START operation was NOT executed. Please specify only BUY or SELL operation to use the Start operation";
      Print(warningMsg);
      MessageBox(warningMsg,"Warning",MB_OK);
      return false;
     }

   if(!m_position_order.IsBuyTradeEnable() && m_position_order.IsSellTradeEnable())
      SellOpen();

   if(m_position_order.IsBuyTradeEnable() && !m_position_order.IsSellTradeEnable())
      BuyOpen();

   Print("********** Executed START operation! **********");
   return true;
  }
//+------------------------------------------------------------------+
//| Stop a trade                                                                
//+------------------------------------------------------------------+
bool CPositionController::TradeStop()
  {
   if(m_position_order.IsOnTradeOperation())
     {
      string warningMsg="STOP operation was NOT executed. You are not in operation!";
      Print(warningMsg);
      MessageBox(warningMsg,"Warning",MB_OK);
      return false;
     }

   if(m_position_order.IsOnBuyTrade())
      BuyClose();

   if(m_position_order.IsOnSellTrade())
      SellClose();

   Print("********** Executed STOP operation! **********");
   return true;
  }
//+------------------------------------------------------------------+
//| Modify Take Profit                                                             
//+------------------------------------------------------------------+
bool CPositionController::ModifyTakeProfit()
  {
   return false;
  }
//+------------------------------------------------------------------+
//| Modify Stop Loss                                                            
//+------------------------------------------------------------------+
bool CPositionController::ModifyStopLoss()
  {
   return false;
  }
//+------------------------------------------------------------------+
//| Reset everything to Default
//+------------------------------------------------------------------+
void CPositionController::ResetToDefault()
  {
   m_position_order.ResetToDefault();
  }
//+------------------------------------------------------------------+
//| Is valid to open a operation?
//+------------------------------------------------------------------+
bool CPositionController::isValidToOpenBuyOperation()
  {
   if(!m_position_order.IsBuyTradeEnable())
      return false;

   if(m_position_order.IsOrderPlaced())
      return false;

   if(m_take_profit_controller.VerifyIfHasOpenTakeProfit())
      return false;

   if(m_stop_loss_controller.VerifyIfHasOpenStop())
      return false;

   return true;
  }
//+------------------------------------------------------------------+
//| Is valid to open a operation?
//+------------------------------------------------------------------+
bool CPositionController::isValidToOpenSellOperation()
  {
   if(!m_position_order.IsSellTradeEnable())
      return false;

   if(m_position_order.IsOrderPlaced())
      return false;

   if(m_take_profit_controller.VerifyIfHasOpenTakeProfit())
      return false;

   if(m_stop_loss_controller.VerifyIfHasOpenStop())
      return false;

   return true;
  }
//+------------------------------------------------------------------+
