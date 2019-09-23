//+------------------------------------------------------------------+
//|                                              PanelHiloTrades.mq5 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Frederico Benevides"
#property link      "fredbene@gmail.com"

#include <MyLibs\Trade\MyTrade.mqh>
#include <MyLibs\HiLoXP\EnumOperations.mqh>
#include <Arrays\ArrayInt.mqh>
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
   int               m_count_take_profit;

public:
   void              Init();
   void              OnTick(int handle,int minRatesTotal);
   void              OnTradeTransaction(ENUM_TRADE_TRANSACTION_TYPE tradeType,ENUM_ORDER_TYPE orderType);

   void              TradeStart(bool buy,bool sell);
   void              TradeStop();

   void              TradeBuyOpen(void);
   void              TradeSellOpen(void);

   void              TradeBuyClose(void);
   void              TradeSellClose(void);

   void              TradeCloseByMetatrader(void);

   void              ModifyTpSl();
   void              EventTpSlExecuted();

   void              BreakEvenShow();
   void              BreakEvenHide();

   bool              IsTimeToOpenOperation();

   bool              HasTimeToUpdateStatus();
  };
//+------------------------------------------------------------------+
//| Constructor
//+------------------------------------------------------------------+
void  CHiLoTrades::Init()
  {
   m_count_take_profit=0;
  }
//+------------------------------------------------------------------+
//| Verify is there any operation for each candle.
//+------------------------------------------------------------------+
void CHiLoTrades::OnTick(int handle,int minRatesTotal)
  {
   if(BarsCalculated(handle)<minRatesTotal)
      return;

   CArrayInt *listOperations=new CArrayInt;
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

      //--- open operation only if is a valid HiLo
      if(m_high_hilo[0]!=EMPTY_VALUE)
        {
         listOperations.Add(BUY_CLOSE_OPERATION);
         listOperations.Add(SELL_OPEN_OPERATION);
        }

      //--- open operation only if is a valid HiLo
      if(m_low_hilo[0]!=EMPTY_VALUE)
        {
         listOperations.Add(SELL_CLOSE_OPERATION);
         listOperations.Add(BUY_OPEN_OPERATION);
        }
     }

   if(listOperations.Total()==0)
     {
      delete listOperations;
      return;
     }

   for(int j=0; j<listOperations.Total(); j++)
     {
      ENUM_OPERATIONS operation=(ENUM_OPERATIONS)listOperations.At(j);
      switch(operation)
        {
         case BUY_OPEN_OPERATION:
            Print("Current candle has BUY_OPEN_OPERATION");
            if(HiLoDialog.IsCloseHiLoChecked())
               HiLoDialog.InitToDefaults();
            else
               if(HiLoDialog.IsBuyChecked())
                  TradeBuyOpen();
            break;

         case SELL_OPEN_OPERATION:
            Print("Current candle has SELL_OPEN_OPERATION");

            // if close HiLo is Checked. Don't open a new operation
            if(HiLoDialog.IsCloseHiLoChecked())
               HiLoDialog.InitToDefaults();
            else
               if(HiLoDialog.IsSellChecked())
                  TradeSellOpen();
            break;

         case BUY_CLOSE_OPERATION:
            Print("Current candle has BUY_CLOSE_OPERATION");
            TradeBuyClose();
            break;
         case SELL_CLOSE_OPERATION:
            Print("Current candle has SELL_CLOSE_OPERATION");
            TradeSellClose();
            break;
         default: // NO_OPERATION
            continue;
        }
     }

// remove this list operation
   if(listOperations!=NULL)
     {
      listOperations.Shutdown();
      delete listOperations;
     }

   if(Time.HasPassedTime((int)0.4))
      HiLoDialog.LoadVolumeStatusToLabel();
  }
//+------------------------------------------------------------------+
//| Verify if has a TakeProfit or StopLoss operation
//+------------------------------------------------------------------+
void CHiLoTrades::OnTradeTransaction(ENUM_TRADE_TRANSACTION_TYPE tradeType,ENUM_ORDER_TYPE orderType)
  {
   if(tradeType!=TRADE_TRANSACTION_HISTORY_ADD)
      return;

   Sleep(500);
// verify on the current day
   bool hadTakeProfitOnHistory=MyTrade.HadTakeProfitOnHistory(PERIOD_D1);
   if(hadTakeProfitOnHistory)
      EventTpSlExecuted();

   bool hadStopLossOnHistory=MyTrade.HadStopLossOnHistory(PERIOD_D1);
   if(hadStopLossOnHistory)
      EventTpSlExecuted();

   if(orderType==ORDER_TYPE_BUY && MyTrade.IsOnSellTrade())
      TradeCloseByMetatrader();

   if(orderType==ORDER_TYPE_SELL && MyTrade.IsOnBuyTrade())
      TradeCloseByMetatrader();

  }
//+------------------------------------------------------------------+
//| Start a trade                                                                 |
//+------------------------------------------------------------------+
void CHiLoTrades::TradeStart(bool buy,bool sell)
  {
   double volume=HiLoDialog.CurrentVolume();
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
      HiLoDialog.InitToDefaults();
      BreakEvenHide();
     }
  }
//+------------------------------------------------------------------+
//| Open a BUY operation
//+------------------------------------------------------------------+
void CHiLoTrades::TradeBuyOpen()
  {
   if(!IsTimeToOpenOperation())
      return;

   double volume=HiLoDialog.CurrentVolume();
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
   if(!IsTimeToOpenOperation())
      return;

   double volume=HiLoDialog.CurrentVolume();
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
      HiLoDialog.CalculateVolumeFactor();
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
      HiLoDialog.CalculateVolumeFactor();
      BreakEvenHide();
     }
  }
//+------------------------------------------------------------------+
//| Close a trade by metatrader
//+------------------------------------------------------------------+
void CHiLoTrades::TradeCloseByMetatrader(void)
  {
   MyTrade.ExecutedOnMetatrader();
   HiLoDialog.CalculateVolumeFactor();
   BreakEvenHide();
  }
//+------------------------------------------------------------------+
//| Modify the current position to config the StopLoss and TakeProfit
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
     {
      Sleep(500);
      MyTrade.ModifyTpSl(stopLoss,takeProfit);
     }
  }
//+------------------------------------------------------------------+
//| If has Take Profit or Stop Loss. Reset the volumes and stop the Expert closing a current Operation.
//+------------------------------------------------------------------+
void CHiLoTrades::EventTpSlExecuted(void)
  {
   HiLoDialog.ResetVolumesToDefault();
   MyTrade.EventTpSlExecuted();
   BreakEvenHide();

   m_count_take_profit=m_count_take_profit+1;

// maxtakeprofit is disable if is 0
   if(InpTradeMaxTakeProfit==0)
      return;

// if close Take Profit is Checked and the count of take profit is equal to max take profit.
//Don't open a new operation
   if(HiLoDialog.IsCloseTpChecked() && InpTradeMaxTakeProfit==m_count_take_profit)
     {
      HiLoDialog.InitToDefaults();
      Init();
     }
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
//| Verify if can start to open new operations
//+------------------------------------------------------------------+
bool CHiLoTrades::IsTimeToOpenOperation()
  {
   if(!InpTimeEnabled)
      return true;

   datetime start=Time.IntToDatetime(InpTimeStartHour,InpTimeStartMinute);
   datetime end=Time.IntToDatetime(InpTimeEndHour,InpTimeEndMinute);

   return Time.TimeTradeServerBetween(start,end);
  }
//+------------------------------------------------------------------+
