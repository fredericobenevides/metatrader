//+------------------------------------------------------------------+
//|                                                   TradeModel.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Frederico Benevides"
#property link      "fredbene@gmail.com"

#include <Trade\Trade.mqh>

#include <MyLibs\Trade\TradesUtils.mqh>
#include <MyLibs\Trade\TradesService.mqh>

#include <MyLibs\Utils\Time.mqh>
//+------------------------------------------------------------------+
//| Model for a Trade Operation
//+------------------------------------------------------------------+
class CTrades
  {
   CTrade            m_trade;
   CTime             m_time;
   CTradesUtils      m_utils;
   CTradesService   *m_trades_service;

   // trade info
   string            m_name;
   bool              m_enable_trade;

   // volumes
   double            m_initial_volume;
   double            m_current_volume;
   double            m_next_volume;

   // result from open trades
   ulong             m_result_ticket_open_trade;
   double            m_result_open_price;

   // martingale
   int               m_martingale;
   int               m_max_martingale_operations;
   double            m_max_volume_martingale_operations;

   //--- type of operation
   bool              m_is_on_buy_trade;
   bool              m_is_on_sell_trade;

   // take profit
   double            m_take_profit_points;
   ulong             m_ticket_take_profit;
   int               m_count_take_profit_operations;
   int               m_max_take_profit_operations;

   // stop loss
   double            m_stop_loss_points;
   ulong             m_ticket_stop_loss;

   // trades time
   int               m_time_start_hour;
   int               m_time_start_minute;
   int               m_time_end_hour;
   int               m_time_end_minute;

public:
                     CTrades(string name);
                    ~CTrades();

   void              InitTrade(bool enableTrade,double initialVolume,double takeProfit,int maxTakeProfitOperations,
                               double stopLoss);
   void              InitMartingale(int martingale,int maxMartingaleOperations);
   void              InitTradesTime(int startHour,int startMinute,int endHour,int endMinute);

   bool              BuyOpen(string methodName);
   bool              SellOpen(string methodName);
   bool              BuyClose(string methodName);
   bool              SellClose(string methodName);

   bool              PlaceTakeProfitOrder(string methodName);
   bool              PlaceStopLossOrder(string methodName);
   bool              DeleteTakeProfitOrder(string methodName);
   bool              DeleteStopLossOrder(string methodName);

   bool              VerifyIfExistTakeProfitTicket(ulong ticket);
   bool              VerifyIfExistStopLossTicket(ulong ticket);

   void              UpdateNextVolumeUsingMartingale(string methodName);
   void              UpdateVolumeFromNextVolume();
   void              UpdateNextVolumeFromInitialVolume();
   void              UpdateCountTakeProfitOperations();

   void              ResetVolumeToZero();
   void              ResetVolumeToZeroIfNextVolumeIsInitialVolume();
   void              ResetNextVolumeToZeroOnMaxMartingale();
   void              ResetNextVolumeToInitialVolumeOnMaxTakeProfit();

   bool              IsOnTradeOperation();
   bool              IsTimeToOpenOperation();

   void              EnableTrade();
   void              DisableTrade();
   bool              IsTradeEnable();

   void              DisableOnMaxMartingaleOperations();
   void              DisableOnMaxTakeProfitOperations();

   bool              IsEnable();
   string            Name();
   double            CurrentVolume();
   double            NextVolume();
   double            TakeProfitPoints();
   double            StopLossPoints();

private:

   double            CalculateTakeProfitPrice();
   double            CalculateStopLossPrice();
   double            CalculateCurrentVolumeWithMaxMartingale();

   void              SaveOpenDealResult();
   void              DeleteOpenDealResult();

   void              SaveTakeProfitTicket();
   void              SaveStopLossTicket();
   void              DeleteTakeProfitTicket();
   void              DeleteStopLossTicket();
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
CTrades::InitTrade(bool enableTrade,double initialVolume,double takeProfit,int maxTakeProfitOperations,
                   double stopLoss)
  {
   m_enable_trade=enableTrade;

   m_initial_volume=initialVolume;
   m_current_volume=0;
   m_next_volume=initialVolume;

   m_take_profit_points=takeProfit;
   m_max_take_profit_operations=maxTakeProfitOperations;

   m_stop_loss_points=stopLoss;
  }
//+------------------------------------------------------------------+
//| Init the trades martingale
//+------------------------------------------------------------------+
void CTrades::InitMartingale(int martingale,int maxMartingaleOperations)
  {
   m_martingale=martingale;
   m_max_martingale_operations=maxMartingaleOperations;
   m_max_volume_martingale_operations=CalculateCurrentVolumeWithMaxMartingale();
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
      SaveOpenDealResult();

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
      SaveOpenDealResult();

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
      DeleteOpenDealResult();

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
      DeleteOpenDealResult();

      result=true;
     }
   else
      PrintFormat("%s operation executed: false",methodName);

   return result;
  }
