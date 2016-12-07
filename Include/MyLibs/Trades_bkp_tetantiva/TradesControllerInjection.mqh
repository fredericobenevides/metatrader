//+------------------------------------------------------------------+
//|                                    TradesControllerInjection.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Frederico Benevides"
#property link      "fredbene@gmail.com"

#include <MyLibs\Trades\PositionController.mqh>
#include <MyLibs\Trades\TakeProfitController.mqh>
#include <MyLibs\Trades\StopLossController.mqh>
//+------------------------------------------------------------------+
//| Class to inject trades controller
//+------------------------------------------------------------------+
class CTradesControllerInjection
  {
   CPositionController *m_position_controller;
   CTakeProfitController *m_take_profit_controller;
   CStopLossController *m_stop_loss_controller;

public:
                     CTradesControllerInjection(string teste);
                    ~CTradesControllerInjection();

   void              Init(CPositionController *positionController,CTakeProfitController *takeProfitController,CStopLossController *stopLossController);

   CPositionController *PositionController() { return m_position_controller; }
   CTakeProfitController *TakeProfitController() { return m_take_profit_controller; }
   CStopLossController *StopLossController() { return m_stop_loss_controller; }
  };
//+------------------------------------------------------------------+
//| Constructor
//+------------------------------------------------------------------+
CTradesControllerInjection::CTradesControllerInjection(string teste)
  {
  }
//+------------------------------------------------------------------+
//| Desstructor
//+------------------------------------------------------------------+
CTradesControllerInjection::~CTradesControllerInjection()
  {
   delete m_position_controller;
   delete m_take_profit_controller;
   delete m_stop_loss_controller;
  }
//+------------------------------------------------------------------+
//| Init with the controller
//+------------------------------------------------------------------+
void CTradesControllerInjection::Init(CPositionController *positionController,CTakeProfitController *takeProfitController,CStopLossController *stopLossController)
  {
   m_position_controller=positionController;
   m_take_profit_controller=takeProfitController;
   m_stop_loss_controller=stopLossController;
  }
//+------------------------------------------------------------------+
