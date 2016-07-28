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
   bool              m_open_position_ticket_loaded;
   ulong             m_open_position_ticket;

   // martingale
   int               m_martingale;
   int               m_max_martingale_operations;
   double            m_max_volume_martingale_operations;

   //--- type of operation
   bool              m_is_on_buy_trade;
   bool              m_is_on_sell_trade;

   // take profit
   bool              m_take_profit_ticket_loaded;
   ulong             m_take_profit_ticket;
   double            m_take_profit_points;
   int               m_count_take_profit_operations;
   int               m_max_take_profit_operations;

   // stop loss
   bool              m_stop_loss_ticket_loaded;
   ulong             m_stop_loss_ticket;
   double            m_stop_loss_points;

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

   void              AddTradesService(CTradesService *tradesService) { m_trades_service=tradesService; }

   bool              BuyOpen(string methodName);
   bool              SellOpen(string methodName);
   bool              BuyClose(string methodName);
   bool              SellClose(string methodName);

   bool              PlaceTakeProfitOrder(string methodName);
   bool              PlaceStopLossOrder(string methodName);
   bool              DeleteTakeProfitOrder(string methodName);
   bool              DeleteStopLossOrder(string methodName);

   void              TryToLoadPositionOpenTicket(string methodName);
   void              TryToLoadTakeProfitTicket(string methodName);
   void              TryToLoadStopLossTicket(string methodName);

   bool              VerifyIfExistTakeProfitTicket(ulong ticket) { return m_take_profit_ticket==ticket; }
   bool              VerifyIfExistStopLossTicket(ulong ticket) { return m_stop_loss_ticket==ticket; }

   void              UpdateNextVolumeUsingMartingale(string methodName);
   void              UpdateVolumeFromNextVolume() { m_current_volume=m_next_volume; }
   void              UpdateNextVolumeFromInitialVolume() {  m_next_volume=m_initial_volume; }
   void              UpdateCountTakeProfitOperations() { m_count_take_profit_operations+=1; }

   void              ResetVolumeToZero();
   void              ResetVolumeToZeroIfNextVolumeIsInitialVolume();
   void              ResetNextVolumeToZeroOnMaxMartingale();
   void              ResetNextVolumeToInitialVolumeOnMaxTakeProfit();

   bool              IsOnTradeOperation();
   bool              IsTimeToOpenOperation();

   void              EnableTrade() { m_enable_trade=true; }
   void              DisableTrade(){ m_enable_trade=false; }
   bool              IsTradeEnable() { return m_enable_trade; }

   void              DisableOnMaxMartingaleOperations();
   void              DisableOnMaxTakeProfitOperations();

   bool              IsEnable() { return m_enable_trade; }
   bool              IsOnBuyTrade() { return m_is_on_buy_trade; }
   bool              IsOnSellTrade() { return m_is_on_sell_trade; }

   string            Name() { return m_name; }
   double            CurrentVolume() { return m_current_volume; }
   double            NextVolume() { return m_next_volume; }
   double            TakeProfitPoints() { return m_take_profit_points; }
   double            StopLossPoints() { return m_stop_loss_points; }

   bool              IsPositionTicketLoaded() { return m_open_position_ticket_loaded; }
   bool              IsTakeProfitTicketLoaded() { return m_take_profit_ticket_loaded; }
   bool              IsStopLossTicketLoaded() { return m_stop_loss_ticket_loaded; }

private:

   double            CalculateTakeProfitPrice();
   double            CalculateStopLossPrice();
   double            CalculateCurrentVolumeWithMaxMartingale();

   void              ResetPositionTicketData();
   void              ResetTakeProfitTicketData();
   void              ResetStopLossTicketData();
  };
//+------------------------------------------------------------------+
//| Constructor
//+------------------------------------------------------------------+
CTrades::CTrades(string name="trade")
  {
   m_name=name;

   m_is_on_buy_trade=false;
   m_is_on_sell_trade=false;
  }
