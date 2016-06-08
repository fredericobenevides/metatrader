//+------------------------------------------------------------------+
//|                                              PanelHiloTrades.mq5 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Frederico Benevides"
#property link      "fredbene@gmail.com"
//+------------------------------------------------------------------+
//| Class to do trades based on HiLo.
//+------------------------------------------------------------------+
class CHiLoTrades
  {
private:
   double            m_high_hilo[1];
   double            m_low_hilo[1];

   double            m_high_invalid_hilo[1];
   double            m_low_invalid_hilo[1];

   datetime          m_last_time;

public:
                     CHiLoTrades(void);
   void              OnTick(int handle,int minRatesTotal);
   void              OnTradeTransaction(ENUM_TRADE_TRANSACTION_TYPE tradeType);

   void              TradeStart(bool buy,bool sell);
   void              TradeStop();

   void              TradeBuyOpen(void);
   void              TradeSellOpen(void);

   void              TradeBuyClose(void);
   void              TradeSellClose(void);

   void              ModifyTpSl();
   void              EventTpSlExecuted();

   void              BreakEvenShow();
   void              BreakEvenHide();

   bool              HasTimeToUpdateStatus();
  };
//+------------------------------------------------------------------+
//| Default Constructor                                                                 
//+------------------------------------------------------------------+
CHiLoTrades::CHiLoTrades(void)
  {
   m_last_time=TimeTradeServer();
  }
//+------------------------------------------------------------------+
//| Verify is there any operation for each candle. 
//+------------------------------------------------------------------+
void CHiLoTrades::OnTick(int handle,int minRatesTotal)
  {
   if(BarsCalculated(handle)<minRatesTotal)
      return;

   if(MyTrade.IsNewBar(InpTradeTimeFrame))
     {
      if(CopyBuffer(handle,4,0,1,m_high_hilo)<=0)
         return;

      if(CopyBuffer(handle,5,0,1,m_low_hilo)<=0)
         return;

      if(CopyBuffer(handle,8,0,1,m_high_invalid_hilo)<=0)
         return;

      if(CopyBuffer(handle,9,0,1,m_low_invalid_hilo)<=0)
         return;

      //--- close operation if there is a valid and invalid HiLo.
      if(m_high_hilo[0]!=EMPTY_VALUE || m_high_invalid_hilo[0]!=EMPTY_VALUE)
         TradeBuyClose();

      //--- open operation only if is a valid HiLo
      if(m_high_hilo[0]!=EMPTY_VALUE)
        {
         // if close HiLo is Checked. Don't open a new operation
         if(HiLoDialog.IsCloseHiLoChecked())
            HiLoDialog.InitToDefaults();
         else if(HiLoDialog.IsSellChecked())
            TradeSellOpen();
        }

      //--- close operation if there is a valid and invalid HiLo.
      if(m_low_hilo[0]!=EMPTY_VALUE || m_low_invalid_hilo[0]!=EMPTY_VALUE)
         TradeSellClose();

      //--- open operation only if is a valid HiLo
      if(m_low_hilo[0]!=EMPTY_VALUE)
        {
         // if close HiLo is Checked. Don't open a new operation
         if(HiLoDialog.IsCloseHiLoChecked())
            HiLoDialog.InitToDefaults();
         else if(HiLoDialog.IsBuyChecked())
            TradeBuyOpen();
        }
     }

//if(HasTimeToUpdateStatus())
//   HiLoDialog.LoadVolumeStatusToLabel();
  }
//+------------------------------------------------------------------+
//| Verify if has a TakeProfit or StopLoss operation                                                                 
//+------------------------------------------------------------------+
void CHiLoTrades::OnTradeTransaction(ENUM_TRADE_TRANSACTION_TYPE tradeType)
  {
   if(tradeType!=TRADE_TRANSACTION_HISTORY_ADD)
      return;

// verify on the current day
   bool hadTakeProfitOnHistory=MyTrade.HadTakeProfitOnHistory(PERIOD_D1);
   if(hadTakeProfitOnHistory)
      EventTpSlExecuted();

   bool hadStopLossOnHistory=MyTrade.HadStopLossOnHistory(PERIOD_D1);
   if(hadStopLossOnHistory)
      EventTpSlExecuted();
  }
