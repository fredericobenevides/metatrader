//+------------------------------------------------------------------+
//|                                              HiLoMultiTrades.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Frederico Benevides"
#property link      "fredbene@gmail.com"
//+------------------------------------------------------------------+
//| Class to do trades based on HiLo.
//+------------------------------------------------------------------+
class CHiLoMultiTrades
  {
private:
//   double            m_high_hilo[1];
//   double            m_low_hilo[1];
//
//   double            m_high_invalid_hilo[1];
//   double            m_low_invalid_hilo[1];
//
//   datetime          m_last_time;

public:
   void              OnTick(int handle,int minRatesTotal);
//   void              OnTradeTransaction(ENUM_TRADE_TRANSACTION_TYPE tradeType);
//
//   void              TradeStart(bool buy,bool sell);
//   void              TradeStop();
//
//   void              TradeBuyOpen(void);
//   void              TradeSellOpen(void);
//
//   void              TradeBuyClose(void);
//   void              TradeSellClose(void);
//
//   void              ModifyTpSl();
//   void              EventTpSlExecuted();
//
//   void              BreakEvenShow();
//   void              BreakEvenHide();
//
//   bool              IsTimeToOpenOperation();
//
//   bool              HasTimeToUpdateStatus();
  };
//+------------------------------------------------------------------+
//| Verify is there any operation for each candle. 
//+------------------------------------------------------------------+
void CHiLoMultiTrades::OnTick(int handle,int minRatesTotal)
  {
//   if(BarsCalculated(handle)<minRatesTotal)
//      return;
//
//   if(MyTrade.IsNewBar(InpTradeTimeFrame))
//     {
//      if(CopyBuffer(handle,4,0,1,m_high_hilo)<=0)
//         return;
//
//      if(CopyBuffer(handle,5,0,1,m_low_hilo)<=0)
//         return;
//
//      if(CopyBuffer(handle,8,0,1,m_high_invalid_hilo)<=0)
//         return;
//
//      if(CopyBuffer(handle,9,0,1,m_low_invalid_hilo)<=0)
//         return;
//
//      //--- close operation if there is a valid and invalid HiLo.
//      if(m_high_hilo[0]!=EMPTY_VALUE || m_high_invalid_hilo[0]!=EMPTY_VALUE)
//         TradeBuyClose();
//
//      //--- open operation only if is a valid HiLo
//      if(m_high_hilo[0]!=EMPTY_VALUE)
//        {
//         // if close HiLo is Checked. Don't open a new operation
//         if(HiLoDialog.IsCloseHiLoChecked())
//            HiLoDialog.InitToDefaults();
//         else if(HiLoDialog.IsSellChecked())
//            TradeSellOpen();
//        }
//
//      //--- close operation if there is a valid and invalid HiLo.
//      if(m_low_hilo[0]!=EMPTY_VALUE || m_low_invalid_hilo[0]!=EMPTY_VALUE)
//         TradeSellClose();
//
//      //--- open operation only if is a valid HiLo
//      if(m_low_hilo[0]!=EMPTY_VALUE)
//        {
//         // if close HiLo is Checked. Don't open a new operation
//         if(HiLoDialog.IsCloseHiLoChecked())
//            HiLoDialog.InitToDefaults();
//         else if(HiLoDialog.IsBuyChecked())
//            TradeBuyOpen();
//        }
//     }
//
//   if(Time.HasPassedTime((int)0.4))
//      HiLoDialog.LoadVolumeStatusToLabel();
  }
