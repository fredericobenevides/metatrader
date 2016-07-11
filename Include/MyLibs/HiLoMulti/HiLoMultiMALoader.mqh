//+------------------------------------------------------------------+
//|                                            HiLoMultiMaLoader.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property copyright "Frederico Benevides"
#property link      "fredbene@gmail.com"
//+------------------------------------------------------------------+
//| Class to work with iCustom on HiLo Ma Activator
//+------------------------------------------------------------------+
class CHiLoMultiMALoader
  {
private:
   //--- vars for HiLo Loader
   int               m_hilo_trade1_custom_handle;
   int               m_min_rates_total;

private:
   bool              InitTrade1();

public:
   bool              Init();
   void              Destroy();

   void              OnTick();

  };
//+------------------------------------------------------------------+
//|  Init load the iCustom for HiLo MA Activator.ex5 for Trade 1
//+------------------------------------------------------------------+
bool CHiLoMultiMALoader::InitTrade1()
  {
   m_hilo_trade1_custom_handle=iCustom(_Symbol,InpTrade1TimeFrame,"HiLo MA Activator.ex5",
                                       InpTrade1HiLoMaData,InpTrade1HiLoPeriod,InpTrade1HiLoMethod,
                                       InpAllArrowInFirstHiLo,InpAllArrowInSecondHiLo,InpAllArrowInCurrentCandle,InpAllShowHiLoLine,
                                       InpTrade1HiLoMaData,InpTrade1MaPeriod,InpTrade1MaMethod);
   if(m_hilo_trade1_custom_handle==INVALID_HANDLE)
     {
      Print("Failed to get handle of HiLo activator indicator");
      return false;
     }

   return true;
  }
//+------------------------------------------------------------------+
//|  Init load the iCustom for HiLo MA Activator.ex5
//+------------------------------------------------------------------+
bool CHiLoMultiMALoader::Init()
  {
   bool result=true;
   result=InitTrade1();

   m_min_rates_total=InpTrade1HiLoPeriod+1;
   return result;
  }
//+------------------------------------------------------------------+
//| Destroy the m_hilo_custom_handle                                                                 |
//+------------------------------------------------------------------+
void CHiLoMultiMALoader::Destroy(void)
  {
   IndicatorRelease(m_hilo_trade1_custom_handle);
  }
//+------------------------------------------------------------------+
//| Verify is there any operation for each candle.                                                                 |
//+------------------------------------------------------------------+
void CHiLoMultiMALoader::OnTick(void)
  {
   HiLoMultiTrades.OnTick(m_hilo_trade1_custom_handle,m_min_rates_total);
  }
//+------------------------------------------------------------------+
