//+------------------------------------------------------------------+
//|                                                        m_trade.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Frederico Benevides"
#property link      "fredbene@gmail.com"
#property version   "1.00"

#include <Trade\Trade.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CMyTrade
  {

private:
   CTrade            m_trade;
   datetime          m_dt_old_bar;

   bool              m_is_on_buy_trade;
   bool              m_is_on_sell_trade;
   int               m_current_trade_volume;

   bool              m_play_sound_on_operation;
   string            m_buy_trade_sound_name;
   string            m_sell_trade_sound_name;
   string            m_error_trade_sound_name;

public:
   void              CMyTrade(void);

   bool              TradeStart(string methodName,bool buy,bool sell,int volume);
   bool              TradeStop(string methodName);

   bool              TradeBuyOpen(string methodName,int volume);
   bool              TradeSellOpen(string methodName,int volume);
   bool              TradeBuyClose(string methodName);
   bool              TradeSellClose(string methodName);

   bool              ExecuteBuyTrade(string methodName,int volume);
   bool              ExecuteSellTrade(string methodName,int volume);

   bool              ModifyTpSl(double stopLoss=0,double takeProfit=0);
   void              EventTpSlExecuted(void);

   bool              HadTakeProfitOnHistory(ENUM_TIMEFRAMES periodStart);
   bool              HadStopLossOnHistory(ENUM_TIMEFRAMES periodStart);
   bool              HadCommentOnHistory(ENUM_TIMEFRAMES periodStart,string comment);

   bool              LastDealOnHistoryIsProfitPositive();
   double            LastDealPriceOnHistory();
   string            CurrentPositionStatus();

   double            CalculateBreakEven(int baseVolume,double pricePerVolume=0);
   double            CalculateBreakEvenWithLastDeal(int baseVolume,double pricePerVolume=0);

   void              EnableSoundOnOperation(string sellSoundsName="alert",string buySoundsName="alert2");
   void              PlayBuySound();
   void              PlaySellSound();
   void              PlayErrorSound();

   // utils
   bool              IsNewBar(ENUM_TIMEFRAMES currentTimeFrame);
   bool              IsOnTradeOperation();
   bool              IsOnBuyTrade();
   bool              IsOnSellTrade();
   int               CurrentTradeVolume();
   void              LoadTradeOperationFromPosition();

   double            TradeLastDealSumPrice(double price,double adjustPrice=0);
   double            TradePositionSumPrice(double price,double adjustPrice=0);

   void              CurrentPositionSelect();
   double            SymbolFactor();
  };
//+------------------------------------------------------------------+
//| Constructor                                                                 |
//+------------------------------------------------------------------+
CMyTrade::CMyTrade(void)
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

   m_is_on_buy_trade=false;
   m_is_on_sell_trade=false;
  }
//+------------------------------------------------------------------+
//| Start a trade                                                                
//+------------------------------------------------------------------+
bool CMyTrade::TradeStart(string methodName,bool buy,bool sell,int volume)
  {
   if(IsOnTradeOperation())
     {
      string warningMsg="START operation was NOT executed. You are already in operation!";
      Print(warningMsg);
      MessageBox(warningMsg,"Warning",MB_OK);
      return false;
     }

   if(buy && sell)
     {
      string warningMsg="START operation was NOT executed. Please specify only BUY or SELL operation to use the Start operation";
      Print(warningMsg);
      MessageBox(warningMsg,"Warning",MB_OK);
      return false;
     }

   m_current_trade_volume=volume;
   if(!buy && sell)
     {
      if(ExecuteSellTrade(methodName,m_current_trade_volume))
         m_is_on_sell_trade=true;
     }

   if(buy && !sell)
     {
      if(ExecuteBuyTrade(methodName,m_current_trade_volume))
         m_is_on_buy_trade=true;
     }

   Print("********** Executed START operation! **********");
   return true;
  }
//+------------------------------------------------------------------+
//| Stop a trade                                                                
//+------------------------------------------------------------------+
bool CMyTrade::TradeStop(string methodName)
  {
   if(!IsOnTradeOperation())
     {
      string warningMsg="STOP operation was NOT executed. You are not in operation!";
      Print(warningMsg);
      MessageBox(warningMsg,"Warning",MB_OK);
      return false;
     }

   if(m_is_on_buy_trade)
     {
      if(ExecuteSellTrade(methodName,m_current_trade_volume))
         m_is_on_buy_trade=false;
     }

   if(m_is_on_sell_trade)
     {
      if(ExecuteBuyTrade(methodName,m_current_trade_volume))
         m_is_on_sell_trade=false;
     }

   Print("********** Executed STOP operation! **********");
   return true;
  }
