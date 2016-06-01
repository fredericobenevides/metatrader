//+------------------------------------------------------------------+
//|                                        Exp Panel HiLo Dialog.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Frederico Benevides"
#property link      "fredbene@gmail.com"
//+------------------------------------------------------------------+
//| Class to work with iCustom on HiLo Ma Activator
//+------------------------------------------------------------------+
class CHiLoLoader
  {
private:
   //--- vars for HiLo Loader
   int               HiLoCustomHandle;
   int               MinRatesTotal;

   //--- vars for Trades
   bool              isOnBuyTrade;
   bool              isOnSellTrade;

public:
   virtual bool      Init();
   virtual void      Destroy();

   virtual void      OnTick();

protected:
   virtual void      tradeBuyOpen();
   virtual void      tradeSellOpen();

   virtual void      tradeBuyClose();
   virtual void      tradeSellClose();

   virtual bool      isOnTradeOperation();

  };
//+------------------------------------------------------------------+
//|  Init load the iCustom for HiLo MA Activator.ex5                                                                |
//+------------------------------------------------------------------+
bool CHiLoLoader::Init()
  {
   HiLoCustomHandle=iCustom(Symbol(),InpTradeTimeFrame,"HiLo MA Activator.ex5",
                            InpHiLoData,InpPeriod,InpMaMethod,
                            InpArrowInFirstHiLo,InpArrowInSecondHiLo,InpArrowInCurrentCandle,InpShowHiLoLine,
                            InpCmaData,InpCmaPeriod,InpCmaMethod);
   if(HiLoCustomHandle==INVALID_HANDLE)
     {
      Print("Failed to get handle of HiLo activator indicator");
      return false;
     }

   MinRatesTotal=InpPeriod+1;
   myTrade.loadTradeConfig();

   return true;
  }
//+------------------------------------------------------------------+
//| Destroy the HiLoCustomHandle                                                                 |
//+------------------------------------------------------------------+
void CHiLoLoader::Destroy(void)
  {
   IndicatorRelease(HiLoCustomHandle);
  }
//+------------------------------------------------------------------+
//| Verify is there any operation for each candle.                                                                 |
//+------------------------------------------------------------------+
void CHiLoLoader::OnTick(void)
  {
   HiLoTrades.OnTick(HiLoCustomHandle,MinRatesTotal);
  }

//+------------------------------------------------------------------+
