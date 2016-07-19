//+------------------------------------------------------------------+
//|                                                       HiLoMa.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Frederico Benevides"
#property link      "fredbene@gmail.com"

#include <Object.mqh>

#include <MyLibs\Trade\Trades.mqh>
#include <MyLibs\Utils\ChartUtils.mqh>
#include <MyLibs\HiLoMulti\Models\EnumOperations.mqh>
//+------------------------------------------------------------------+
//| Model of HiLoMa
//+------------------------------------------------------------------+
class CHiLoMa : public CObject
  {
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

   // trade operations
   bool              m_enable;
   ENUM_TIMEFRAMES   m_timeframe;
   double            m_volume;
   int               m_max_factor_operations; // Default max operations (Martingale^MaxOperations)*InitialVolume
   double            m_take_profit;
   double            m_stop_loss;
   CTrades          *m_trades;

   // handle data
   int               m_hilo_custom_handle;
   int               m_min_rates_total;

   // hilo operations
   double            m_high_hilo[1];
   double            m_low_hilo[1];
   double            m_high_invalid_hilo[1];
   double            m_low_invalid_hilo[1];

   // utils
   CChartUtils       m_chart_utils;

public:
                     CHiLoMa();
                    ~CHiLoMa();
   void              Destroy();

   void              InitHiLoConfig(int period,ENUM_MA_METHOD method);
   void              InitMaConfig(int period,ENUM_MA_METHOD method);

   void              InitTradesConfig(bool enable,ENUM_TIMEFRAMES timeframe,
                                      double volume,int maxFactorOperations,
                                      double takeProfit,double stopLoss);

   void              InitIndicatorHandleConfig(bool arrowFirstHiLoo,bool arrowSecondHiLo,bool arrowCurrentCandle,bool showHiLoLine);

   bool              InitHandle();
   int               ExecuteOperation();

   // getters and setters
   bool              IsTradeEnable();
   CTrades          *GetTrades();
   double            GetVolume();
   double            GetTakeProfit();
   double            GetStopLoss();
  };
//+------------------------------------------------------------------+
//| Constructor
//+------------------------------------------------------------------+
CHiLoMa::CHiLoMa(void)
  {
   m_trades=new CTrades();
  };
//+------------------------------------------------------------------+
//| Destructor
//+------------------------------------------------------------------+
CHiLoMa::~CHiLoMa(void)
  {
   delete m_trades;
  };
//+------------------------------------------------------------------+
//| Destroy
//+------------------------------------------------------------------+
CHiLoMa::Destroy()
  {
   IndicatorRelease(m_hilo_custom_handle);
  }
//+------------------------------------------------------------------+
//| Init HiLo's Config
//+------------------------------------------------------------------+
void CHiLoMa::InitHiLoConfig(int period,ENUM_MA_METHOD method)
  {
   m_hilo_period=period;
   m_hilo_method=method;
  };
//+------------------------------------------------------------------+
//| Init Ma's Config
//+------------------------------------------------------------------+
void CHiLoMa::InitMaConfig(int period,ENUM_MA_METHOD method)
  {
   m_ma_period=period;
   m_ma_method=method;
  };
//+------------------------------------------------------------------+
//| Init Trade's Config
//+------------------------------------------------------------------+
void CHiLoMa::InitTradesConfig(bool enable,ENUM_TIMEFRAMES timeframe,
                               double volume,int maxFactorOperations,
                               double takeProfit,double stopLoss)
  {
   m_enable=enable;
   m_timeframe=timeframe;
   m_volume=volume;
   m_max_factor_operations=maxFactorOperations;
   m_take_profit=takeProfit;
   m_stop_loss=stopLoss;
   
   m_trades.Init(volume,takeProfit,stopLoss);
  }
//+------------------------------------------------------------------+
//| Init Indicator's Config
//+------------------------------------------------------------------+
void CHiLoMa::InitIndicatorHandleConfig(bool arrowFirstHiLo,bool arrowSecondHiLo,bool arrowCurrentCandle,bool showHiLoLine)
  {
   m_arrow_in_first_hilo=arrowFirstHiLo;
   m_arrow_in_second_hilo=arrowSecondHiLo;
   m_arrow_in_current_candle=arrowCurrentCandle;
   m_show_hilo_line=showHiLoLine;
  };
//+------------------------------------------------------------------+
//| Init HiLo Ma Indicator Handle
//+------------------------------------------------------------------+
bool CHiLoMa::InitHandle()
  {
   m_hilo_custom_handle=iCustom(_Symbol,m_timeframe,"HiLo MA Activator.ex5",
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
int CHiLoMa::ExecuteOperation()
  {
   if(BarsCalculated(m_hilo_custom_handle)<m_min_rates_total)
      return NO_OPERATION;

   if(m_chart_utils.IsNewBar(m_timeframe))
     {
      if(CopyBuffer(m_hilo_custom_handle,4,0,1,m_high_hilo)<=0)
         return NO_OPERATION;

      if(CopyBuffer(m_hilo_custom_handle,5,0,1,m_low_hilo)<=0)
         return NO_OPERATION;

      if(CopyBuffer(m_hilo_custom_handle,8,0,1,m_high_invalid_hilo)<=0)
         return NO_OPERATION;

      if(CopyBuffer(m_hilo_custom_handle,9,0,1,m_low_invalid_hilo)<=0)
         return NO_OPERATION;

      //--- close operation if there is a valid and invalid HiLo.
      if(m_high_hilo[0]!=EMPTY_VALUE || m_high_invalid_hilo[0]!=EMPTY_VALUE)
         return BUY_CLOSE_OPERATION;

      //--- open operation only if is a valid HiLo
      if(m_high_hilo[0]!=EMPTY_VALUE)
         return SELL_OPEN_OPERATION;

      //--- close operation if there is a valid and invalid HiLo.
      if(m_low_hilo[0]!=EMPTY_VALUE || m_low_invalid_hilo[0]!=EMPTY_VALUE)
         return SELL_CLOSE_OPERATION;

      //--- open operation only if is a valid HiLo
      if(m_low_hilo[0]!=EMPTY_VALUE)
         return BUY_OPEN_OPERATION;
     }

   return NO_OPERATION;
  }
//+------------------------------------------------------------------+
//| Return if the trade is enable
//+------------------------------------------------------------------+
bool CHiLoMa::IsTradeEnable()
  {
   return m_enable;
  }
//+------------------------------------------------------------------+
//| Return CTrades
//+------------------------------------------------------------------+
CTrades *CHiLoMa::GetTrades()
  {
   return m_trades;
  }
//+------------------------------------------------------------------+
//| Return the Volume
//+------------------------------------------------------------------+
double CHiLoMa::GetVolume(void)
  {
   return m_volume;
  }
//+------------------------------------------------------------------+
//| Return the take profit
//+------------------------------------------------------------------+
double CHiLoMa::GetTakeProfit()
  {
   return m_take_profit;
  }
//+------------------------------------------------------------------+
//| Return the stop loss
//+------------------------------------------------------------------+
double CHiLoMa::GetStopLoss()
  {
   return m_stop_loss;
  }
//+------------------------------------------------------------------+