//+------------------------------------------------------------------+
//| Open a BUY operation                                                                
//+------------------------------------------------------------------+
bool CMyTrade::TradeBuyOpen(string methodName,int volume)
  {
   if(IsOnTradeOperation())
     {
      Print("Buy will not be executed since is already on Buy/Sell Trade Operation **********");
      return false;
     }

   m_current_trade_volume=volume;
   if(ExecuteBuyTrade(methodName,m_current_trade_volume))
      m_is_on_buy_trade=true;

   Print("********** Executed BUY OPEN operation! **********");
   return true;
  }
//+------------------------------------------------------------------+
//| Open a Sell operation                                                                
//+------------------------------------------------------------------+
bool CMyTrade::TradeSellOpen(string methodName,int volume)
  {
   if(IsOnTradeOperation())
     {
      Print("Sell will not be executed since is already on Buy/Sell Trade Operation **********");
      return false;
     }

   m_current_trade_volume=volume;
   if(ExecuteSellTrade(methodName,m_current_trade_volume))
      m_is_on_sell_trade=true;

   Print("********** Executed SELL OPEN operation! **********");
   return true;
  }
//+------------------------------------------------------------------+
//| Close a BUY operation
//+------------------------------------------------------------------+
bool CMyTrade::TradeBuyClose(string methodName)
  {
   if(m_is_on_buy_trade)
     {
      if(ExecuteSellTrade(methodName,m_current_trade_volume))
         m_is_on_buy_trade=false;

      Print("********** Executed BUY CLOSE operation! **********");
      return true;
     }

   return false;
  }
//+------------------------------------------------------------------+
//| Close a SELL operation
//+------------------------------------------------------------------+
bool CMyTrade::TradeSellClose(string methodName)
  {
   if(m_is_on_sell_trade)
     {
      if(ExecuteBuyTrade(methodName,m_current_trade_volume))
         m_is_on_sell_trade=false;

      Print("********** Executed SELL CLOSE operation! **********");
      return true;
     }

   return false;
  }
//+------------------------------------------------------------------+
//| Execute the BUY Operation                                                                   
//+------------------------------------------------------------------+
bool CMyTrade::ExecuteBuyTrade(string methodName,int volume)
  {
   double price=SymbolInfoDouble(_Symbol,SYMBOL_LAST);
   string comment=methodName+"() "+(string)price;

   if(m_trade.Buy(volume,NULL,0.0,0,0,comment))
     {
      Print("",methodName,"() method executed successfully. Return code=",m_trade.ResultRetcode()," (",m_trade.ResultRetcodeDescription(),")");
      PlayBuySound();

      return true;
     }
   else
     {
      Print("",methodName,"() method failed. Return code=",m_trade.ResultRetcode(),". Code description: ",m_trade.ResultRetcodeDescription());
      PlayErrorSound();

      return false;
     }
  }
//+------------------------------------------------------------------+
//| Execute the BUY Operation
//+------------------------------------------------------------------+
bool CMyTrade::ExecuteSellTrade(string methodName,int volume)
  {
   double price=SymbolInfoDouble(_Symbol,SYMBOL_LAST);
   string comment=methodName+"() "+(string)price;

   if(m_trade.Sell(volume,NULL,0.0,0,0,comment))
     {
      Print("",methodName,"() method executed successfully. Return code=",m_trade.ResultRetcode()," (",m_trade.ResultRetcodeDescription(),")");
      PlaySellSound();

      return true;
     }
   else
     {
      Print("",methodName,"() method failed. Return code=",m_trade.ResultRetcode(),". Code description: ",m_trade.ResultRetcodeDescription());
      PlayErrorSound();

      return false;
     }
  }
