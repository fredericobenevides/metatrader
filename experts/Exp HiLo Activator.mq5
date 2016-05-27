//+------------------------------------------------------------------+
//|                                           Exp HiLo Activator.mq5 |
//|                                              Frederico Benevides |
//|                                               fredbene@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Frederico Benevides"
#property link      "fredbene@gmail.com"
#property version   "1.20"

#resource "\\Indicators\\HiLo Activator.ex5"
#include <MyTrades.mqh>

//+------------------------------------------------------------------+
//| HiLo Activator Input Parameters                                  |
//+------------------------------------------------------------------+
//--- input parameters
input string         InpHiLoData="------------------------------";    // --------------- HiLo ---------------
input int            InpPeriod=1;                                     // Period
input ENUM_MA_METHOD InpMaMethod=MODE_SMMA;                           // Method
input bool           InpArrowInFirstHiLo=false;                       // Add an arrow to the first HiLo
input bool           InpArrowInSecondHiLo=true;                       // Add an arrow to the second HiLo
input bool           InpArrowInCurrentCandle=true;                    // Add an arrow to the current candle
input bool           InpShowHiLoLine=false;                           // Show the line of HiLo

//--- input parameters for Trades
input string          InpTradesData="------------------------------"; // --------------- Trades ---------------
input ENUM_TIMEFRAMES InpTradeTimeFrame=PERIOD_CURRENT;               // Default TimeFrame
input int             InpTradeVolume=1;                               // Default volume to do trades operations
input double          InpTradeVolumeFactor=2.0;                       // Default factor for the next volume operation.
input double          InpTradeTakeProfit=0.0;                         // Default value of Take Profit
input bool            InpSetTradeSound=false;                         // Play sound for each operation on Buy or Sell trades.
input string          InpSellTradeSound="alert";                      // The Sound's name for Sell trade operations.
input string          InpBuyTradeSound="alert2";                      // The Sound's name for Buy trade operations.

//--- global vars for HiLo Activator
int MinRatesTotal;

//--- global vars for Expert
int HiLoCustomHandle;
datetime dtOldBar;
double HighHiLo[3];
double LowHiLo[3];

// buttons
bool isTradeButtonSelected;
bool isBuyButtonSelected;
bool isSellButtonSelected;

// HiLo detection
bool isHighHiLo;
bool isLowHiLo;
bool isHiLoToOperate;

