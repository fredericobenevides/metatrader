//+------------------------------------------------------------------+
//|                                                   TradeOrder.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Frederico Benevides"
#property link      "fredbene@gmail.com"
//+------------------------------------------------------------------+
//| Class to map the position order
//+------------------------------------------------------------------+
class CPositionOrder
  {
   string            m_name;
   string            m_buy_open_name;
   string            m_buy_close_name;
   string            m_sell_open_name;
   string            m_sell_close_name;

   bool              m_trade_enable;
   bool              m_initial_trade_enable;
   double            m_initial_volume;
   double            m_volume;
   double            m_next_volume;

   // martingale
   int               m_martingale;
   int               m_max_martingale_operations;
   double            m_max_volume_martingale_operations;

   bool              m_order_placed;
   bool              m_ticket_loaded;
   ulong             m_ticket_value;

   //--- type of operation
   bool              m_is_on_buy_trade;
   bool              m_is_on_sell_trade;

public:
                     CPositionOrder(string tradeName);
   void              InitTrade(bool tradeEnable,double initialVolume);
   void              InitMartingale(int martingale,int maxMartingaleOperations);

   void              ExecutedBuyOpenOperation();
   void              ExecutedSellOpenOperation();
   void              ExecutedBuyCloseOperation();
   void              ExecutedSellCloseOperation();

   double            OpenNewVolume();
   double            CloseVolume()    { return m_volume; }
   double            Volume()         { return m_volume; }
   double            NextVolume() { return m_next_volume; }

   double            CalculateMaxVolumeMartingaleOperations();

   bool              IsTradeEnable() { return m_trade_enable; }
   void              EnableTrade() { m_trade_enable=true; }
   void              DisableTrade() { m_trade_enable=false; }

   bool              IsOrderPlaced()  { return m_order_placed; }
   bool              IsTicketLoaded() { return m_ticket_loaded; }
   ulong             Ticket()         { return m_ticket_value; }
   void              LoadTicket(ulong ticket);

   bool              IsOnTradeOperation() { return IsOnBuyTrade() || IsOnSellTrade(); }
   bool              IsOnBuyTrade()  { return m_is_on_buy_trade; }
   bool              IsOnSellTrade() { return m_is_on_sell_trade; }

   string            Name()          { return m_name; }
   string            BuyOpenName()   { return m_buy_open_name; }
   string            BuyCloseName()  { return m_buy_close_name; }
   string            SellOpenName()  { return m_sell_open_name; }
   string            SellCloseName() { return m_sell_close_name; }
   string            BuySellOperationStatus();

   void              ResetVolumeToZeroNextVolumeToInitialVolume();
   void              ResetNextVolumeToInitialVolume();

   void              ResetToDefault();

private:
   void              updateNextVolumeUsingMartingale();
   void              resetNextVolumeToZeroOnMaxMartingale();

   void              disableOnMaxMartingaleOperations();
   void              disableOnMaxTakeProfitOperations();
  };
//+------------------------------------------------------------------+
//| Constructor
//+------------------------------------------------------------------+
CPositionOrder::CPositionOrder(string tradeName)
  {
   m_name=tradeName;
   m_buy_open_name=m_name+"::BuyOpen()";
   m_buy_close_name=m_name+"::BuyClose()";
   m_sell_open_name=m_name+"::SellOpen()";
   m_sell_close_name=m_name+"::SellClose()";
  }
//+------------------------------------------------------------------+
//| Init the base volume
//+------------------------------------------------------------------+
void CPositionOrder::InitTrade(bool tradeEnable,double initialVolume)
  {
   m_trade_enable=tradeEnable;
   m_initial_trade_enable=tradeEnable;
   m_initial_volume=initialVolume;
   m_next_volume=m_initial_volume;
   m_volume=0;
  }
//+------------------------------------------------------------------+
//| Init the trades martingale
//+------------------------------------------------------------------+
void CPositionOrder::InitMartingale(int martingale,int maxMartingaleOperations)
  {
   m_martingale=martingale;
   m_max_martingale_operations=maxMartingaleOperations;
   m_max_volume_martingale_operations=CalculateMaxVolumeMartingaleOperations();
  }
//+------------------------------------------------------------------+
//| Executed Open Operation
//+------------------------------------------------------------------+
void CPositionOrder::ExecutedBuyOpenOperation()
  {
   m_is_on_buy_trade=true;
   m_order_placed=true;
  }