//+------------------------------------------------------------------+
//| Modify current Take Profit / Stop Loss 
//|
//| Example for a BUY operation:
//| Current price: 50200.
//| Take Profit: 200  (50400)
//| Stop Loss: 50     (50150)
//|
//| Example for a SELL operation:
//| Take Profit: 200  (50000)
//| Stop Loss: 50     (50250)
//+------------------------------------------------------------------+
bool CMyTrade::ModifyTpSl(double stopLoss=0,double takeProfit=0)
  {
   CurrentPositionSelect();

   double tickSize=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
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
      double adjustIndex=i;

      if(takeProfit>0)
        {
         // invert the signal for sell operation
         if(IsOnSellTrade())
           {
            takeProfit=NormalizeDouble(takeProfit*-1,2);
            adjustIndex=NormalizeDouble(adjustIndex*-1,2);
           }

         takeProfitCalculated=TradeLastDealSumPrice(takeProfit,adjustIndex);
        }
      if(stopLoss>0)
        {
         // invert the signal for buy operation
         if(IsOnBuyTrade())
           {
            stopLoss=NormalizeDouble(stopLoss*-1,2);
            adjustIndex=NormalizeDouble(adjustIndex*-1,2);
           }

         stopLossCalculated=TradeLastDealSumPrice(stopLoss,adjustIndex);
        }

      ResetLastError();
      if(m_trade.PositionModify(_Symbol,stopLossCalculated,takeProfitCalculated))
        {
         executedModify=true;
         break;
        }
      else
         Print("There was an error when trying to modify TP / SL position: ",GetLastError());
     }

   if(executedModify)
      Print("Successfully modified the TP / SL");
   else
      Print("There was ann error to modify TP / SL");

   return executedModify;
  }
//+------------------------------------------------------------------+
//| There was an event of Tp / Sl executed.                                                                
//+------------------------------------------------------------------+
void CMyTrade::EventTpSlExecuted(void)
  {
   if(m_is_on_buy_trade)
     {
      m_is_on_buy_trade=false;
      PlaySellSound(); // sell because is selling on a buy operation
     }
   else
     {
      m_is_on_sell_trade=false;
      PlayBuySound(); // buy because is buying on a sell operation
     }

   Print("********** Executed BUY TP / SL operation! **********");
  }
//+------------------------------------------------------------------+
//| Verify if on the history has a Take Profit operation                                                                 
//+------------------------------------------------------------------+
bool CMyTrade::HadTakeProfitOnHistory(ENUM_TIMEFRAMES periodStart)
  {
   return HadCommentOnHistory(periodStart, "tp ");
  }
//+------------------------------------------------------------------+
//| Verify if on the history has a Stop Loss operation                                                                 
//+------------------------------------------------------------------+
bool CMyTrade::HadStopLossOnHistory(ENUM_TIMEFRAMES periodStart)
  {
   return HadCommentOnHistory(periodStart, "sl ");
  }
//+------------------------------------------------------------------+
//| Verify if on the history has the specified comment                                                               
//+------------------------------------------------------------------+
bool CMyTrade::HadCommentOnHistory(ENUM_TIMEFRAMES periodStart,string comment)
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
//| Return true if the last deal on history is positive or false otherwise.
//+------------------------------------------------------------------+
bool CMyTrade::LastDealOnHistoryIsProfitPositive()
  {
   datetime end=TimeCurrent();
   datetime start=end-PeriodSeconds(PERIOD_D1);
   HistorySelect(start,end);

   int deals=HistoryDealsTotal();
   ulong ticket=HistoryDealGetTicket(deals-1);

   double profit=HistoryDealGetDouble(ticket,DEAL_PROFIT);
   return profit>=0;
  }
//+------------------------------------------------------------------+
//| Return the last order price on history
//+------------------------------------------------------------------+
double CMyTrade::LastDealPriceOnHistory()
  {
   datetime end=TimeCurrent();
   datetime start=end-PeriodSeconds(PERIOD_D1);
   HistorySelect(start,end);

   int deals=HistoryDealsTotal();
   ulong ticket=HistoryDealGetTicket(deals-1);

   double price=HistoryDealGetDouble(ticket,DEAL_PRICE);
   return price;
  }
//+------------------------------------------------------------------+
//| Return the current position status with (Volume/Points/Profit)
//+------------------------------------------------------------------+
string CMyTrade::CurrentPositionStatus(void)
  {
   CurrentPositionSelect();

   double volume=PositionGetDouble(POSITION_VOLUME);
   if(volume==0)
      return "Volume: 0 / Profit: 0 / Pt: 0";

   string sVolume=DoubleToString(volume,0);

   string profit=DoubleToString(PositionGetDouble(POSITION_PROFIT),2);

   int digits=(int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS);
   double priceOpen=PositionGetDouble(POSITION_PRICE_OPEN);
   double priceCurrent=PositionGetDouble(POSITION_PRICE_CURRENT);

   double points=NormalizeDouble(priceCurrent-priceOpen,digits);
   if(IsOnSellTrade())
      points=NormalizeDouble(points*-1,digits);
   string sPoints=DoubleToString(points,digits);

   return StringFormat("Volume: %s / Profit: %s / Pt: %s",sVolume,profit,sPoints);
  }