// trade
CMyTrade myTrade;
bool isOnBuyTrade;
bool isOnSellTrade;
int currentTradeVolume;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- getting the HiLo Activator indicator handle
   Print("********** Initting Exp HiLo Activator **********");

   HiLoCustomHandle=iCustom(Symbol(),InpTradeTimeFrame,"HiLo Activator.ex5",
                            InpHiLoData,InpPeriod,InpMaMethod,InpArrowInFirstHiLo,InpArrowInSecondHiLo,
                            InpArrowInCurrentCandle,InpShowHiLoLine);
   if(HiLoCustomHandle==INVALID_HANDLE)
      Print("Failed to get handle of HiLo activator indicator");

   MinRatesTotal=InpPeriod+1; // Period + current candle

   initDefaultStatus();
   printDataStatus();

   createTradeButtons();
   myTrade.loadTradeConfig();

   if(InpSetTradeSound)
      myTrade.enableSoundOnOperation(InpSellTradeSound,InpBuyTradeSound);

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Print("********** Deinitting Exp HiLo Activator **********");

   IndicatorRelease(HiLoCustomHandle);
   destroyTradeButtons();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---- checking the number of bars to be enough for calculation
   if(BarsCalculated(HiLoCustomHandle)<MinRatesTotal)
      return;

   if(myTrade.isNewBar(_Symbol,InpTradeTimeFrame))
     {
      if(CopyBuffer(HiLoCustomHandle,8,0,3,HighHiLo)<=0)
         return;

      if(CopyBuffer(HiLoCustomHandle,9,0,3,LowHiLo)<=0)
         return;

      if(HighHiLo[0]==EMPTY_VALUE && HighHiLo[1]!=EMPTY_VALUE && HighHiLo[2]!=EMPTY_VALUE)
        {
         isHighHiLo= true;
         isLowHiLo = false;

         isHiLoToOperate=true;
        }
      else if(LowHiLo[0]==EMPTY_VALUE && LowHiLo[1]!=EMPTY_VALUE && LowHiLo[2]!=EMPTY_VALUE)
        {
         isHighHiLo=false;
         isLowHiLo=true;

         isHiLoToOperate=true;
        }
      else
        {
         isHiLoToOperate=false;
        }

      if(isTradeButtonSelected && isHiLoToOperate)
        {
         if(isHighHiLo) // sell operation
           {
            tradeBuyClose();

            if(isSellButtonSelected)
               tradeSellOpen();
           }

         if(isLowHiLo) // buy operation
           {
            tradeSellClose();

            if(isBuyButtonSelected)
               tradeBuyOpen();
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Verify the events for object mouse click                                                                 |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,          // event identifier
                  const long &lparam,    // parameter of the event of type long
                  const double &dparam,   // parameter of the event of type double
                  const string &sparam)   // parameter of the event of type string
  {
   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      if(sparam=="TRADE_BUTTON")
         eventEnableDisableButton();

      if(sparam=="BUY")
         eventBuyButton();

      if(sparam=="SELL")
         eventSellButton();

      if(sparam=="START")
         eventStartButton();

      if(sparam=="STOP")
         eventStopButton();

      ChartRedraw();
     }
  }
//+------------------------------------------------------------------+
//| Event on Trade Transaction to find a trade runned by a Take Profit
//+------------------------------------------------------------------+
void  OnTradeTransaction(
                         const MqlTradeTransaction& trans,        // trade transaction structure
                         const MqlTradeRequest&     request,      // request structure
                         const MqlTradeResult&      result        // result structure
                         )
  {
   if(InpTradeTakeProfit==0.0)
      return;

   if(trans.type!=TRADE_TRANSACTION_HISTORY_ADD)
      return;

// verify on the current day
   bool hadTakeProfitOnHistory=myTrade.hadTakeProfitOnHistory(PERIOD_D1);
   if(hadTakeProfitOnHistory)
     {
      resetCurrentVolumeToInpTradeVolume();

      if(isOnBuyTrade)
        {
         isOnBuyTrade=false;
         Print("********** Executed BUY TAKE PROFIT operation! **********");
        }
      else
        {
         isOnSellTrade=false;
         Print("********** Executed BUY TAKE PROFIT operation! **********");
        }
     }
  }
//+------------------------------------------------------------------+
//| Verify if has a trade on operation                                                                  |
//+------------------------------------------------------------------+
bool isOnTradeOperation()
  {
   return isOnBuyTrade || isOnSellTrade;
  }
//+------------------------------------------------------------------+
//| Init default status for global variables                                                                 |
//+------------------------------------------------------------------+
void initDefaultStatus()
  {
   if(!isTradeButtonSelected)
     {
      // buttons
      isTradeButtonSelected=false;
      isBuyButtonSelected=false;
      isSellButtonSelected=false;

      enableBuyButton();
      enableSellButton();

      // HiLo detection
      isHighHiLo=false;
      isLowHiLo=false;
      isHiLoToOperate=false;

      // trade
      isOnBuyTrade=false;
      isOnSellTrade=false;
      resetCurrentVolumeToInpTradeVolume();
     }
  }
//+------------------------------------------------------------------+
//| Reset to default Trade Status
//+------------------------------------------------------------------+
void resetDefaultTradeStatus()
  {
   isTradeButtonSelected=false;
   initDefaultStatus();
  }
//+------------------------------------------------------------------+
//| Print data status of the HiLo Activator                                                                 |
//+------------------------------------------------------------------+
void printDataStatus()
  {
   Print("********** Operations Buttons **********");
   Print("isTradeButtonSelected: ",isTradeButtonSelected);
   Print("isBuyButtonSelected: ",isBuyButtonSelected);
   Print("isSellButtonSelected: ",isSellButtonSelected);

   Print("********** HiLo detection **********");
   Print("isHighHiLo: ",isHighHiLo);
   Print("isLowHiLo: ",isLowHiLo);
   Print("isHiLoToOperate: ",isHiLoToOperate);

   Print("********** Trades **********");
   Print("isOnBuyTrade: ",isOnBuyTrade);
   Print("isOnSellTrade: ",isOnSellTrade);

   Print("********** Trades Input **********");
   Print("InpTradeTimeFrame: ",InpTradeTimeFrame," minutes");
   Print("InpTradeTakeProfit: ",InpTradeTakeProfit);
   Print("InpTradeVolume: ",InpTradeVolume);
   Print("currentTradeVolume: ",currentTradeVolume);
   Print("InpTradeVolumeFactor: ",InpTradeVolumeFactor);
  }
//+------------------------------------------------------------------+
//| Create the default buttons on initting the Expert
//+------------------------------------------------------------------+
void createTradeButtons()
  {
   createTradeOrNoTradeButton();
   createBuyButton();
   createSellButton();

// when changing between timeframe, it's necessary to check this.
   if(isBuyButtonSelected || isSellButtonSelected)
      createStartButton();

   if(isOnTradeOperation())
      createStopButton();
  }
//+------------------------------------------------------------------+
//| Destroy all buttons
//+------------------------------------------------------------------+
void destroyTradeButtons()
  {
   ObjectDelete(0,"TRADE_BUTTON");
   destroyBuyButton();
   destroySellButton();
   destroyStartButton();
   destroyStopButton();
  }
//+------------------------------------------------------------------+
//| Create the Trade Button                                                                 |
//+------------------------------------------------------------------+
void createTradeOrNoTradeButton()
  {
   createButton("TRADE_BUTTON","Enable",200,25,10,int(ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS)-125));
   if(isTradeButtonSelected)
      showTradeButton();
   else
      showNoTradeButton();
  }
