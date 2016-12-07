//+------------------------------------------------------------------+
//|                                                StopLossOrder.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Frederico Benevides"
#property link      "fredbene@gmail.com"

#include <MyLibs\Trades\TradesControllerInjection.mqh>
//+------------------------------------------------------------------+
//| Class to map the stop loss order
//+------------------------------------------------------------------+
class CStopLossOrder
  {
   CTradesControllerInjection *m_trades_controller_injection;
   //CPositionOrder   *m_position_order;

   CStopLossProfile *m_stop_loss_profile;

   string            m_buy_open_name;
   string            m_sell_open_name;
   string            m_buy_close_name;
   string            m_sell_close_name;

   bool              m_open_on_buy_trade;
   bool              m_open_on_sell_trade;

   double            m_points;

public:

                     CStopLossOrder(string tradeName,CTradesControllerInjection *tradesControllerInjection);
                    ~CStopLossOrder();
  };
//+------------------------------------------------------------------+
//| Constructor
//+------------------------------------------------------------------+
CStopLossOrder::CStopLossOrder(string tradeName,CTradesControllerInjection *tradesControllerInjection)
  {
   //m_buy_open_name=tradeName+"::TradeBuyOpen::SL()";
   //m_sell_open_name=tradeName+"::TradeSellOpen::SL()";
   //m_buy_close_name=tradeName+"::TradeBuyClose::DSL()";
   //m_sell_close_name=tradeName+"::TradeSellClose::DSL()";

   m_trades_controller_injection=tradesControllerInjection;
  }
//+------------------------------------------------------------------+
//| Destructor
//+------------------------------------------------------------------+
CStopLossOrder::~CStopLossOrder()
  {
   //delete m_stop_loss_profile;
  }
//+------------------------------------------------------------------+