//+------------------------------------------------------------------+
//| Executed Open Operation
//+------------------------------------------------------------------+
void CPositionOrder::ExecutedSellOpenOperation()
  {
   m_is_on_sell_trade=true;
   m_order_placed=true;
  }
//+------------------------------------------------------------------+
//| Executed Close Operation
//+------------------------------------------------------------------+
void CPositionOrder::ExecutedBuyCloseOperation()
  {
   m_is_on_buy_trade=false;
   m_order_placed=false;
   m_ticket_loaded=false;
   m_ticket_value=0;
  }
//+------------------------------------------------------------------+
//| Executed Close Operation
//+------------------------------------------------------------------+
void CPositionOrder::ExecutedSellCloseOperation()
  {
   m_is_on_sell_trade=false;
   m_order_placed=false;
   m_ticket_loaded=false;
   m_ticket_value=0;
  }
//+------------------------------------------------------------------+
//| Open a new volume
//+------------------------------------------------------------------+
double CPositionOrder::OpenNewVolume()
  {
   m_volume=m_next_volume;
   updateNextVolumeUsingMartingale();

   resetNextVolumeToZeroOnMaxMartingale();
   disableOnMaxMartingaleOperations();

   return m_volume;
  }
//+------------------------------------------------------------------+
//| Calculate the volume using using the max martingale operations
//| Formula: (Martingale^MaxOperations)*InitialVolume
//+------------------------------------------------------------------+
double CPositionOrder::CalculateMaxVolumeMartingaleOperations()
  {
   int digits=(int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS);

   double powValue=pow(m_martingale,(m_max_martingale_operations-1));
   double maxVolume=NormalizeDouble(powValue*m_initial_volume,digits);

   return maxVolume;
  }
//+------------------------------------------------------------------+
//| Load the current ticket
//+------------------------------------------------------------------+
void CPositionOrder::LoadTicket(ulong ticket)
  {
   m_ticket_loaded=true;
   m_ticket_value=ticket;
  }
//+------------------------------------------------------------------+
//| Return B if on buy operation
//| Return S if on sell operation
//| Return N if is not on operation
//+------------------------------------------------------------------+
string CPositionOrder::BuySellOperationStatus()
  {
   if(IsOnTradeOperation())
     {
      if(IsOnBuyTrade())
         return "B";
      if(IsOnSellTrade())
         return "S";
     }

   return "N";
  }
//+------------------------------------------------------------------+
//| Reset the volume to 0 and next volume to initial volume
//+------------------------------------------------------------------+
void CPositionOrder::ResetVolumeToZeroNextVolumeToInitialVolume()
  {
   m_volume=0;
   m_next_volume=m_initial_volume;
  }
//+------------------------------------------------------------------+
//| Reset next vokume to 0.
//+------------------------------------------------------------------+
void CPositionOrder::ResetNextVolumeToInitialVolume()
  {
   m_next_volume=m_initial_volume;
  }
//+------------------------------------------------------------------+
//| Reset everything to Default
//+------------------------------------------------------------------+
void CPositionOrder::ResetToDefault()
  {
   m_trade_enable=m_initial_trade_enable;

   m_volume=0;
   m_next_volume=m_initial_volume;

   m_order_placed=false;
   m_ticket_loaded=false;
   m_ticket_value=0;

   m_is_on_buy_trade=false;
   m_is_on_sell_trade=false;
  }
//+------------------------------------------------------------------+
//| Update the next volume based on martingale
//+------------------------------------------------------------------+
void CPositionOrder::updateNextVolumeUsingMartingale()
  {
   m_next_volume=NormalizeDouble(m_next_volume*m_martingale,2);
  }
//+------------------------------------------------------------------+
//| If current volume is equal than the max volume operations. 
//| Reset the next volume to be the initial volume
//+------------------------------------------------------------------+
void CPositionOrder::resetNextVolumeToZeroOnMaxMartingale()
  {
   if(m_volume>=m_max_volume_martingale_operations)
      m_next_volume=0;
  }
//+------------------------------------------------------------------+
//| Disable the trade if is on max martingale operations
//| Formula: (Martingale^MaxOperations)*InitialVolume
//+------------------------------------------------------------------+
void CPositionOrder::disableOnMaxMartingaleOperations()
  {
   if(m_volume>=m_max_volume_martingale_operations)
      DisableTrade();
  }
//+------------------------------------------------------------------+