//+------------------------------------------------------------------+
//| Create the Buy Button
//+------------------------------------------------------------------+
void createBuyButton()
  {
   createButton("BUY","Buy",100,25,10,int(ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS)-100),clrBlack,isBuyButtonSelected);
  }
//+------------------------------------------------------------------+
//| Create the Sell Button
//+------------------------------------------------------------------+
void createSellButton()
  {
   createButton("SELL","Sell",100,25,110,int(ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS)-100),clrBlack,isSellButtonSelected);
  }
//+------------------------------------------------------------------+
//| Create the Start Button                                                                 |
//+------------------------------------------------------------------+
void createStartButton()
  {
   createButton("START","Start",200,25,10,int(ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS)-75));
  }
//+------------------------------------------------------------------+
//| Create the Stop Button                                                                 |
//+------------------------------------------------------------------+
void createStopButton()
  {
   createButton("STOP","Stop",200,25,10,int(ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS)-75));
  }
//+------------------------------------------------------------------+
//| Destroy the Buy Button                                                                 |
//+------------------------------------------------------------------+
void destroyBuyButton()
  {
   ObjectDelete(0,"BUY");
  }
//+------------------------------------------------------------------+
//| Destroy the Sell Button                                                                 |
//+------------------------------------------------------------------+
void destroySellButton()
  {
   ObjectDelete(0,"SELL");
  }
//+------------------------------------------------------------------+
//| Destroy the Start Button                                                                 |
//+------------------------------------------------------------------+
void destroyStartButton()
  {
   ObjectDelete(0,"START");
  }
//+------------------------------------------------------------------+
//| Destroy the Stop Button
//+------------------------------------------------------------------+
void destroyStopButton()
  {
   ObjectDelete(0,"STOP");
  }
//+------------------------------------------------------------------+
//| Enable Buy button as selected
//+------------------------------------------------------------------+
void enableBuyButton()
  {
   ObjectSetInteger(0,"BUY",OBJPROP_STATE,false);
  }
//+------------------------------------------------------------------+
//| Enable Sell button as selected
//+------------------------------------------------------------------+
void enableSellButton()
  {
   ObjectSetInteger(0,"SELL",OBJPROP_STATE,false);
  }
//+------------------------------------------------------------------+
//| Disable Buy button as selected
//+------------------------------------------------------------------+
void disableBuyButton()
  {
   ObjectSetInteger(0,"BUY",OBJPROP_STATE,true);
  }
//+------------------------------------------------------------------+
//| Disable Sell button as unselected                                                                  |
//+------------------------------------------------------------------+
void disableSellButton()
  {
   ObjectSetInteger(0,"SELL",OBJPROP_STATE,true);
  }
//+------------------------------------------------------------------+
//| Show the button with the text Enable
//+------------------------------------------------------------------+
void showTradeButton()
  {
   ObjectSetString(0,"TRADE_BUTTON",OBJPROP_TEXT,"Trade");
   ObjectSetInteger(0,"TRADE_BUTTON",OBJPROP_COLOR,clrGreen);
   ObjectSetInteger(0,"TRADE_BUTTON",OBJPROP_STATE,true);
  }
//+------------------------------------------------------------------+
//| Show the button with the text Disable
//+------------------------------------------------------------------+
void showNoTradeButton()
  {
   ObjectSetString(0,"TRADE_BUTTON",OBJPROP_TEXT,"No Trade");
   ObjectSetInteger(0,"TRADE_BUTTON",OBJPROP_COLOR,clrRed);
   ObjectSetInteger(0,"TRADE_BUTTON",OBJPROP_STATE,false);
  }
