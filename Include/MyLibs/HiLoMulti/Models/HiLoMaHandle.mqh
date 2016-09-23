//+------------------------------------------------------------------+
//|                                                       HiLoMa.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Frederico Benevides"
#property link      "fredbene@gmail.com"

#include <Object.mqh>
#include <Arrays\ArrayInt.mqh>

#include <MyLibs\Trades\TradesController.mqh>
#include <MyLibs\Utils\ChartUtils.mqh>
#include <MyLibs\HiLoMulti\Models\EnumOperations.mqh>
//+------------------------------------------------------------------+
//| Model of CHiLoMaHandleHandle
//+------------------------------------------------------------------+
class CHiLoMaHandle : public CObject
  {
   CTradesController *m_trades_controller;
   CChartUtils       m_chart_utils;

   // hilo config
   int               m_hilo_period;
   ENUM_MA_METHOD    m_hilo_method;

   // ma config
   int               m_ma_period;
   ENUM_MA_METHOD    m_ma_method;

   // hilo data for indicator handle
   bool              m_arrow_in_first_hilo;
   bool              m_arrow_in_second_hilo;
   bool              m_arrow_in_current_candle;
   bool              m_show_hilo_line;

   // handle data
   ENUM_TIMEFRAMES   m_timeframe;
   int               m_hilo_custom_handle;
   int               m_min_rates_total;

   // hilo operations
   double            m_high_hilo[1];
   double            m_low_hilo[1];
   double            m_high_invalid_hilo[1];
   double            m_low_invalid_hilo[1];

public:
                     CHiLoMaHandle();
                    ~CHiLoMaHandle();

   void              InitHiLoConfig(int period,ENUM_MA_METHOD method);
   void              InitMaConfig(int period,ENUM_MA_METHOD method);

   void              InitIndicatorHandleConfig(ENUM_TIMEFRAMES m_timeframe,bool arrowFirstHiLoo,bool arrowSecondHiLo,bool arrowCurrentCandle,bool showHiLoLine);
   bool              InitHandle();
   CArrayInt        *VerifyTypeOperation();

   // getters and setters 
   void              AddTradesController(CTradesController *tradesController) { m_trades_controller=tradesController; }
   CTradesController *GetTradesController() { return m_trades_controller; }
  };
//+------------------------------------------------------------------+
//| Constructor
//+------------------------------------------------------------------+
CHiLoMaHandle::CHiLoMaHandle(void)
  {
  };
//+------------------------------------------------------------------+
//| Destructor
//+------------------------------------------------------------------+
CHiLoMaHandle::~CHiLoMaHandle(void)
  {
   IndicatorRelease(m_hilo_custom_handle);
   delete m_trades_controller;
  };
//+------------------------------------------------------------------+
//| Init HiLo's Config
//+------------------------------------------------------------------+
void CHiLoMaHandle::InitHiLoConfig(int period,ENUM_MA_METHOD method)
  {
   m_hilo_period=period;
   m_hilo_method=method;
  };
//+------------------------------------------------------------------+
//| Init Ma's Config
//+------------------------------------------------------------------+
void CHiLoMaHandle::InitMaConfig(int period,ENUM_MA_METHOD method)
  {
   m_ma_period=period;
   m_ma_method=method;
  };
//+------------------------------------------------------------------+
//| Init Indicator's Config
//+------------------------------------------------------------------+
void CHiLoMaHandle::InitIndicatorHandleConfig(ENUM_TIMEFRAMES timeframe,bool arrowFirstHiLo,bool arrowSecondHiLo,bool arrowCurrentCandle,bool showHiLoLine)
  {
   m_timeframe=timeframe;
   m_arrow_in_first_hilo=arrowFirstHiLo;
   m_arrow_in_second_hilo=arrowSecondHiLo;
   m_arrow_in_current_candle=arrowCurrentCandle;
   m_show_hilo_line=showHiLoLine;
  }
//+------------------------------------------------------------------+
//| Init HiLo Ma Indicator Handle
//+------------------------------------------------------------------+
bool CHiLoMaHandle::InitHandle()
  {
   m_hilo_custom_handle=iCustom(_Symbol,m_timeframe,"HiLo XP Activator.ex5",
                                "",m_hilo_period,m_hilo_method,
                                m_arrow_in_first_hilo,m_arrow_in_second_hilo,m_arrow_in_current_candle,m_show_hilo_line,
                                "",m_ma_period,m_ma_method);
   if(m_hilo_custom_handle==INVALID_HANDLE)
     {
      Print("Failed to get handle of HiLo activator indicator");
      return false;
     }

   m_min_rates_total=m_hilo_period+1;
   return true;
  }
//+------------------------------------------------------------------+
//| Verify which kind of operation to execute
//+------------------------------------------------------------------+
CArrayInt *CHiLoMaHandle::VerifyTypeOperation()
  {
   CArrayInt *listOperations=new CArrayInt;

   if(BarsCalculated(m_hilo_custom_handle)<m_min_rates_total)
      return NULL;

   if(m_chart_utils.IsNewBar(m_timeframe))
     {
      if(CopyBuffer(m_hilo_custom_handle,4,0,1,m_high_hilo)<=0)
         return NULL;

      if(CopyBuffer(m_hilo_custom_handle,5,0,1,m_low_hilo)<=0)
         return NULL;

      if(CopyBuffer(m_hilo_custom_handle,8,0,1,m_high_invalid_hilo)<=0)
         return NULL;

      if(CopyBuffer(m_hilo_custom_handle,9,0,1,m_low_invalid_hilo)<=0)
         return NULL;

      //--- close operation if there is a valid and invalid HiLo.
      if(m_high_hilo[0]!=EMPTY_VALUE || m_high_invalid_hilo[0]!=EMPTY_VALUE)
         listOperations.Add(BUY_CLOSE_OPERATION);

      //--- open operation only if is a valid HiLo
      if(m_high_hilo[0]!=EMPTY_VALUE)
         listOperations.Add(SELL_OPEN_OPERATION);

      //--- close operation if there is a valid and invalid HiLo.
      if(m_low_hilo[0]!=EMPTY_VALUE || m_low_invalid_hilo[0]!=EMPTY_VALUE)
         listOperations.Add(SELL_CLOSE_OPERATION);

      //--- open operation only if is a valid HiLo
      if(m_low_hilo[0]!=EMPTY_VALUE)
         listOperations.Add(BUY_OPEN_OPERATION);
     }

   if(listOperations.Total()==0)
      return NULL;

   return listOperations;
  }
//+------------------------------------------------------------------+