//+------------------------------------------------------------------+
//| Destructor
//+------------------------------------------------------------------+
CTrades::~CTrades()
  {
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
void CTrades::InitTradesTime(int startHour,int startMinute,int endHour,int endMinute)
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
      ResetPositionTicketData();

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
      ResetPositionTicketData();

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
   if(IsTakeProfitTicketLoaded())
      return false;

   PrintFormat("%s will delete take profit order with the ticket: %d",methodName,m_take_profit_ticket);

   bool result=false;
   if(m_trades_service.ExecuteOrderDelete(m_take_profit_ticket,methodName))
     {
      PrintFormat("%s operation executed: true",methodName);
      ResetTakeProfitTicketData();

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
   if(IsStopLossTicketLoaded())
      return  false;

   PrintFormat("%s will delete stop loss order with the ticket: %d",methodName,m_stop_loss_ticket);

   bool result=false;
   if(m_trades_service.ExecuteOrderDelete(m_stop_loss_ticket,methodName))
     {
      PrintFormat("%s operation executed: true",methodName);
      ResetStopLossTicketData();

      result=true;
     }
   else
      PrintFormat("%s operation executed: false",methodName);

   return result;
  }
//+------------------------------------------------------------------+
//| Try to load the position open ticket by its methodName
//+------------------------------------------------------------------+
void CTrades::TryToLoadPositionOpenTicket(string methodName)
  {
   ulong ticket=m_trades_service.TryToLoadPositionTicket(methodName);
   if(ticket!=-1)
     {
      m_open_position_ticket_loaded=true;
      m_open_position_ticket=ticket;
     }
  }
//+------------------------------------------------------------------+
//| Try to load the take profit ticket by its methodName
//+------------------------------------------------------------------+
void CTrades::TryToLoadTakeProfitTicket(string methodName)
  {
   ulong ticket=m_trades_service.TryToLoadOrderTicket(methodName);
   if(ticket!=-1)
     {
      m_take_profit_ticket_loaded=true;
      m_take_profit_ticket=ticket;
     }
  }
//+------------------------------------------------------------------+
//| Try to load the stop loss ticket by its methodName
//+------------------------------------------------------------------+
void CTrades::TryToLoadStopLossTicket(string methodName)
  {
   ulong ticket=m_trades_service.TryToLoadOrderTicket(methodName);
   if(ticket!=-1)
     {
      m_stop_loss_ticket_loaded=true;
      m_stop_loss_ticket=ticket;
     }
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
//| Calculate the take profit price using the current price
//+------------------------------------------------------------------+
double CTrades::CalculateTakeProfitPrice()
  {
   double openPrice=m_trades_service.PositionOpenPrice(m_open_position_ticket);
   double takeProfitPrice=0;

   if(m_is_on_buy_trade)
      takeProfitPrice=openPrice+m_take_profit_points;
   else
      takeProfitPrice=openPrice-m_take_profit_points;

   return takeProfitPrice;
  }
//+------------------------------------------------------------------+
//| Calculate the stop loss price using the current price
//+------------------------------------------------------------------+
double CTrades::CalculateStopLossPrice()
  {
   double openPrice=m_trades_service.PositionOpenPrice(m_open_position_ticket);
   double stopLossPrice=0;

   if(m_is_on_buy_trade)
      stopLossPrice=openPrice-m_stop_loss_points;
   else
      stopLossPrice=openPrice+m_stop_loss_points;

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
//| Reset the data for position ticket
//+------------------------------------------------------------------+
void CTrades::ResetPositionTicketData()
  {
   m_open_position_ticket_loaded=false;
   m_open_position_ticket=0;
  }
//+------------------------------------------------------------------+
//| Reset the data for take profit ticket
//+------------------------------------------------------------------+
void CTrades::ResetTakeProfitTicketData()
  {
   m_take_profit_ticket_loaded=false;
   m_take_profit_ticket=0;
  }
//+------------------------------------------------------------------+
//| Reset the data for stop loss ticket
//+------------------------------------------------------------------+
void CTrades::ResetStopLossTicketData()
  {
   m_stop_loss_ticket_loaded=false;
   m_stop_loss_ticket=0;
  }
//+------------------------------------------------------------------+