//+------------------------------------------------------------------+
//| Place Take Profit Order
//+------------------------------------------------------------------+
bool CTrades::PlaceTakeProfitOrder(string methodName)
  {
   if(m_take_profit_points==0.0)
      return false;

   double price=CalculateTakeProfitPrice();
   PrintFormat("%s will be executed the take profit with price: %.2f",methodName,price);

   bool result=false;
   if(m_trades_service.ExecuteBuySellLimit(m_is_on_buy_trade,m_current_volume,price,methodName))
     {
      PrintFormat("%s operation executed: true",methodName);
      SaveTakeProfitTicket();

      result=true;
     }
   else
      PrintFormat("%s operation executed: false",methodName);

   return result;
  }
//+------------------------------------------------------------------+
//| Place Take Profit Order
//+------------------------------------------------------------------+
bool CTrades::PlaceStopLossOrder(string methodName)
  {
   if(m_stop_loss_points==0.0)
      return false;

   double price=CalculateStopLossPrice();
   PrintFormat("%s will be executed the stop loss with price: %.2f",methodName,price);

   bool result=false;
   if(m_trades_service.ExecuteBuySellStop(m_is_on_buy_trade,m_current_volume,price,methodName))
     {
      PrintFormat("%s operation executed: true",methodName);
      SaveStopLossTicket();

      result=true;
     }
   else
      PrintFormat("%s operation executed: false",methodName);

   return result;
  }
//+------------------------------------------------------------------+
//| Delete the take profit ticket
//+------------------------------------------------------------------+
bool CTrades::DeleteTakeProfitOrder(string methodName)
  {
   if(m_ticket_take_profit==0)
      return false;

   PrintFormat("%s will delete take profit order with the ticket: %d",methodName,m_ticket_take_profit);

   bool result=false;
   if(m_trades_service.ExecuteOrderDelete(m_ticket_take_profit,methodName))
     {
      PrintFormat("%s operation executed: true",methodName);
      DeleteTakeProfitTicket();

      result=true;
     }
   else
      PrintFormat("%s operation executed: false",methodName);

   return result;
  }
//+------------------------------------------------------------------+
//| Delete the stop loss ticket
//+------------------------------------------------------------------+
bool CTrades::DeleteStopLossOrder(string methodName)
  {
   if(m_ticket_stop_loss==0)
      return  false;

   PrintFormat("%s will delete stop loss order with the ticket: %d",methodName,m_ticket_stop_loss);

   bool result=false;
   if(m_trades_service.ExecuteOrderDelete(m_ticket_stop_loss,methodName))
     {
      PrintFormat("%s operation executed: true",methodName);
      DeleteStopLossTicket();

      result=true;
     }
   else
      PrintFormat("%s operation executed: false",methodName);

   return result;
  }
//+------------------------------------------------------------------+
//| Verify if the ticket of take profit exist for current operation
//+------------------------------------------------------------------+
bool CTrades::VerifyIfExistTakeProfitTicket(ulong ticket)
  {
   if(ticket==m_ticket_take_profit)
      return true;

   return false;
  }