//+------------------------------------------------------------------+
//| Calculate the current points of BreakEven for the current Symbol                                                                 
//+------------------------------------------------------------------+
double CMyTrade::CalculateBreakEven(int baseVolume,double pricePerVolume=0)
  {
   int digits=(int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS);

   MqlDateTime dtServer;
   TimeTradeServer(dtServer);

   datetime end=TimeCurrent();
   datetime start=end-PeriodSeconds(PERIOD_D1);
   HistorySelect(start,end);

   double totalProfit=0;
   int totalVolumes=0;

   int deals=HistoryDealsTotal();
   for(int i=0; i<deals;i++)
     {
      ulong ticket=HistoryDealGetTicket(i);
      if(ticket>0)
        {
         string historySymbol=HistoryDealGetString(ticket,DEAL_SYMBOL);
         if(historySymbol==_Symbol)
           {
            long dealTime=HistoryDealGetInteger(ticket,DEAL_TIME);
            MqlDateTime dealMqlTime;
            TimeToStruct(dealTime,dealMqlTime);

            // Verify if is in the same day of the TradeServer
            if(dtServer.day==dealMqlTime.day)
              {
               double dealProfit=HistoryDealGetDouble(ticket,DEAL_PROFIT);
               totalProfit=NormalizeDouble(totalProfit+dealProfit,digits);

               int dealVolume=(int)HistoryDealGetDouble(ticket,DEAL_VOLUME);
               totalVolumes=totalVolumes+dealVolume;
              }
           }
        }
      else
        {
         PrintFormat("Total number of deals %d, error in selection of the deal"+
                     " with index %d. Error %d",deals,i,GetLastError());
        }
     }

   double breakEven=0;
   double totalPricePerVolume=NormalizeDouble(totalVolumes*pricePerVolume,6);

// first operation doesn't have a profit, so the breakeven is the cost of the volume
   if(totalProfit==0)
     {
      breakEven=NormalizeDouble(totalPricePerVolume*-1,6); // negate the volume, since is expensive.
      return breakEven;
     }

   if(totalProfit!=0)
     {
      totalProfit=NormalizeDouble(totalProfit-totalPricePerVolume,6);
      double volumeWithFactor=NormalizeDouble(baseVolume*SymbolFactor(),6);
      breakEven=NormalizeDouble(totalProfit/volumeWithFactor,digits);
     }

   return breakEven;
  };
//+------------------------------------------------------------------+
//| Calculate current break even and use to set it up with the last order,
//| verifying is on a BUY or SELL trade
//|
//| Example for a BUY operation with break even with positive value:
//| Current price: 50100.
//| BreakEven: 60
//| New Price wil be: 50040
//|
//| Example for a BUY operation with break even with negative value:
//| Current price: 50100.
//| BreakEven: -60
//| New Price wil be: 50160
//|
//| Example for a SELL operation with break even with positive value:
//| Current price: 50100.
//| BreakEven: 60
//| New Price wil be: 50160
//|
//| Example for a BUY operation with break even with negative value:
//| Current price: 50100.
//| BreakEven: -60
//| New Price wil be: 50040
//+------------------------------------------------------------------+
double CMyTrade::CalculateBreakEvenWithLastDeal(int baseVolume,double pricePerVolume=0)
  {
   double breakEven=CalculateBreakEven(baseVolume,pricePerVolume);

   if(IsOnBuyTrade())
      breakEven=NormalizeDouble(breakEven*-1,2);

   return TradePositionSumPrice(breakEven);
  }
//+------------------------------------------------------------------+
//| Enable the sounds for BUY operation and SELL operation                                                                
//+------------------------------------------------------------------+
void CMyTrade::EnableSoundOnOperation(string sellSoundsName="alert",string buySoundsName="alert2")
  {
   m_play_sound_on_operation=true;
   m_sell_trade_sound_name=sellSoundsName;
   m_buy_trade_sound_name=buySoundsName;
   m_error_trade_sound_name="timeout";
  };
//+------------------------------------------------------------------+
//| Play sounds for BUY Operation                                                                 |
//+------------------------------------------------------------------+
void CMyTrade::PlayBuySound()
  {
   if(m_play_sound_on_operation)
      PlaySound(m_buy_trade_sound_name);
  }
//+------------------------------------------------------------------+
//| Play sounds for SELL Operation                                                                |
//+------------------------------------------------------------------+
void CMyTrade::PlaySellSound()
  {
   if(m_play_sound_on_operation)
      PlaySound(m_sell_trade_sound_name);
  }
//+------------------------------------------------------------------+
//| Play sounds for ERROR Operation                                                                |
//+------------------------------------------------------------------+
void CMyTrade::PlayErrorSound()
  {
   if(m_play_sound_on_operation)
      PlaySound(m_error_trade_sound_name);
  }