//+------------------------------------------------------------------+
//| Create a button with specific sizes and distances
//+------------------------------------------------------------------+
void createButton(string name,string title,int xSize,int ySize,int xDistance,int yDistance,color textColor=clrBlack,bool selected=false)
  {
   ObjectCreate(0,name,OBJ_BUTTON,0,0,0);
   ObjectSetString(0,name,OBJPROP_TEXT,title);
   ObjectSetInteger(0,name,OBJPROP_COLOR,textColor);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,xSize);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,ySize);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,xDistance);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,yDistance);
   ObjectSetInteger(0,name,OBJPROP_STATE,selected);
  }
//+------------------------------------------------------------------+
//| Events for Enable Disable Button
//+------------------------------------------------------------------+
void eventEnableDisableButton()
  {
   isTradeButtonSelected=!isTradeButtonSelected;

   if(isTradeButtonSelected)
     {
      Print("********** Expert enabled on ",Symbol(),"! **********");
      Print(">> InpTradeTimeFrame: ",InpTradeTimeFrame," minutes");

      showTradeButton();
     }
   else
     {
      Print("********** Expert disabled on ",Symbol(),"! **********");
      showNoTradeButton();

      isBuyButtonSelected=false;
      disableBuyButton();

      isSellButtonSelected=false;
      disableSellButton();

      destroyStartButton();
      destroyStopButton();

      resetDefaultTradeStatus();
     }

   ChartRedraw();
  }
//+------------------------------------------------------------------+
//| Events for Buy Button
//+------------------------------------------------------------------+
void eventBuyButton()
  {
   if(isTradeButtonSelected)
     {
      isBuyButtonSelected=!isBuyButtonSelected;

      if(isBuyButtonSelected)
        {
         Print("********** Enable BUY mode operation! **********");
         Print("BUY:");
         Print("  --> Take Profit: ",InpTradeTakeProfit);
         Print("  --> Current Volume: ",currentTradeVolume,". Volume Factor (x",InpTradeVolumeFactor,")");

         // Show the start button if is not on operation
         if(!isOnTradeOperation())
            createStartButton();

         // Destroy the start button if the sell operation is enabled.
         if(isSellButtonSelected)
            destroyStartButton();
        }
      else
        {
         Print("********** Disable BUY mode operation! **********");

         // create Start button if the Sell Operation is selected and is not on operation.
         if(isSellButtonSelected && !isOnTradeOperation())
            createStartButton();
         else if(!isSellButtonSelected) // Destroy the start button since none of the operations are selected.
           {
            destroyStartButton();
           }
        }
     }
   else // the operation is not enabled
     {
      isBuyButtonSelected=false;
      disableBuyButton();
     }
  }
//+------------------------------------------------------------------+
//| Events for Sell Button
//+------------------------------------------------------------------+
void eventSellButton()
  {
   if(isTradeButtonSelected)
     {
      isSellButtonSelected=!isSellButtonSelected;

      if(isSellButtonSelected)
        {
         Print("********** Enabled SELL mode operation! **********");
         Print("SELL:");
         Print("  --> Take Profit: ",InpTradeTakeProfit);
         Print("  --> Current Volume: ",currentTradeVolume,". Volume Factor (x",InpTradeVolumeFactor,")");

         // Show the start button if is not on operation
         if(!isOnTradeOperation())
            createStartButton();

         // Destroy the start button if the buy operation is enabled.
         if(isBuyButtonSelected)
            destroyStartButton();
        }
      else
        {
         Print("********** Disabled SELL mode operation! **********");

         // create Start button if the Buy Operation is selected and is not on operation.
         if(isBuyButtonSelected && !isOnTradeOperation())
            createStartButton();
         else if(!isBuyButtonSelected) // Destroy the start button since none of the operations are selected.
           {
            destroyStartButton();
           }
        }
     }
   else // the operation is not enabled
     {
      isSellButtonSelected=false;
      disableSellButton();
     }
  }
