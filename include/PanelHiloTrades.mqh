//+------------------------------------------------------------------+
//|                                              PanelHiloTrades.mq5 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Frederico Benevides"
#property link      "fredbene@gmail.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Class to work with trades
//+------------------------------------------------------------------+
class CHiLoTrades
  {
private:
   double            highHiLo[1];
   double            lowHiLo[1];

   double            highInvalidHiLo[1];
   double            lowInvalidHiLo[1];

   bool              isOnBuyTrade;
   bool              isOnSellTrade;
   int               currentTradeVolume;

public:
   virtual void      OnTick(int handle,int minRatesTotal);

   virtual bool      isOnTradeOperation(void);

   virtual void      tradeBuyOpen(void);
   virtual void      tradeSellOpen(void);

   virtual void      tradeBuyClose(void);
   virtual void      tradeSellClose(void);

   virtual void      tradeStart(bool buy,bool sell);
   virtual void      tradeStop(bool buy,bool sell);
  };
//+------------------------------------------------------------------+
//| Verify is there any operation for each candle. 
//+------------------------------------------------------------------+
void CHiLoTrades::OnTick(int handle,int minRatesTotal)
  {
   if(BarsCalculated(handle)<minRatesTotal)
      return;

   if(myTrade.isNewBar(_Symbol,InpTradeTimeFrame))
     {
      if(CopyBuffer(handle,4,0,1,highHiLo)<=0)
         return;

      if(CopyBuffer(handle,5,0,1,lowHiLo)<=0)
         return;

      if(CopyBuffer(handle,8,0,1,highInvalidHiLo)<=0)
         return;

      if(CopyBuffer(handle,9,0,1,lowInvalidHiLo)<=0)
         return;

      //--- close operation if there is a valid and invalid HiLo.
      if(highHiLo[0]!=EMPTY_VALUE || highInvalidHiLo[0]!=EMPTY_VALUE)
         tradeBuyClose();

      //--- open operation only if is a valid HiLo
      if(highHiLo[0]!=EMPTY_VALUE)
        {
         if(PanelHiLoDialog.isClosePLChecked())
            PanelHiLoDialog.initToDefaults();
         else if(PanelHiLoDialog.isSellChecked())
            tradeSellOpen();
        }

      //--- close operation if there is a valid and invalid HiLo.
      if(lowHiLo[0]!=EMPTY_VALUE || lowInvalidHiLo[0]!=EMPTY_VALUE)
         tradeSellClose();

      //--- open operation only if is a valid HiLo
      if(lowHiLo[0]!=EMPTY_VALUE)
        {
         if(PanelHiLoDialog.isClosePLChecked())
            PanelHiLoDialog.initToDefaults();
         else if(PanelHiLoDialog.isBuyChecked())
            tradeBuyOpen();
        }
     }
  }
//+------------------------------------------------------------------+
//| Open a BUY operation
//+------------------------------------------------------------------+
void CHiLoTrades::tradeBuyOpen()
  {
   if(isOnTradeOperation())
     {
      Print("Sell will not be executed since is already on Buy/Sell Trade Operation **********");
      return;
     }

   currentTradeVolume=PanelHiLoDialog.getCurrentVolume();
   int takeProfit=0;
   if(myTrade.executeBuyTrade(_Symbol,"tradeBuyOpen",currentTradeVolume,takeProfit))
     {
      isOnBuyTrade=true;
     }

   Print("********** Executed BUY OPEN operation! **********");
  }
//+------------------------------------------------------------------+
//| Open a SELL operation
//+------------------------------------------------------------------+
void CHiLoTrades::tradeSellOpen()
  {
   if(isOnTradeOperation())
     {
      Print("Sell will not be executed since is already on Buy/Sell Trade Operation **********");
      return;
     }

   currentTradeVolume=PanelHiLoDialog.getCurrentVolume();
   int takeProfit=0;
   if(myTrade.executeSellTrade(_Symbol,"tradeSellOpen",currentTradeVolume,takeProfit))
     {
      isOnSellTrade=true;
     }

   Print("********** Executed SELL OPEN operation! **********");
  }
//+------------------------------------------------------------------+
//| Close a BUY operation|
//+------------------------------------------------------------------+
void CHiLoTrades::tradeBuyClose(void)
  {
   if(isOnBuyTrade)
     {
      int takeProfit=0;
      if(myTrade.executeSellTrade(_Symbol,"tradeBuyClose",currentTradeVolume,takeProfit,false))
        {
         isOnBuyTrade=false;
         PanelHiLoDialog.upMartingale();
        }

      Print("********** Executed BUY CLOSE operation! **********");
     }
  }
//+------------------------------------------------------------------+
//| Close a SELL operation
//+------------------------------------------------------------------+
void CHiLoTrades::tradeSellClose(void)
  {
   if(isOnSellTrade)
     {
      int takeProfit=0;
      if(myTrade.executeBuyTrade(_Symbol,"tradeSellClose",currentTradeVolume,takeProfit,false))
        {
         isOnSellTrade=false;
         PanelHiLoDialog.upMartingale();
        }

      Print("********** Executed SELL CLOSE operation! **********");
     }
  }
//+------------------------------------------------------------------+
//| Start a trade                                                                 |
//+------------------------------------------------------------------+
void CHiLoTrades::tradeStart(bool buy,bool sell)
  {
   if(isOnTradeOperation())
     {
      string warningMsg="START operation was NOT executed. You are already in operation!";
      Print(warningMsg);
      MessageBox(warningMsg,"Warning",MB_OK);
      return;
     }

   if(buy && sell)
     {
      string warningMsg="START operation was NOT executed. Please specify only BUY or SELL operation to use the Start operation";
      Print(warningMsg);
      MessageBox(warningMsg,"Warning",MB_OK);
      return;
     }

   currentTradeVolume=PanelHiLoDialog.getCurrentVolume();
   bool executed=false;

   if(!buy && sell)
     {
      if(myTrade.executeSellTrade(_Symbol,"OnClickStartButton",currentTradeVolume,0))
        {
         isOnSellTrade=true;
         executed=true;
        }
     }

   if(buy && !sell)
     {
      if(myTrade.executeBuyTrade(_Symbol,"OnClickStartButton",currentTradeVolume,0))
        {
         isOnBuyTrade=true;
         executed=true;
        }
     }

   if(executed)
      Print("********** Executed START operation! **********");
  }
//+------------------------------------------------------------------+
//| Stop a trade                                                                 |
//+------------------------------------------------------------------+
void CHiLoTrades::tradeStop(bool buy,bool sell)
  {
   bool executed=false;

   if(isOnBuyTrade)
     {
      if(myTrade.executeSellTrade(_Symbol,"OnClickStopButton",currentTradeVolume,0,false))
        {
         isOnBuyTrade=false;
         executed=true;
        }
     }

   if(isOnSellTrade)
     {
      if(myTrade.executeBuyTrade(_Symbol,"OnClickStopButton",currentTradeVolume,0,false))
        {
         isOnSellTrade=false;
         executed=true;
        }
     }

   PanelHiLoDialog.resetVolumesToDefault();

   if(executed)
      Print("********** Executed STOP operation! **********");
  }
//+------------------------------------------------------------------+
//| Verify if has a trade on operation                                                                  |
//+------------------------------------------------------------------+
bool CHiLoTrades::isOnTradeOperation(void)
  {
   return isOnBuyTrade || isOnSellTrade;
  }

//+------------------------------------------------------------------+