//+------------------------------------------------------------------+
//| Start a trade                                                                 |
//+------------------------------------------------------------------+
void CHiLoTrades::TradeStart(bool buy,bool sell)
  {
   int volume=HiLoDialog.CurrentVolume();
   bool executed=MyTrade.TradeStart("TradeStart",buy,sell,volume);
   if(executed)
      ModifyTpSl();

   BreakEvenShow();
  }
//+------------------------------------------------------------------+
//| Stop a trade                                                                 |
//+------------------------------------------------------------------+
void CHiLoTrades::TradeStop()
  {
   bool executed=MyTrade.TradeStop("TradeStop");
   if(executed)
     {
      HiLoDialog.ResetVolumesToDefault();
      BreakEvenHide();
     }
  }
//+------------------------------------------------------------------+
//| Open a BUY operation
//+------------------------------------------------------------------+
void CHiLoTrades::TradeBuyOpen()
  {
   int volume=HiLoDialog.CurrentVolume();
   if(MyTrade.TradeBuyOpen("TradeBuyOpen",volume))
     {
      ModifyTpSl();
      BreakEvenShow();
     }
  }
//+------------------------------------------------------------------+
//| Open a SELL operation
//+------------------------------------------------------------------+
void CHiLoTrades::TradeSellOpen()
  {
   int volume=HiLoDialog.CurrentVolume();
   if(MyTrade.TradeSellOpen("TradeSellOpen",volume))
     {
      ModifyTpSl();
      BreakEvenShow();
     }
  }
//+------------------------------------------------------------------+
//| Close a BUY operation|
//+------------------------------------------------------------------+
void CHiLoTrades::TradeBuyClose(void)
  {
   if(MyTrade.TradeBuyClose("TradeBuyClose"))
     {
      HiLoDialog.UpMartingale();
      BreakEvenHide();
     }
  }
//+------------------------------------------------------------------+
//| Close a SELL operation
//+------------------------------------------------------------------+
void CHiLoTrades::TradeSellClose(void)
  {
   if(MyTrade.TradeSellClose("TradeSellClose"))
     {
      HiLoDialog.UpMartingale();
      BreakEvenHide();
     }
  }
//+------------------------------------------------------------------+
//| Modify the current Buy position to config the StopLoss and TakeProfit
//+------------------------------------------------------------------+
void CHiLoTrades::ModifyTpSl(void)
  {
   double takeProfit=0;
   double stopLoss=0;

   bool executeModify=false;

   if(HiLoDialog.IsTakeProfitChecked())
     {
      executeModify=true;
      takeProfit=HiLoDialog.TakeProfit();
     }

   if(HiLoDialog.IsStopLossChecked())
     {
      executeModify=true;
      stopLoss=HiLoDialog.StopLoss();
     }

   if(executeModify)
      MyTrade.ModifyTpSl(stopLoss,takeProfit);
  }
//+------------------------------------------------------------------+
//| If has Take Profit or Stop Loss. Reset the volumes and stop the Expert closing a current Operation.
//+------------------------------------------------------------------+
void CHiLoTrades::EventTpSlExecuted(void)
  {
   HiLoDialog.ResetVolumesToDefault();
   MyTrade.EventTpSlExecuted();
   BreakEvenHide();

// if close Take Profit is Checked. Don't open a new operation
   if(HiLoDialog.IsCloseTpChecked())
      HiLoDialog.InitToDefaults();
  }
//+------------------------------------------------------------------+
//| Show the BreakEven on Chart                                                                 |
//+------------------------------------------------------------------+
void CHiLoTrades::BreakEvenShow()
  {
   BreakEven.Show(HiLoDialog.CurrentVolume(),InpTradePricePerVolume);
  }
//+------------------------------------------------------------------+
//| Hide the BreakEven on Chart                                                                 |
//+------------------------------------------------------------------+
void CHiLoTrades::BreakEvenHide()
  {
   BreakEven.Hide();
  }
//+------------------------------------------------------------------+
//| Verify if has a new time to update the status                                                               |
//+------------------------------------------------------------------+
bool CHiLoTrades::HasTimeToUpdateStatus(void)
  {
   datetime currentTime=TimeTradeServer();
   uint cCurrentTime=(uint)currentTime;

   uint lTime=(uint)m_last_time;

   uint between=cCurrentTime-lTime;
   if(between>=1)
     {
      m_last_time=currentTime;
      return true;
     }

   return false;
  }
//+------------------------------------------------------------------+
