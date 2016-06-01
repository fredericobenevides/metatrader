//+------------------------------------------------------------------+
//|                                                     MyTrades.mqh |
//|                                              Frederico Benevides |
//|                                               fredbene@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Frederico Benevides"
#property link      "fredbene@gmail.com"
#property version   "1.20"

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
      double price=SymbolInfoDouble(symbol,SYMBOL_LAST);
      string comment=methodName+"() "+(string)price;

      if(enableTakeProfit && takeProfit>0.0)
        {
         takeProfit=tradeSumPrice(symbol,takeProfit);
        }

      if(trade.Buy(volume,NULL,0.0,0.0,takeProfit,comment))
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
      double price=SymbolInfoDouble(symbol,SYMBOL_LAST);
      string comment=methodName+"() "+(string)price;

      if(enableTakeProfit && takeProfit>0.0)
        {
         takeProfit=tradeMinusPrice(symbol,takeProfit);
        }

      if(trade.Sell(volume,NULL,0.0,0.0,takeProfit,comment))
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
   //| Modify current Buy symbol to use a Take Profit                                                                 
   //+------------------------------------------------------------------+
   bool modifyBuyPosition(string symbol,double stopLoss=0,double takeProfit=0)
     {
      positionSelect(symbol);

      if(takeProfit>0)
         takeProfit=tradeSumPrice(symbol,takeProfit);
      if(stopLoss>0)
         stopLoss=tradeMinusPrice(symbol,stopLoss);

      bool modified=false;
      if(trade.PositionModify(symbol,stopLoss,takeProfit))
         modified=true;

      if(trade.PositionModify(symbol,stopLoss,takeProfit))
         return true;

      return false;
     };
   //+------------------------------------------------------------------+
   //| Modify current Sell symbol to use a Take Profit                                                                 
   //+------------------------------------------------------------------+
   bool modifySellPosition(string symbol,double stopLoss=0,double takeProfit=0)
     {
      positionSelect(symbol);

      if(takeProfit>0)
         takeProfit=tradeMinusPrice(symbol,takeProfit);
      if(stopLoss>0)
         stopLoss=tradeSumPrice(symbol,stopLoss);

      if(trade.PositionModify(symbol,stopLoss,takeProfit))
         return true;

      return false;
     };
   //+------------------------------------------------------------------+
   //| Verify the Chart has a New Bar                                                                 
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
   //| Verify if on the history has an Take Profit operation                                                                 
   //+------------------------------------------------------------------+
   bool hadTakeProfitOnHistory(ENUM_TIMEFRAMES periodStart)
     {
      return hadCommentOnHistory(periodStart, "tp ");
     };

   //+------------------------------------------------------------------+
   //| Verify if on the history has a Stop Loss operation                                                                 
   //+------------------------------------------------------------------+
   bool hadStopLossOnHistory(ENUM_TIMEFRAMES periodStart)
     {
      return hadCommentOnHistory(periodStart, "sl ");
     };

   //+------------------------------------------------------------------+
   //| Verify if on the history has the specified comment                                                               
   //+------------------------------------------------------------------+
   bool hadCommentOnHistory(ENUM_TIMEFRAMES periodStart,string comment)
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
            if(StringFind(historyComment,comment)!=-1)
               return true;

            // break if the last index of the current symbol doesn't have tp in the comment  
            break;
           }
        }

      return false;
     };

   //+------------------------------------------------------------------+
   //| Sum the current position price with the next price.                                                                 
   //+------------------------------------------------------------------+
   double tradeSumPrice(string symbol,double nextPrice)
     {
      double price=PositionGetDouble(POSITION_PRICE_OPEN);
      int digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);
      double point=SymbolInfoDouble(symbol,SYMBOL_POINT);

      nextPrice=NormalizeDouble(price+nextPrice*point,digits);
      return nextPrice;
     };
   //+------------------------------------------------------------------+
   //| Minus the current position price with the next price.                                                                 
   //+------------------------------------------------------------------+
   double tradeMinusPrice(string symbol,double nextPrice)
     {
      double price=PositionGetDouble(POSITION_PRICE_OPEN);
      int digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);
      double point=SymbolInfoDouble(symbol,SYMBOL_POINT);

      nextPrice=NormalizeDouble(price-nextPrice*point,digits);
      return nextPrice;
     };
   //+------------------------------------------------------------------+
   //| Select the current Position                                                                  
   //+------------------------------------------------------------------+
   void positionSelect(string symbol)
     {
      int retry=1;
      while(!PositionSelect(_Symbol) && retry<10)
        {
         Sleep(retry*100); // sleep for SelectRetryCount * 100 mS
         retry++;
        }
     };
  };

//+------------------------------------------------------------------+
