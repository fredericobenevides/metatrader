//+------------------------------------------------------------------+
//|                                                     MyTrades.mqh |
//|                                              Frederico Benevides |
//|                                               fredbene@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Frederico Benevides"
#property link      "fredbene@gmail.com"

#include <Trade\Trade.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CMyTrade
  {

protected:
   CTrade            trade;
   datetime          dtOldBar;

   bool              playSoundOnOperation;
   string            buyTradeSoundName;
   string            sellTradeSoundName;
   string            errorTradeSoundName;

public:
   //+------------------------------------------------------------------+
   //| Loads configs for trading                                                                 
   //+------------------------------------------------------------------+
   void loadTradeConfig()
     {
      //--- set MagicNumber for your orders identification
      int MagicNumber=123456;
      trade.SetExpertMagicNumber(MagicNumber);
      //--- set available slippage in points when buying/selling
      int deviation=50;
      trade.SetDeviationInPoints(deviation);
      //--- order filling mode, the mode allowed by the server should be used
      trade.SetTypeFilling(ORDER_FILLING_RETURN);
      //--- logging mode: it would be better not to declare this method at all, the class will set the best mode on its own
      trade.LogLevel(1);
      //--- what function is to be used for trading: true - OrderSendAsync(), false - OrderSend()
      trade.SetAsyncMode(true);
     };

   //+------------------------------------------------------------------+
   //| Enable the sounds for BUY operation and SELL operation                                                                
   //+------------------------------------------------------------------+
   void enableSoundOnOperation(string sellSoundsName="alert",string buySoundsName="alert2")
     {
      playSoundOnOperation=true;
      sellTradeSoundName=sellSoundsName;
      buyTradeSoundName=buySoundsName;
      errorTradeSoundName="timeout";
     };

   //+------------------------------------------------------------------+
   //| Execute the BUY Operation                                                                 
   //+------------------------------------------------------------------+
   bool executeBuyTrade(string symbol,string methodName,int volume,double takeProfit,bool enableTakeProfit=true)
     {
      double price=SymbolInfoDouble(symbol,SYMBOL_BID);
      string comment=methodName+"() "+(string)price;
      double takeProfitCalculated=0.0;

      if(enableTakeProfit && takeProfit>0.0)
        {
         int digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);
         double point=SymbolInfoDouble(symbol,SYMBOL_POINT);
         takeProfitCalculated=NormalizeDouble(price+takeProfit*point,digits);
        }

      if(trade.Buy(volume,NULL,0.0,0.0,takeProfitCalculated,comment))
        {
         Print("",methodName,"() method executed successfully. Return code=",trade.ResultRetcode()," (",trade.ResultRetcodeDescription(),")");
         if(playSoundOnOperation)
            PlaySound(buyTradeSoundName);

         return true;
        }
      else
        {
         Print("",methodName,"() method failed. Return code=",trade.ResultRetcode(),". Code description: ",trade.ResultRetcodeDescription());
         if(playSoundOnOperation)
            PlaySound(errorTradeSoundName);

         return false;
        }
     };

   //+------------------------------------------------------------------+
   //| Execute the SELL Operation                                                                 |
   //+------------------------------------------------------------------+
   bool executeSellTrade(string symbol,string methodName,int volume,double takeProfit,bool enableTakeProfit=true)
     {
      double price=SymbolInfoDouble(symbol,SYMBOL_BID);
      string comment=methodName+"() "+(string)price;
      double takeProfitCalculated=0.0;

      if(enableTakeProfit && takeProfit>0.0)
        {
         int digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);
         double point=SymbolInfoDouble(symbol,SYMBOL_POINT);
         takeProfitCalculated=NormalizeDouble(price-takeProfit*point,digits);
        }

      if(trade.Sell(volume,NULL,0.0,0.0,takeProfitCalculated,comment))
        {
         Print("",methodName,"() method executed successfully. Return code=",trade.ResultRetcode()," (",trade.ResultRetcodeDescription(),")");
         if(playSoundOnOperation)
            PlaySound(sellTradeSoundName);

         return true;
        }
      else
        {
         Print("",methodName,"() method failed. Return code=",trade.ResultRetcode(),". Code description: ",trade.ResultRetcodeDescription());
         if(playSoundOnOperation)
            PlaySound(errorTradeSoundName);

         return false;
        }
     };
   //+------------------------------------------------------------------+
   //| Verify the Chart has a New Bar                                                                 |
   //+------------------------------------------------------------------+
   bool isNewBar(string symbol,ENUM_TIMEFRAMES currentTimeFrame)
     {
      datetime dtNewBar[1];
      if(CopyTime(symbol,currentTimeFrame,0,1,dtNewBar))
        {
         if(dtOldBar!=dtNewBar[0])
           {
            dtOldBar=dtNewBar[0];
            return true;
           }
        }
      else
        {
         Print("Error in copying historical times data, error =",GetLastError());
         ResetLastError();
        }

      return false;
     };

   //+------------------------------------------------------------------+
   //| Verify if on the history has an Take Profit operation                                                                 |
   //+------------------------------------------------------------------+
   bool hadTakeProfitOnHistory(ENUM_TIMEFRAMES periodStart)
     {
      datetime end=TimeCurrent();
      datetime start=end-PeriodSeconds(periodStart);

      HistorySelect(start,end);
      int historyOrders=HistoryOrdersTotal();

      // inverse search on history to find the current symbol and his last comment      
      for(int lastIndex=historyOrders-1;lastIndex>=0;lastIndex--)
        {
         ulong ticket=HistoryOrderGetTicket(lastIndex);
         string historySymbol=HistoryOrderGetString(ticket,ORDER_SYMBOL);
         if(historySymbol==Symbol())
           {
            // if the last symbol comment has tp, so is a takeProfit
            string historyComment=HistoryOrderGetString(ticket,ORDER_COMMENT);
            if(StringFind(historyComment,"tp ")!=-1)
               return true;

            // break if the last index of the current symbol doesn't have tp in the comment  
            break;
           }
        }

      return false;
     };
  };
//+------------------------------------------------------------------+
