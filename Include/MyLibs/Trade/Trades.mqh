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

   // trade info
   string            m_name;
   bool              m_enable_trade;

   // volumes
   double            m_initial_volume;
   double            m_current_volume;
   double            m_next_volume;
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

   bool              BuyOpen(string methodName);
   bool              SellOpen(string methodName);
   bool              BuyClose(string methodName);
   bool              SellClose(string methodName);

   void              UpdateNextVolumeUsingMartingale(string methodName);
   void              UpdateVolumeFromNextVolume();
   void              UpdateNextVolumeFromInitialVolume();
   void              ResetVolumeToZero();

   bool              IsOnTradeOperation();
   bool              IsTimeToOpenOperation();

   void              EnableTrade();
   void              DisableTrade();
   bool              IsTradeEnable();
   void              DisableOnMaxMartingaleOperations();

   bool              IsEnable();
   string            Name();
   double            CurrentVolume();
   double            NextVolume();
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
   m_current_volume=0;
   m_next_volume=initialVolume;

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
//| Open a BUY operation
//+------------------------------------------------------------------+
bool CTrades::BuyOpen(string methodName="BuyOpen()")
  {
   PrintFormat("%s will be executed with volume: %.2f",methodName,m_current_volume);

   bool result=false;
   if(m_trades_service.ExecuteBuyTrade(m_current_volume,methodName))
     {
      PrintFormat("%s operation executed: true",methodName);
      m_is_on_buy_trade=true;
      result=true;
     }
   else
      PrintFormat("%s operation executed: false",methodName);

   return result;
  }
//+------------------------------------------------------------------+
//| Open a SELL operation
//+------------------------------------------------------------------+
bool CTrades::SellOpen(string methodName="SellOpen()")
  {
   PrintFormat("%s will be executed with volume: %.2f",methodName,m_current_volume);

   bool result=false;
   if(m_trades_service.ExecuteSellTrade(m_current_volume,methodName))
     {
      PrintFormat("%s operation executed: true",methodName);
      m_is_on_sell_trade=true;
      result=true;
     }
   else
      PrintFormat("%s operation executed: false",methodName);

   return result;
  }
//+------------------------------------------------------------------+
//| Close a BUY operation
//+------------------------------------------------------------------+
bool CTrades::BuyClose(string methodName="BuyClose()")
  {
   if(!m_is_on_buy_trade)
      return false;

   PrintFormat("%s will be executed with volume: %.2f",methodName,m_current_volume);

   bool result=false;
   if(m_trades_service.ExecuteSellTrade(m_current_volume,methodName))
     {
      PrintFormat("%s operation executed: true",methodName);
      m_is_on_buy_trade=false;
      result=true;
     }
   else
      PrintFormat("%s operation executed: false",methodName);

   return result;
  }
//+------------------------------------------------------------------+
//| Close a SELL operation
//+------------------------------------------------------------------+
bool CTrades::SellClose(string methodName="SellClose()")
  {
   if(!m_is_on_sell_trade)
      return false;

   PrintFormat("%s will be executed with volume: %.2f",methodName,m_current_volume);

   bool result=false;
   if(m_trades_service.ExecuteBuyTrade(m_current_volume,methodName))
     {
      PrintFormat("%s operation executed: true",methodName);
      m_is_on_sell_trade=false;
      result=true;
     }
   else
      PrintFormat("%s operation executed: false",methodName);

   return result;
  }
//+------------------------------------------------------------------+
//| Update the volume based on martingale
//+------------------------------------------------------------------+
void CTrades::UpdateNextVolumeUsingMartingale(string methodName="UpdateNextVolumeUsingMartingale")
  {
// current volume is not setup, use initial volume
   if(m_current_volume==0)
      m_current_volume=m_initial_volume;

   double volumeCalculated=NormalizeDouble(m_current_volume*m_martingale,2);

   PrintFormat("%s using martingale (%.2f) to calculate the volume. Last used volume: (%.2f). Next Volume: (%.2f)",methodName,m_martingale,m_current_volume,volumeCalculated);
   m_next_volume=volumeCalculated;
  }
//+------------------------------------------------------------------+
//| Update volume using the volume from next volume
//+------------------------------------------------------------------+
void CTrades::UpdateVolumeFromNextVolume()
  {
   m_current_volume=m_next_volume;
  }
//+------------------------------------------------------------------+
//| Update the next volume to use initial volume
//+------------------------------------------------------------------+
void CTrades::UpdateNextVolumeFromInitialVolume()
  {
   m_next_volume=m_initial_volume;
  }
//+------------------------------------------------------------------+
//| Reset the current volume to value 0
//+------------------------------------------------------------------+
void CTrades::ResetVolumeToZero()
  {
   m_current_volume=0;
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
//| Disable the trade if is on max martingale operations
//| Formula: (Martingale^MaxOperations)*InitialVolume
//+------------------------------------------------------------------+
void CTrades::DisableOnMaxMartingaleOperations()
  {
   int digits=(int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS);

   double powValue=pow(m_martingale,(m_max_martingale_operations-1));
   double maxVolume=NormalizeDouble(powValue*m_initial_volume,digits);

   if(m_current_volume>maxVolume)
      DisableTrade();
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
//| Returns the next volume
//+------------------------------------------------------------------+
double CTrades::NextVolume()
  {
   return m_next_volume;
  }
//+------------------------------------------------------------------+