//+------------------------------------------------------------------+
//|  Verify if the ticket of stop loss exist for current operation
//+------------------------------------------------------------------+
bool CTrades::VerifyIfExistStopLossTicket(ulong ticket)
  {
   if(ticket==m_ticket_stop_loss)
      return true;

   return false;
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
//| Return Take Profit points
//+------------------------------------------------------------------+
double CTrades::TakeProfitPoints()
  {
   return m_take_profit_points;
  }
//+------------------------------------------------------------------+
//| Return Stop Loss points
//+------------------------------------------------------------------+
double CTrades::StopLossPoints()
  {
   return m_stop_loss_points;
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
//| Update the count of take profit operations
//+------------------------------------------------------------------+
void CTrades::UpdateCountTakeProfitOperations()
  {
   m_count_take_profit_operations+=1;
  }
//+------------------------------------------------------------------+
//| Reset the current volume to value 0 and next volume to initial volume
//+------------------------------------------------------------------+
void CTrades::ResetVolumeToZero()
  {
   m_current_volume=0;
   m_next_volume=m_initial_volume;
  }
//+------------------------------------------------------------------+
//| Reset the current volume to value 0 if the next volume has the value of initial volume
//+------------------------------------------------------------------+
void CTrades::ResetVolumeToZeroIfNextVolumeIsInitialVolume()
  {
   if(m_next_volume==m_initial_volume)
      m_current_volume=0;
  }
//+------------------------------------------------------------------+
//| If current volume is equal than the max volume operations. 
//| Reset the next volume to be the initial volume
//+------------------------------------------------------------------+
void CTrades::ResetNextVolumeToZeroOnMaxMartingale()
  {
   if(m_current_volume>=m_max_volume_martingale_operations)
      m_next_volume=0;
  }
//+------------------------------------------------------------------+
//| Reset the next volume to 0 if is on max take profit
//+------------------------------------------------------------------+
void CTrades::ResetNextVolumeToInitialVolumeOnMaxTakeProfit()
  {
   if(m_count_take_profit_operations>=m_max_take_profit_operations)
      m_next_volume=m_initial_volume;
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
   datetime start=m_time.IntToDatetime(m_time_start_hour,m_time_start_minute);
   datetime end=m_time.IntToDatetime(m_time_end_hour,m_time_end_minute);

   return m_time.TimeTradeServerBetween(start,end);
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
   if(m_current_volume>=m_max_volume_martingale_operations)
      DisableTrade();
  }
//+------------------------------------------------------------------+
//| Disable the trade if is on the max take profit operations
//+------------------------------------------------------------------+
void CTrades::DisableOnMaxTakeProfitOperations()
  {
   if(m_count_take_profit_operations>=m_max_take_profit_operations)
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
//| Calculate the take profit price using the current price
//+------------------------------------------------------------------+
double CTrades::CalculateTakeProfitPrice()
  {
   double takeProfitPrice=0;
   if(m_is_on_buy_trade)
      takeProfitPrice=m_result_open_price+m_take_profit_points;
   else
      takeProfitPrice=m_result_open_price-m_take_profit_points;

   return takeProfitPrice;
  }
//+------------------------------------------------------------------+
//| Calculate the stop loss price using the current price
//+------------------------------------------------------------------+
double CTrades::CalculateStopLossPrice()
  {
   double stopLossPrice=0;
   if(m_is_on_buy_trade)
      stopLossPrice=m_result_open_price-m_stop_loss_points;
   else
      stopLossPrice=m_result_open_price+m_stop_loss_points;

   return stopLossPrice;
  }
//+------------------------------------------------------------------+
//| Calculate the volume using using the max martingale operations
//| Formula: (Martingale^MaxOperations)*InitialVolume
//+------------------------------------------------------------------+
double CTrades::CalculateCurrentVolumeWithMaxMartingale()
  {
   int digits=(int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS);

   double powValue=pow(m_martingale,(m_max_martingale_operations-1));
   double maxVolume=NormalizeDouble(powValue*m_initial_volume,digits);

   return maxVolume;
  }
//+------------------------------------------------------------------+
//| Save the open deal result
//+------------------------------------------------------------------+
void CTrades::SaveOpenDealResult()
  {
   m_result_ticket_open_trade=m_trades_service.ResultTicket();
   m_result_open_price=m_trades_service.ResultPrice();
  }
//+------------------------------------------------------------------+
//| Delete the open deal result
//+------------------------------------------------------------------+
void CTrades::DeleteOpenDealResult()
  {
   m_result_ticket_open_trade=0;
   m_result_open_price=0;
  }
//+------------------------------------------------------------------+
//| Save Take Profit Ticket
//+------------------------------------------------------------------+
void CTrades::SaveTakeProfitTicket()
  {
   m_ticket_take_profit=m_trades_service.ResultTicket();
  }
//+------------------------------------------------------------------+
//| Save Stop Loss Ticket
//+------------------------------------------------------------------+
void CTrades::SaveStopLossTicket()
  {
   m_ticket_stop_loss=m_trades_service.ResultTicket();
  }
//+------------------------------------------------------------------+
//| Delete the open deal ticket
//+------------------------------------------------------------------+
void CTrades::DeleteTakeProfitTicket()
  {
   m_ticket_take_profit=0;
  }
//+------------------------------------------------------------------+
//| Delete the open deal ticket
//+------------------------------------------------------------------+
void CTrades::DeleteStopLossTicket()
  {
   m_ticket_stop_loss=0;
  }
//+------------------------------------------------------------------+