//+------------------------------------------------------------------+
//| Verify if the Chart has a New Bar                                                                  
//+------------------------------------------------------------------+
bool CMyTrade::IsNewBar(ENUM_TIMEFRAMES currentTimeFrame)
  {
   datetime dtNewBar[1];
   if(CopyTime(_Symbol,currentTimeFrame,0,1,dtNewBar))
     {
      if(m_dt_old_bar!=dtNewBar[0])
        {
         m_dt_old_bar=dtNewBar[0];
         return true;
        }
     }
   else
     {
      Print("Error in copying historical times data, error =",GetLastError());
      ResetLastError();
     }

   return false;
  }
//+------------------------------------------------------------------+
//| Verify if has a trade on operation                                                                  
//+------------------------------------------------------------------+
bool CMyTrade::IsOnTradeOperation(void)
  {
   return IsOnBuyTrade() || IsOnSellTrade();
  }
//+------------------------------------------------------------------+
//| Verify if is on a BUY trade operation
//+------------------------------------------------------------------+
bool CMyTrade::IsOnBuyTrade()
  {
   return m_is_on_buy_trade;
  }
//+------------------------------------------------------------------+
//| Verify if is on a SELL trade operation
//+------------------------------------------------------------------+
bool CMyTrade::IsOnSellTrade()
  {
   return m_is_on_sell_trade;
  }
//+------------------------------------------------------------------+
//| Return the current trade volume
//+------------------------------------------------------------------+
int CMyTrade::CurrentTradeVolume()
  {
   return m_current_trade_volume;
  }
//+------------------------------------------------------------------+
//| Load the Status for TradeOperation using the Current Position
//+------------------------------------------------------------------+
void CMyTrade::LoadTradeOperationFromPosition()
  {
   CurrentPositionSelect();

   m_current_trade_volume=(int)PositionGetDouble(POSITION_VOLUME);
   if(m_current_trade_volume!=0)
     {
      ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      if(type==POSITION_TYPE_BUY)
         m_is_on_buy_trade=true;
      else
         m_is_on_sell_trade=true;
     }
  }
//+------------------------------------------------------------------+
//| Sum the current last deal price with the next price.
//| If the adjustPrice is different from 0. Minus the price with the adjustPrice.
//+------------------------------------------------------------------+
double CMyTrade::TradeLastDealSumPrice(double price,double adjustPrice=0)
  {
   double lastDealPrice=LastDealPriceOnHistory();
   int digits=(int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS);
   double point=SymbolInfoDouble(_Symbol,SYMBOL_POINT);

   price=NormalizeDouble(lastDealPrice+(price*point)-(adjustPrice*point),digits);
   return price;
  };
//+------------------------------------------------------------------+
//| Sum the current position open price with the next price.
//| If the adjustPrice is different from 0. Minus the price with the adjustPrice.                                                                 |
//+------------------------------------------------------------------+
double CMyTrade::TradePositionSumPrice(double price,double adjustPrice=0)
  {
   double positionPrice=PositionGetDouble(POSITION_PRICE_OPEN);
   int digits=(int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS);
   double point=SymbolInfoDouble(_Symbol,SYMBOL_POINT);

   price=NormalizeDouble(positionPrice+(price*point)-(adjustPrice*point),digits);
   return price;
  }
//+------------------------------------------------------------------+
//| Select the current Position                                                                  
//+------------------------------------------------------------------+
void CMyTrade::CurrentPositionSelect()
  {
   ENUM_POSITION_TYPE type=POSITION_TYPE_BUY;
   if(IsOnSellTrade())
      type=POSITION_TYPE_SELL;

// load current position
   PositionSelect(_Symbol);
   int retry=1;

   while(retry<20)
     {
      if(PositionGetInteger(POSITION_TYPE)==type)
         break;

      Sleep(retry*200); // sleep for SelectRetryCount * 100 mS
      retry++;

      // load again the current position
      PositionSelect(_Symbol);
     }
  };
//+------------------------------------------------------------------+
//| Return the current symbol Factor                                                                  |
//+------------------------------------------------------------------+
double CMyTrade::SymbolFactor()
  {
   if(StringFind(_Symbol,"IND")!=-1)
      return 1;
   if(StringFind(_Symbol,"WIN")!=-1)
      return 0.2;

   if(StringFind(_Symbol,"DOL")!=-1)
      return 50;
   if(StringFind(_Symbol,"WDO")!=-1)
      return 10;

   return 1;
  };

//+------------------------------------------------------------------+
