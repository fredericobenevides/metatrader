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
   int               m_hilo_custom_handle;
   int               m_min_rates_total;

public:
   bool              Init();
   void              Destroy();

   void              OnTick();

  };
//+------------------------------------------------------------------+
//|  Init load the iCustom for HiLo MA Activator.ex5                                                                |
//+------------------------------------------------------------------+
bool CHiLoLoader::Init()
  {
   m_hilo_custom_handle=iCustom(_Symbol,InpTradeTimeFrame,"HiLo MA Activator.ex5",
                            InpHiLoData,InpPeriod,InpMaMethod,
                            InpArrowInFirstHiLo,InpArrowInSecondHiLo,InpArrowInCurrentCandle,InpShowHiLoLine,
                            InpCmaData,InpCmaPeriod,InpCmaMethod);
   if(m_hilo_custom_handle==INVALID_HANDLE)
     {
      Print("Failed to get handle of HiLo activator indicator");
      return false;
     }

   m_min_rates_total=InpPeriod+1;
   return true;
  }
//+------------------------------------------------------------------+
//| Destroy the m_hilo_custom_handle                                                                 |
//+------------------------------------------------------------------+
void CHiLoLoader::Destroy(void)
  {
   IndicatorRelease(m_hilo_custom_handle);
  }
//+------------------------------------------------------------------+
//| Verify is there any operation for each candle.                                                                 |
//+------------------------------------------------------------------+
void CHiLoLoader::OnTick(void)
  {
   HiLoTrades.OnTick(m_hilo_custom_handle,m_min_rates_total);
  }

//+------------------------------------------------------------------+
