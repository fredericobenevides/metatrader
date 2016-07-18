//+------------------------------------------------------------------+
//|                                                   TradeModel.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Frederico Benevides"
#property link      "fredbene@gmail.com"

#include <Trade\Trade.mqh>
//+------------------------------------------------------------------+
//| Model for a Trade Operation
//+------------------------------------------------------------------+
class CTrades
  {
   CTrade            m_trade;

   // current operation
   int               m_ticket_current_deal;
   double            m_current_trade_volume;
   bool              m_is_on_buy_trade;
   bool              m_is_on_sell_trade;

public:
                     CTrades(void);

   void              Buy(int ticket,double volume);
   void              Sell(int ticket,double volume);
   bool              IsOnTradeOperation();
  };
//+------------------------------------------------------------------+
//| Constructor
//+------------------------------------------------------------------+
CTrades::CTrades(void)
  {
//--- set MagicNumber for your orders identification
   int MagicNumber=123456;
   m_trade.SetExpertMagicNumber(MagicNumber);
//--- set available slippage in points when buying/selling
   int deviation=50;
   m_trade.SetDeviationInPoints(deviation);
//--- order filling mode, the mode allowed by the server should be used
   m_trade.SetTypeFilling(ORDER_FILLING_RETURN);
//--- logging mode: it would be better not to declare this method at all, the class will set the best mode on its own
   m_trade.LogLevel(1);
//--- what function is to be used for trading: true - OrderSendAsync(), false - OrderSend()
   m_trade.SetAsyncMode(true);

   m_is_on_buy_trade=false;
   m_is_on_sell_trade=false;
  }
//+------------------------------------------------------------------+
//| Buy more or sell less accordling operation.
//+------------------------------------------------------------------+
void CTrades::Buy(int ticket,double volume)
  {
   m_ticket_current_deal=ticket;

   if(m_is_on_buy_trade)
      m_current_trade_volume+=volume;

   if(m_is_on_sell_trade)
      m_current_trade_volume-=volume;

// buy close a sell operation
   if(m_current_trade_volume==0)
      m_is_on_sell_trade=false;

// still buying.
   if(m_current_trade_volume>0)
      m_is_on_buy_trade=true;
  }
//+------------------------------------------------------------------+
//| Sell more or buy less accordling operation.
//+------------------------------------------------------------------+
void CTrades::Sell(int ticket,double volume)
  {
   if(m_is_on_buy_trade)
      m_current_trade_volume-=volume;

   if(m_is_on_sell_trade)
      m_current_trade_volume+=volume;

// sell close a buy operation
   if(m_current_trade_volume==0)
      m_is_on_buy_trade=false;

// still selling.
   if(m_current_trade_volume>0)
      m_is_on_sell_trade=true;
  }
//+------------------------------------------------------------------+
//| Verify if is on trade operation
//+------------------------------------------------------------------+
bool CTrades::IsOnTradeOperation(void)
  {
   return m_is_on_buy_trade || m_is_on_sell_trade;
  }
//+------------------------------------------------------------------+