//+------------------------------------------------------------------+
//| Events for Start Button
//+------------------------------------------------------------------+
void eventStartButton()
  {
   bool executed=false;
   if(!isBuyButtonSelected && isSellButtonSelected)
     {
      if(myTrade.executeSellTrade(_Symbol,"eventStartButton",currentTradeVolume,InpTradeTakeProfit))
        {
         isOnSellTrade=true;

         destroyStartButton();
         createStopButton();

         executed=true;
        }
     }

   if(isBuyButtonSelected && !isSellButtonSelected)
     {
      if(myTrade.executeBuyTrade(_Symbol,"eventStartButton",currentTradeVolume,InpTradeTakeProfit))
        {
         isOnBuyTrade=true;

         destroyStartButton();
         createStopButton();

         executed=true;
        }
     }

   if(isBuyButtonSelected && isSellButtonSelected)
     {
      Print("START operation was NOT executed. Please specify only BUY or SELL operation to use the Start operation");
      destroyStartButton();
      createStartButton();
     }

   if(executed)
      Print("********** Executed START operation! **********");
  }
//+------------------------------------------------------------------+
//| Events for Stop Button
//+------------------------------------------------------------------+
void eventStopButton()
  {
   if(isOnBuyTrade)
     {
      if(myTrade.executeSellTrade(_Symbol,"eventStopButton",currentTradeVolume,InpTradeTakeProfit,false))
        {
         isOnBuyTrade=false;
        }
     }

   if(isOnSellTrade)
     {
      if(myTrade.executeBuyTrade(_Symbol,"eventStopButton",currentTradeVolume,InpTradeTakeProfit,false))
        {
         isOnSellTrade=false;
        }
     }

   destroyStopButton();
   resetCurrentVolumeToInpTradeVolume();

// Show the start button only if buy or sell is selected.
   if(isBuyButtonSelected || isSellButtonSelected)
      createStartButton();

   Print("********** Executed STOP operation! **********");
  }
//+------------------------------------------------------------------+
//| Reset the current volume and set to be equal to the InpTradeVolume
//+------------------------------------------------------------------+
void resetCurrentVolumeToInpTradeVolume()
  {
   currentTradeVolume=InpTradeVolume;
  }
//+------------------------------------------------------------------+
//| Calculate the next volume to use in currentVolume using the InpTradeFactor
//+------------------------------------------------------------------+
void calculateNextVolumeUsingTradeFactor()
  {
   currentTradeVolume=int(round(currentTradeVolume*InpTradeVolumeFactor));
  }
//+------------------------------------------------------------------+
//| Open a BUY operation
//+------------------------------------------------------------------+
void tradeBuyOpen()
  {
   if(isOnTradeOperation())
     {
      Print("Sell will not be executed since since is already on Buy/Sell Trade Operation **********");
      return;
     }

   if(myTrade.executeBuyTrade(_Symbol,"tradeBuyOpen",currentTradeVolume,InpTradeTakeProfit))
     {
      isOnBuyTrade=true;

      destroyStartButton();
      createStopButton();
     }

   Print("********** Executed BUY OPEN operation! **********");
  }
//+------------------------------------------------------------------+
//| Open a SELL operation
//+------------------------------------------------------------------+
void tradeSellOpen()
  {
   if(isOnTradeOperation())
     {
      Print("Sell will not be executed since since is already on Buy/Sell Trade Operation **********");
      return;
     }

   if(myTrade.executeSellTrade(_Symbol,"tradeSellOpen",currentTradeVolume,InpTradeTakeProfit))
     {
      isOnSellTrade=true;

      destroyStartButton();
      createStopButton();
     }

   Print("********** Executed SELL OPEN operation! **********");
  }
//+------------------------------------------------------------------+
//| Close a BUY operation|
//+------------------------------------------------------------------+
void tradeBuyClose()
  {
   if(isOnBuyTrade)
     {
      if(myTrade.executeSellTrade(_Symbol,"tradeBuyClose",currentTradeVolume,InpTradeTakeProfit,false))
        {
         isOnBuyTrade=false;

         destroyStopButton();
         createStartButton();

         calculateNextVolumeUsingTradeFactor();
        }

      Print("********** Executed BUY CLOSE operation! **********");
     }
  }
//+------------------------------------------------------------------+
//| Close a SELL operation
//+------------------------------------------------------------------+
void tradeSellClose()
  {
   if(isOnSellTrade)
     {
      if(myTrade.executeBuyTrade(_Symbol,"tradeSellClose",currentTradeVolume,InpTradeTakeProfit,false))
        {
         isOnSellTrade=false;

         destroyStopButton();
         createStartButton();

         calculateNextVolumeUsingTradeFactor();
        }

      Print("********** Executed SELL CLOSE operation! **********");
     }
  }
//+------------------------------------------------------------------+
