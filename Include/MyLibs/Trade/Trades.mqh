//+------------------------------------------------------------------+
//|                                                   TradeModel.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Frederico Benevides"
#property link      "fredbene@gmail.com"

#include <Trade\Trade.mqh>
#include <MyLibs\Trade\TradesService.mqh>

#include <MyLibs\Utils\Time.mqh>
//+------------------------------------------------------------------+
//| Model for a Trade Operation
//+------------------------------------------------------------------+
class CTrades
  {
   CTrade            m_trade;
   CTime             Time;
   CTradesService   *m_trades_service;

   // current operation
   string            m_name;
   bool              m_enable_trade;
   double            m_initial_volume;
   double            m_current_volume;
   int               m_ticket_current_deal;

   // martingale
   int               m_martingale;
   int               m_max_martingale_operations; // Default max operations (Martingale^MaxOperations)*InitialVolume   

   //--- type of operation
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
                     CTrades(string name);
                    ~CTrades();

   void              InitTrade(bool enableTrade,double initialVolume,double takeProfit,double stopLoss);
   void              InitMartingale(int martingale,int maxMartingaleOperations);
   void              InitTradesTime(int startHour,int startMinute,int endHour,int endMinute);

   void              Buy(int ticket,double volume);
   void              Sell(int ticket,double volume);

   bool              BuyOpen();
   bool              SellOpen();
   bool              BuyClose();
   bool              SellClose();

   bool              IsOnTradeOperation();
   bool              IsTimeToOpenOperation();

   void              EnableTrade();
   void              DisableTrade();
   bool              IsTradeEnable();

   string            Name();
   double            CurrentVolume();
  };
//+------------------------------------------------------------------+
//| Constructor
//+------------------------------------------------------------------+
CTrades::CTrades(string name="trade")
  {
   m_name=name;

   m_is_on_buy_trade=false;
   m_is_on_sell_trade=false;
   m_trades_service=new CTradesService();
  }
//+------------------------------------------------------------------+
//| Destructor
//+------------------------------------------------------------------+
CTrades::~CTrades()
  {
   delete m_trades_service;
  }
//+------------------------------------------------------------------+
//| Init CTrades
//+------------------------------------------------------------------+
CTrades::InitTrade(bool enableTrade,double initialVolume,double takeProfit,double stopLoss)
  {
   m_enable_trade=enableTrade;

   m_initial_volume=initialVolume;
   m_current_volume=m_initial_volume;

   m_take_profit_points=takeProfit;
   m_stop_loss_points=stopLoss;
  }
//+------------------------------------------------------------------+
//| Init the trades martingale
//+------------------------------------------------------------------+
void CTrades::InitMartingale(int martingale,int maxMartingaleOperations)
  {
   m_martingale=martingale;
   m_max_martingale_operations=maxMartingaleOperations;
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
//| Buy Open Operations
//+------------------------------------------------------------------+
bool CTrades::BuyOpen()
  {
   if(!IsTimeToOpenOperation())
      return false;

   string methodName=m_name+"::TradeBuyOpen()";
   PrintFormat("%s will be executed",methodName);

   if(m_trades_service.ExecuteBuyTrade(this,methodName))
     {
      m_is_on_buy_trade=true;
      PrintFormat("%s operation executed: true",methodName);
     }

   PrintFormat("%s operation executed: false",methodName);
   return false;
  }
//+------------------------------------------------------------------+
//| Sell Open Operations
//+------------------------------------------------------------------+
bool CTrades::SellOpen()
  {
   if(!IsTimeToOpenOperation())
      return false;

   string methodName=m_name+"::TradeSellOpen()";
   PrintFormat("%s will be executed",methodName);

   if(m_trades_service.ExecuteBuyTrade(this,methodName))
     {
      m_is_on_sell_trade=true;
      PrintFormat("%s operation executed: true",methodName);
     }

   PrintFormat("%s operation executed: false",methodName);
   return false;
  }
//+------------------------------------------------------------------+
//| Buy Close Operations
//+------------------------------------------------------------------+
bool CTrades::BuyClose()
  {
   if(!IsTimeToOpenOperation())
      return false;

   string methodName=m_name+"::TradeBuyClose()";
   PrintFormat("%s will be executed",methodName);

   if(m_trades_service.ExecuteBuyTrade(this,methodName))
     {
      m_is_on_buy_trade=false;
      PrintFormat("%s operation executed: true",methodName);
     }

   PrintFormat("%s operation executed: false",methodName);
   return false;
  }
//+------------------------------------------------------------------+
//| Sell Close Operations
//+------------------------------------------------------------------+
bool CTrades::SellClose()
  {
   if(!IsTimeToOpenOperation())
      return false;

   string methodName=m_name+"::TradeSellClose()";
   PrintFormat("%s will be executed",methodName);

   if(m_trades_service.ExecuteBuyTrade(this,methodName))
     {
      m_is_on_sell_trade=false;
      PrintFormat("%s operation executed: true",methodName);
     }

   PrintFormat("%s operation executed: false",methodName);
   return false;
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
//| Enable trade operation
//+------------------------------------------------------------------+
void CTrades::EnableTrade(void)
  {
   m_enable_trade=true;
  }
//+------------------------------------------------------------------+
//| Disable trade operation
//+------------------------------------------------------------------+
void CTrades::DisableTrade(void)
  {
   m_enable_trade=false;
  }
//+------------------------------------------------------------------+
//| Returns if the trade is enable
//+------------------------------------------------------------------+
bool CTrades::IsTradeEnable(void)
  {
   return m_enable_trade;
  }
//+------------------------------------------------------------------+
//| Returns the trades name
//+------------------------------------------------------------------+
string CTrades::Name()
  {
   return m_name;
  }
//+------------------------------------------------------------------+
//| Returns the current volume
//+------------------------------------------------------------------+
double CTrades::CurrentVolume()
  {
   return m_current_volume;
  }
//+------------------------------------------------------------------+
