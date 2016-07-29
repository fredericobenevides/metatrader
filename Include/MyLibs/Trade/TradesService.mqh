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
   long              m_magic;

   bool              m_play_sound_on_operation;
   string            m_buy_trade_sound_name;
   string            m_sell_trade_sound_name;
   string            m_error_trade_sound_name;

public:
                     CTradesService(long magic);

   bool              ExecuteBuyTrade(double volume,string methodName);
   bool              ExecuteSellTrade(double volume,string methodName);

   bool              ExecuteBuySellLimit(bool isOnBuyTrade,double volume,double price,string methodName);
   bool              ExecuteBuySellStop(bool isOnBuyTrade,double volume,double price,string methodName);

   bool              ExecuteOrderDelete(ulong ticket,string methodName);

   double            PositionOpenPrice(ulong ticket);
   double            OrderPrice(ulong ticket);

   ulong             TryToLoadPositionTicket(string methodName);
   ulong             TryToLoadOrderTicket(string methodName);

   void              EnableSoundOnOperation(string sellSoundsName="alert",string buySoundsName="alert2");
   void              PlayBuySound();
   void              PlaySellSound();
   void              PlayErrorSound();
  };
//+------------------------------------------------------------------+
//| Constructor
//+------------------------------------------------------------------+
CTradesService::CTradesService(long magic)
  {
//--- set MagicNumber for your orders identification
   m_magic=magic;
   m_trade.SetExpertMagicNumber(magic);
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
         executed=true;
     }
   else
     {
      price=m_utils.FixPriceByTickSize(price,true);

      if(m_trade.BuyLimit(volume,price,NULL,0,0,ORDER_TIME_DAY,0,comment))
         executed=true;
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
         executed=true;
     }
   else
     {
      price=m_utils.FixPriceByTickSize(price,true);

      if(m_trade.BuyStop(volume,price,NULL,0,0,ORDER_TIME_DAY,0,comment))
         executed=true;
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
//| Returns the position price from a ticket
//+------------------------------------------------------------------+
double CTradesService::PositionOpenPrice(ulong ticket)
  {
   if(HistoryDealSelect(ticket))
      return HistoryDealGetDouble(ticket,DEAL_PRICE);

   return -1;
  }
//+------------------------------------------------------------------+
//| Returns the order price from a ticket
//+------------------------------------------------------------------+
double CTradesService::OrderPrice(ulong ticket)
  {
   if(OrderSelect(ticket))
      return OrderGetDouble(ORDER_PRICE_OPEN);

   return -1;
  }
//+------------------------------------------------------------------+
//| Try to load position ticket by its comment
//+------------------------------------------------------------------+
ulong CTradesService::TryToLoadPositionTicket(string comment)
  {
   int retry=1;
   int maxRetry=20;

   int total=PositionsTotal();
   for(int i=0;i<total;i++)
     {
      if(PositionSelect(Symbol()))
        {
         // select all deals on current day
         datetime end=TimeCurrent();
         datetime start=end-PeriodSeconds(PERIOD_D1);
         HistorySelect(start,end);

         // find the ticket on the history deals
         int totalDeals=HistoryDealsTotal();
         for(int j=totalDeals-1; j>=0;j--)
           {
            ulong ticket=HistoryDealGetTicket(j);
            long magic=HistoryDealGetInteger(ticket,DEAL_MAGIC);
            string positionComment=HistoryDealGetString(ticket,DEAL_COMMENT);

            if(m_magic==magic && StringFind(positionComment,comment,0)!=-1)
               return ticket;
           }
        }
     }

   return 0;
  }
//+------------------------------------------------------------------+
//| Try to load order ticket by its comment
//+------------------------------------------------------------------+
ulong CTradesService::TryToLoadOrderTicket(string comment)
  {
   int retry=1;
   int maxRetry=20;

   int total=OrdersTotal();
   for(int i=0;i<total;i++)
     {
      ulong ticket=OrderGetTicket(i);
      if(OrderSelect(ticket))
        {
         long magic=OrderGetInteger(ORDER_MAGIC);
         string orderComment=OrderGetString(ORDER_COMMENT);

         if(m_magic==magic && StringFind(orderComment,comment,0)!=-1)
            return ticket;
        }
     }

   return 0;
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
