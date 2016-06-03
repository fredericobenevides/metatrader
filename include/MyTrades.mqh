//+------------------------------------------------------------------+
//|                                                     MyTrades.mqh |
//|                                              Frederico Benevides |
//|                                               fredbene@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Frederico Benevides"
#property link      "fredbene@gmail.com"
#property version   "1.23"

#include <Trade\Trade.mqh>
#include <MyTradesOperation.mqh>

#include <Arrays\List.mqh>
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

   CList         *tradesOperation;

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

         createTradeOperation();

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

         createTradeOperation();

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

      double tickSize=SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_SIZE);
      bool executedModify=false;

      // Adjust the price using the tickSize.
      // Example:
      // Suppose on a market, the price is 50107. Since the step for this market
      // is 5, the correctly price should be 50100, 50105 or 50110.
      // So for each tickSize the price will be ajusting by 1 until is possible to
      // modify the position.
      for(double i=0;i<tickSize;i++)
        {
         double takeProfitCalculated=0;
         double stopLossCalculated=0;

         if(takeProfit>0)
            takeProfitCalculated=tradeSumPrice(symbol,takeProfit,i);
         if(stopLoss>0)
            stopLossCalculated=tradeMinusPrice(symbol,stopLoss,i);

         if(trade.PositionModify(symbol,stopLossCalculated,takeProfitCalculated))
           {
            executedModify=true;
            break;
           }
        }

      return executedModify;
     };
   //+------------------------------------------------------------------+
   //| Modify current Sell symbol to use a Take Profit                                                                 
   //+------------------------------------------------------------------+
   bool modifySellPosition(string symbol,double stopLoss=0,double takeProfit=0)
     {
      positionSelect(symbol);

      double tickSize=SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_SIZE);
      bool executedModify=false;

      // Adjust the price using the tickSize.
      // Example:
      // Suppose on a market, the price is 50107. Since the step for this market
      // is 5, the correctly price should be 50100, 50105 or 50110.
      // So for each tickSize the price will be ajusting by 1 until is possible to
      // modify the position.
      for(double i=0;i<tickSize;i++)
        {
         double takeProfitCalculated=0;
         double stopLossCalculated=0;

         if(takeProfit>0)
            takeProfitCalculated=tradeMinusPrice(symbol,takeProfit,i);
         if(stopLoss>0)
            stopLossCalculated=tradeSumPrice(symbol,stopLoss,i);

         if(trade.PositionModify(symbol,stopLossCalculated,takeProfitCalculated))
           {
            executedModify=true;
            break;
           }
        }

      return executedModify;
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
   //| Sum the current position price with the price.
   //| If the adjustPrice is different from 0. Minus the price with the adjustPrice.
   //+------------------------------------------------------------------+
   double tradeSumPrice(string symbol,double price,double adjustPrice=0)
     {
      double positionPrice=PositionGetDouble(POSITION_PRICE_OPEN);
      int digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);
      double point=SymbolInfoDouble(symbol,SYMBOL_POINT);

      price=NormalizeDouble(positionPrice+(price*point)-(adjustPrice*point),digits);
      return price;
     };

   //+------------------------------------------------------------------+
   //| Minus the current position price with the next price.
   //| If the adjustPrice is different from 0. Sum the price with the adjustPrice.
   //+------------------------------------------------------------------+
   double tradeMinusPrice(string symbol,double price,double adjustPrice=0)
     {
      double positionPrice=PositionGetDouble(POSITION_PRICE_OPEN);
      int digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);
      double point=SymbolInfoDouble(symbol,SYMBOL_POINT);

      price=NormalizeDouble(positionPrice-(price*point)+(adjustPrice*point),digits);
      return price;
     };

   double calculateProfit(double priceOpen,double priceClose,int volume,double symbolFactor)
     {
      int digits=(int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS);
      double   profit=NormalizeDouble((priceClose-priceOpen)*symbolFactor,digits);
      return profit;
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

   double getSymbolFactor()
     {
      if(StringFind(_Symbol,"WIN")!=-1)
         return 0.2;

      if(StringFind(_Symbol,"WDO")!=-1)
         return 10;

      return 0;
     };

   void createTradeOperation()
     {
     if (tradesOperation == NULL) {
      tradesOperation = new CList();
     }
     

    
     
      //int size = ArraySize(tradesOperation)-1;
      //CTradeOperation last = tradesOperation[size];
      positionSelect(_Symbol);
      CPositionInfo positionInfo;
      positionInfo.Select(_Symbol);

      CTradeOperation* tradeOperation = new CTradeOperation();
      tradeOperation.priceOpen(positionInfo.PriceCurrent());
      tradeOperation.priceClose(positionInfo.PriceCurrent());
      tradeOperation.volume(positionInfo.Volume());
      tradeOperation.factor(getSymbolFactor());


     bool existPriceClose
     
     CTradeOperation* tradeOperation = tradesOperation.GetLastNode();
     if (lastNode != NULL && lastNode.priceClose != 0) {
     tradeOperation = new *CTradeOperation();
     }

      tradesOperation.Add(tradeOperation);
     }
  };
//+------------------------------------------------------------------+
