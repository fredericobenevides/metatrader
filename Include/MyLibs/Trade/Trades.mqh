//+------------------------------------------------------------------+
//|                                                   TradeModel.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Frederico Benevides"
#property link      "fredbene@gmail.com"

#include <Trade\Trade.mqh>

#include <MyLibs\Utils\Time.mqh>
//+------------------------------------------------------------------+
//| Model for a Trade Operation
//+------------------------------------------------------------------+
class CTrades
  {
   CTrade            m_trade;
   CTime             Time;
   bool              m_initial_volume;

   // current operation
   int               m_ticket_current_deal;
   double            m_current_volume;
   bool              m_is_on_buy_trade;
   bool              m_is_on_sell_trade;

   // take profit
   double            m_take_profit_points;
   double            m_take_profit_price;

   // stop loss
   double            m_stop_loss_points;
   double            m_stop_loss_price;

   // trades time
   int               m_time_start_hour;
   int               m_time_start_minute;
   int               m_time_end_hour;
   int               m_time_end_minute;

public:
                     CTrades();
   void              Init(double initialVolume,double takeProfit,double stopLoss);
   void              InitTradesTime(int startHour,int startMinute,int endHour,int endMinute);

   void              Buy(int ticket,double volume);
   void              Sell(int ticket,double volume);

   bool              IsOnTradeOperation();
   bool              IsTimeToOpenOperation();
   double            CurrentVolume();
  };
//+------------------------------------------------------------------+
//| Constructor
//+------------------------------------------------------------------+
CTrades::CTrades()
  {
   m_is_on_buy_trade=false;
   m_is_on_sell_trade=false;
  }
//+------------------------------------------------------------------+
//| Init CTrades
//+------------------------------------------------------------------+
CTrades::Init(double initialVolume,double takeProfit,double stopLoss)
  {
   m_initial_volume=initialVolume;
   m_current_volume=m_initial_volume;

   m_take_profit_points=takeProfit;
   m_stop_loss_points=stopLoss;
  }
//+------------------------------------------------------------------+
//| Init Trade's Time
//+------------------------------------------------------------------+
CTrades::InitTradesTime(int startHour,int startMinute,int endHour,int endMinute)
  {
   m_time_start_hour=startHour;
   m_time_start_minute=startMinute;
   m_time_end_hour=endHour;
   m_time_end_minute=endMinute;
  }
//+------------------------------------------------------------------+
//| Buy more or sell less accordling operation.
//+------------------------------------------------------------------+
void CTrades::Buy(int ticket,double volume)
  {
   m_ticket_current_deal=ticket;

   if(m_is_on_buy_trade)
      m_current_volume+=volume;

   if(m_is_on_sell_trade)
      m_current_volume-=volume;

// buy close a sell operation
   if(m_current_volume==0)
      m_is_on_sell_trade=false;

// still buying.
   if(m_current_volume>0)
      m_is_on_buy_trade=true;

// now it's selling
   if(m_current_volume<0)
      m_is_on_sell_trade=true;
  }
//+------------------------------------------------------------------+
//| Sell more or buy less accordling operation.
//+------------------------------------------------------------------+
void CTrades::Sell(int ticket,double volume)
  {
   if(m_is_on_buy_trade)
      m_current_volume-=volume;

   if(m_is_on_sell_trade)
      m_current_volume+=volume;

// sell close a buy operation
   if(m_current_volume==0)
      m_is_on_buy_trade=false;

// still selling.
   if(m_current_volume>0)
      m_is_on_sell_trade=true;

// now it's buying
   if(m_current_volume<0)
      m_is_on_buy_trade=true;
  }
//+------------------------------------------------------------------+
//| Verify if is on trade operation
//+------------------------------------------------------------------+
bool CTrades::IsOnTradeOperation(void)
  {
   return m_is_on_buy_trade || m_is_on_sell_trade;
  }
//+------------------------------------------------------------------+
//| Verify if can start to open new operations
//+------------------------------------------------------------------+
bool CTrades::IsTimeToOpenOperation()
  {
   datetime start=Time.IntToDatetime(m_time_start_hour,m_time_start_minute);
   datetime end=Time.IntToDatetime(m_time_end_hour,m_time_end_minute);

   return Time.TimeTradeServerBetween(start,end);
  }
//+------------------------------------------------------------------+
//| Returns the current volume
//+------------------------------------------------------------------+
double CTrades::CurrentVolume()
  {
   return m_current_volume;
  }
//+------------------------------------------------------------------+
