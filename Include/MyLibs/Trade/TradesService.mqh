//+------------------------------------------------------------------+
//|                                              TradeController.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Frederico Benevides"
#property link      "fredbene@gmail.com"

#include <MyLibs\Trade\Trades.mqh>
//+------------------------------------------------------------------+
//| Controller for Trade Operations
//+------------------------------------------------------------------+
class CTradesService
  {
private:
   CTrade            m_trade;

   bool              m_play_sound_on_operation;
   string            m_buy_trade_sound_name;
   string            m_sell_trade_sound_name;
   string            m_error_trade_sound_name;

public:
                     CTradesService();

   //bool              TradeBuyOpen(CTrades *trades,string methodName);
   //bool              TradeSellOpen(CTrades *trades,string methodName);
   //bool              TradeBuyClose(CTrades *trades,string methodName);
   //bool              TradeSellClose(CTrades *trades,string methodName);

   bool              ExecuteBuyTrade(CTrades *trades,string methodName);
   bool              ExecuteSellTrade(CTrades *trades,string methodName);

   void              EnableSoundOnOperation(string sellSoundsName="alert",string buySoundsName="alert2");
   void              PlayBuySound();
   void              PlaySellSound();
   void              PlayErrorSound();
  };
//+------------------------------------------------------------------+
//| Constructor
//+------------------------------------------------------------------+
CTradesService::CTradesService(void)
  {
//--- set MagicNumber for your orders identification
   int MagicNumber=123456;
   m_trade.SetExpertMagicNumber(MagicNumber);
//--- set available slippage in points when buying/selling
   int deviation=50;
   m_trade.SetDeviationInPoints(deviation);
//--- order filling mode, the mode allowed by the server should be used
   m_trade.SetTypeFilling(ORDER_FILLING_RETURN);
//--- logging mode: it would be better not to declare this method at all, the class will set the best mode on its own
   m_trade.LogLevel(1);
//--- what function is to be used for trading: true - OrderSendAsync(), false - OrderSend()
   m_trade.SetAsyncMode(true);
  }
//+------------------------------------------------------------------+
//| Execute the BUY Operation                                                                   
//+------------------------------------------------------------------+
bool CTradesService::ExecuteBuyTrade(CTrades *trades,string methodName)
  {
   double volume=trades.CurrentVolume();

   double price=SymbolInfoDouble(_Symbol,SYMBOL_LAST);
   string comment=methodName+"() "+(string)price;

   if(m_trade.Buy(volume,NULL,0.0,0,0,comment))
     {
      Print("",methodName," method executed successfully. Return code=",m_trade.ResultRetcode()," (",m_trade.ResultRetcodeDescription(),")");
      PlayBuySound();

      return true;
     }
   else
     {
      Print("",methodName," method failed. Return code=",m_trade.ResultRetcode(),". Code description: ",m_trade.ResultRetcodeDescription());
      PlayErrorSound();

      return false;
     }
  }
//+------------------------------------------------------------------+
//| Enable the sounds for BUY operation and SELL operation                                                                
//+------------------------------------------------------------------+
void CTradesService::EnableSoundOnOperation(string sellSoundsName="alert",string buySoundsName="alert2")
  {
   m_play_sound_on_operation=true;
   m_sell_trade_sound_name=sellSoundsName;
   m_buy_trade_sound_name=buySoundsName;
   m_error_trade_sound_name="timeout";
  };
//+------------------------------------------------------------------+
//| Play sounds for BUY Operation                                                                 |
//+------------------------------------------------------------------+
void CTradesService::PlayBuySound()
  {
   if(m_play_sound_on_operation)
      PlaySound(m_buy_trade_sound_name);
  }
//+------------------------------------------------------------------+
//| Play sounds for SELL Operation                                                                |
//+------------------------------------------------------------------+
void CTradesService::PlaySellSound()
  {
   if(m_play_sound_on_operation)
      PlaySound(m_sell_trade_sound_name);
  }
//+------------------------------------------------------------------+
//| Play sounds for ERROR Operation                                                                |
//+------------------------------------------------------------------+
void CTradesService::PlayErrorSound()
  {
   if(m_play_sound_on_operation)
      PlaySound(m_error_trade_sound_name);
  }
//+------------------------------------------------------------------+
