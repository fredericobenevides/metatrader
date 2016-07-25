//+------------------------------------------------------------------+
//|                                              TradeController.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Frederico Benevides"
#property link      "fredbene@gmail.com"

#include <MyLibs\Trade\Trades.mqh>

#include <MyLibs\Trade\TradesUtils.mqh>
//+------------------------------------------------------------------+
//| Controller for Trade Operations
//+------------------------------------------------------------------+
class CTradesService
  {
private:
   CTrade            m_trade;
   CTradesUtils      m_utils;

   bool              m_play_sound_on_operation;
   string            m_buy_trade_sound_name;
   string            m_sell_trade_sound_name;
   string            m_error_trade_sound_name;

public:
                     CTradesService();

   bool              ExecuteBuyTrade(double volume,string methodName);
   bool              ExecuteSellTrade(double volume,string methodName);

   bool              ExecuteBuySellLimit(bool isOnBuyTrade,double volume,double price,string methodName);
   bool              ExecuteBuySellStop(bool isOnBuyTrade,double volume,double price,string methodName);

   bool              ExecuteOrderDelete(ulong ticket,string methodName);

   ulong             ResultTicket();
   double            ResultPrice();

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
bool CTradesService::ExecuteBuyTrade(double volume,string methodName)
  {
   double price=SymbolInfoDouble(_Symbol,SYMBOL_LAST);
   string comment=methodName+" "+(string)price;

   if(m_trade.Buy(volume,NULL,0,0,0,comment))
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
//| Execute the SELL Operation
//+------------------------------------------------------------------+
bool CTradesService::ExecuteSellTrade(double volume,string methodName)
  {
   double price=SymbolInfoDouble(_Symbol,SYMBOL_LAST);
   string comment=methodName+" "+(string)price;

   if(m_trade.Sell(volume,NULL,0,0,0,comment))
     {
      Print("",methodName," method executed successfully. Return code=",m_trade.ResultRetcode()," (",m_trade.ResultRetcodeDescription(),")");
      PlaySellSound();

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
//| Execute the BUY  OR SELL Limit
//| If is on Buy Trade will execute Sell Limit
//| If is on Sell Trade will execute Buy Limit
//+------------------------------------------------------------------+
bool CTradesService::ExecuteBuySellLimit(bool isOnBuyTrade,double volume,double price,string methodName)
  {
   if(price==0.0)
      return false;

   string comment=methodName+" "+(string)price;
   bool executed=false;

   if(isOnBuyTrade)
     {
      price=m_utils.FixPriceByTickSize(price,false);

      if(m_trade.SellLimit(volume,price,NULL,0,0,ORDER_TIME_DAY,0,comment))
        {
         executed=true;
         PlaySellSound();
        }
     }
   else
     {
      price=m_utils.FixPriceByTickSize(price,true);

      if(m_trade.BuyLimit(volume,price,NULL,0,0,ORDER_TIME_DAY,0,comment))
        {
         executed=true;
         PlayBuySound();
        }
     }

   if(executed)
      Print("",methodName," method executed successfully. Return code=",m_trade.ResultRetcode()," (",m_trade.ResultRetcodeDescription(),")");
   else
     {
      Print("",methodName," method failed. Return code=",m_trade.ResultRetcode(),". Code description: ",m_trade.ResultRetcodeDescription());
      PlayErrorSound();
     }

   return executed;
  }
//+------------------------------------------------------------------+
//| Execute the BUY  OR SELL Stop
//| If is on Buy Trade will execute Sell Stop
//| If is on Sell Trade will execute Buy Stop
//+------------------------------------------------------------------+
bool CTradesService::ExecuteBuySellStop(bool isOnBuyTrade,double volume,double price,string methodName)
  {
   if(price==0.0)
      return false;

   string comment=methodName+" "+(string)price;
   bool executed=false;

   if(isOnBuyTrade)
     {
      price=m_utils.FixPriceByTickSize(price,false);

      if(m_trade.SellStop(volume,price,NULL,0,0,ORDER_TIME_DAY,0,comment))
        {
         executed=true;
         PlaySellSound();
        }
     }
   else
     {
      price=m_utils.FixPriceByTickSize(price,true);

      if(m_trade.BuyStop(volume,price,NULL,0,0,ORDER_TIME_DAY,0,comment))
        {
         executed=true;
         PlayBuySound();
        }
     }

   if(executed)
      Print("",methodName," method executed successfully. Return code=",m_trade.ResultRetcode()," (",m_trade.ResultRetcodeDescription(),")");
   else
     {
      Print("",methodName," method failed. Return code=",m_trade.ResultRetcode(),". Code description: ",m_trade.ResultRetcodeDescription());
      PlayErrorSound();
     }

   return executed;
  }
//+------------------------------------------------------------------+
//| Execute Order Delete
//+------------------------------------------------------------------+
bool CTradesService::ExecuteOrderDelete(ulong ticket,string methodName)
  {
   bool result=m_trade.OrderDelete(ticket);
   if(result)
      Print("",methodName," method executed successfully. Return code=",m_trade.ResultRetcode()," (",m_trade.ResultRetcodeDescription(),")");
   else
      Print("",methodName," method failed. Return code=",m_trade.ResultRetcode(),". Code description: ",m_trade.ResultRetcodeDescription());

   return result;
  }
//+------------------------------------------------------------------+
//| Result ticket order
//+------------------------------------------------------------------+
ulong CTradesService::ResultTicket()
  {
   return m_trade.ResultOrder();
  }
//+------------------------------------------------------------------+
//| Result price order
//+------------------------------------------------------------------+
double  CTradesService::ResultPrice()
  {
   return m_trade.ResultPrice();
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
