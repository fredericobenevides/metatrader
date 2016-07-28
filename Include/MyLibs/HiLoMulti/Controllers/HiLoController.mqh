//+------------------------------------------------------------------+
//|                                               HiLoController.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Frederico Benevides"
#property link      "fredbene@gmail.com"

#include <Arrays\ArrayInt.mqh>
#include <Arrays\List.mqh>

#include <MyLibs\HiLoMulti\Models\HiLoMaHandle.mqh>
#include <MyLibs\HiLoMulti\Models\EnumOperations.mqh>
#include <MyLibs\HiLoMulti\Views\HiLoMultiDialog.mqh>

#include <MyLibs\Trade\TradesUtils.mqh>
#include <MyLibs\Trade\TradesService.mqh>
//+------------------------------------------------------------------+
//| Controller for HiLo
//+------------------------------------------------------------------+
class CHiLoController
  {
   CList            *m_list_hilo_ma;
   CTradesService   *m_trades_service;
   CTradesUtils      m_utils;

protected:
   CHiLoMultiDialog  m_hilo_multi_dialog;

public:
                     CHiLoController();
                    ~CHiLoController();

   void              Destroy(int reason);
   void              OnTick();
   void              OnTradeTransaction(const MqlTradeTransaction &trans,const MqlTradeRequest &request,const MqlTradeResult &result);
   void              OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam);

   void              AddModel(CHiLoMaHandle *hiloMa);

   void              InitTradeSound(string sellSoundName,string buySoundName) { m_trades_service.EnableSoundOnOperation(sellSoundName,buySoundName); }
   bool              InitAll();

protected:
   bool              InitModels();
   bool              InitView();

   void              AddModelsToView();

   void              TradeBuyOpen(int index,CTrades *trades);
   void              TradeSellOpen(int index,CTrades *trades);
   void              TradeBuyClose(int index,CTrades *trades);
   void              TradeSellClose(int index,CTrades *trades);

   void              VerifyIfLoadPositionTicket(CTrades *trades);
   void              VerifyIfLoadTakeProfitTicket(CTrades *trades);
   void              VerifyIfLoadStopLossTicket(CTrades *trades);

   void              VerifyIfPlaceTakeProfit(CTrades *trades);
   void              VerifyIfPlaceStopLoss(CTrades *trades);

   void              DestroyTpSlIfTicketAddedToHistory(ulong ticket);
  };
//+------------------------------------------------------------------+
//| Constructor
//+------------------------------------------------------------------+
CHiLoController::CHiLoController(void)
  {
   m_list_hilo_ma=new CList;

   long magicNumber=m_utils.GenerateMagicNumber();
   m_trades_service=new CTradesService(magicNumber);
  }
//+------------------------------------------------------------------+
//| Destructor
//+------------------------------------------------------------------+
CHiLoController::~CHiLoController(void)
  {
// destroy the models
   for(int i=0;i<m_list_hilo_ma.Total();i++)
     {
      CHiLoMaHandle *hma=m_list_hilo_ma.GetNodeAtIndex(i);
      delete hma;
     }

   delete m_list_hilo_ma;
   delete m_trades_service;
  }
//+------------------------------------------------------------------+
//| Destroy everything
//+------------------------------------------------------------------+
CHiLoController::Destroy(int reason)
  {
// destroy the view
   m_hilo_multi_dialog.Destroy(reason);

// destroy the models
   for(int i=0;i<m_list_hilo_ma.Total();i++)
     {
      CHiLoMaHandle *hma=m_list_hilo_ma.GetNodeAtIndex(i);
      hma.Destroy();
     }
  }
//+------------------------------------------------------------------+
//| Verify is there any operation for each candle. 
//+------------------------------------------------------------------+
void CHiLoController::OnTick()
  {
// verify operation for each trade
   for(int i=0;i<m_list_hilo_ma.Total();i++)
     {
      CHiLoMaHandle *hma=m_list_hilo_ma.GetNodeAtIndex(i);
      CTrades *trades=hma.GetTrades();

      VerifyIfLoadPositionTicket(trades);
      VerifyIfLoadTakeProfitTicket(trades);
      VerifyIfLoadStopLossTicket(trades);

      VerifyIfPlaceTakeProfit(trades);
      VerifyIfPlaceStopLoss(trades);

      // verify if exist operations for current trade
      CArrayInt *listOperations=hma.VerifyTypeOperation();
      if(listOperations==NULL)
         continue;

      // verify what type of operation for current trade
      for(int j=0;j<listOperations.Total();j++)
        {
         ENUM_OPERATIONS operation=(ENUM_OPERATIONS)listOperations.At(j);
         switch(operation)
           {
            case BUY_OPEN_OPERATION:
               TradeBuyOpen(i,trades);
               break;
            case SELL_OPEN_OPERATION:
               TradeSellOpen(i,trades);
               break;
            case BUY_CLOSE_OPERATION:
               TradeBuyClose(i,trades);
               break;
            case SELL_CLOSE_OPERATION:
               TradeSellClose(i,trades);
               break;
            default: // NO_OPERATION
               continue;
           }
        }

      // remove this list operation
      listOperations.Shutdown();
     }
  }
//+------------------------------------------------------------------+
//| Event onTradeTransaction to find a trade runned by a Take Profit or Stop Loss
//+------------------------------------------------------------------+
void CHiLoController::OnTradeTransaction(const MqlTradeTransaction &trans,
                                         const MqlTradeRequest &request,
                                         const MqlTradeResult &result)
  {
   if(trans.type==TRADE_TRANSACTION_HISTORY_ADD)
     {
      if(trans.order_type==ORDER_TYPE_BUY_LIMIT
         || trans.order_type== ORDER_TYPE_BUY_STOP
         || trans.order_type== ORDER_TYPE_SELL_LIMIT
         || trans.order_type== ORDER_TYPE_SELL_STOP)
        {
         DestroyTpSlIfTicketAddedToHistory(trans.order);
        }
     }
  }
//+------------------------------------------------------------------+
//| Chart event
//+------------------------------------------------------------------+
void  CHiLoController::OnChartEvent(const int id,// event ID  
                                    const long& lparam,   // event parameter of the long type
                                    const double& dparam, // event parameter of the double type
                                    const string& sparam) // event parameter of the string type
  {
   m_hilo_multi_dialog.ChartEvent(id,lparam,dparam,sparam);
  }
//+------------------------------------------------------------------+
//| Add the HiLoMa to the controller
//+------------------------------------------------------------------+
void CHiLoController::AddModel(CHiLoMaHandle *hiloMa)
  {
   hiloMa.GetTrades().AddTradesService(m_trades_service);
   m_list_hilo_ma.Add(hiloMa);
  }
//+------------------------------------------------------------------+
//| Init models and views
//+------------------------------------------------------------------+
bool CHiLoController::InitAll()
  {
   AddModelsToView();

   bool result=InitModels();
   if(result==false)
      return result;

   result=InitView();
   if(result==false)
      return result;

   return result;
  }
//+------------------------------------------------------------------+
//| Init all models
//+------------------------------------------------------------------+
bool CHiLoController::InitModels()
  {
   for(int i=0;i<m_list_hilo_ma.Total();i++)
     {
      CHiLoMaHandle *hma=m_list_hilo_ma.GetNodeAtIndex(i);

      int handle=hma.InitHandle();
      if(handle==INVALID_HANDLE)
         return false;
     }

   return true;
  }
//+------------------------------------------------------------------+
//| Init the view
//+------------------------------------------------------------------+
bool CHiLoController::InitView()
  {
   int y1=int(ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS)-250);
   int y2=int(ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS)-20);

   if(!m_hilo_multi_dialog.Create(0,"",0,20,y1,450,y2))
      return(INIT_FAILED);

   m_hilo_multi_dialog.Run();

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Add models to view
//+------------------------------------------------------------------+
void CHiLoController::AddModelsToView()
  {
   m_hilo_multi_dialog.AddListHiLoMaHandle(m_list_hilo_ma);
  }
//+------------------------------------------------------------------+
//| Open a BUY operation
//+------------------------------------------------------------------+
void CHiLoController::TradeBuyOpen(int index,CTrades *trades)
  {
   if(!trades.IsTradeEnable())
      return;

   if(!trades.IsTimeToOpenOperation())
      return;

   trades.UpdateVolumeFromNextVolume();
   trades.UpdateNextVolumeUsingMartingale();

   trades.ResetNextVolumeToZeroOnMaxMartingale();
   trades.ResetNextVolumeToInitialVolumeOnMaxTakeProfit();

   trades.DisableOnMaxMartingaleOperations();
   trades.DisableOnMaxTakeProfitOperations();

   m_hilo_multi_dialog.UpdateAllDialog(index,trades);

   string methodName=trades.Name()+"::TradeBuyOpen()";
   if(!trades.BuyOpen(methodName))
     {
      Print("There's was an error while buying");
     }
  }
//+------------------------------------------------------------------+
//| Open a SELL operation
//+------------------------------------------------------------------+
void CHiLoController::TradeSellOpen(int index,CTrades *trades)
  {
   if(!trades.IsTradeEnable())
      return;

   if(!trades.IsTimeToOpenOperation())
      return;

   trades.UpdateVolumeFromNextVolume();
   trades.UpdateNextVolumeUsingMartingale();

   trades.ResetNextVolumeToZeroOnMaxMartingale();
   trades.ResetNextVolumeToInitialVolumeOnMaxTakeProfit();

   trades.DisableOnMaxMartingaleOperations();
   trades.DisableOnMaxTakeProfitOperations();

   m_hilo_multi_dialog.UpdateAllDialog(index,trades);

   string methodName=trades.Name()+"::TradeSellOpen()";
   if(!trades.SellOpen(methodName))
     {
      Print("There's was an error while selling");
     }
  }
//+------------------------------------------------------------------+
//| Close a BUY operation|
//+------------------------------------------------------------------+
void CHiLoController::TradeBuyClose(int index,CTrades *trades)
  {
   string methodName=trades.Name()+"::TradeBuyClose()";
   if(trades.BuyClose(methodName))
     {
      methodName=trades.Name()+"::TradeBuyClose::DTP()";
      trades.DeleteTakeProfitOrder(methodName);

      methodName=trades.Name()+"::TradeBuyClose::DSL()";
      trades.DeleteStopLossOrder(methodName);

      trades.ResetVolumeToZeroIfNextVolumeIsInitialVolume();
      m_hilo_multi_dialog.UpdateAllDialog(index,trades);
     }
  }
//+------------------------------------------------------------------+
//| Close a SELL operation
//+------------------------------------------------------------------+
void CHiLoController::TradeSellClose(int index,CTrades *trades)
  {
   string methodName=trades.Name()+"::TradeSellClose()";
   if(trades.SellClose(methodName))
     {
      methodName=trades.Name()+"::TradeSellClose::DTP()";
      trades.DeleteTakeProfitOrder(methodName);

      methodName=trades.Name()+"::TradeSellClose::DSL()";
      trades.DeleteStopLossOrder(methodName);

      trades.ResetVolumeToZeroIfNextVolumeIsInitialVolume();
      m_hilo_multi_dialog.UpdateAllDialog(index,trades);
     }
  }
//+------------------------------------------------------------------+
//| Load current position ticket is there'is a position ticket
//+------------------------------------------------------------------+
void CHiLoController::VerifyIfLoadPositionTicket(CTrades *trades)
  {
   if(trades.IsOnTradeOperation() && !trades.IsPositionTicketLoaded())
     {
      if(trades.IsOnBuyTrade())
        {
         string methodName=trades.Name()+"::TradeBuyOpen()";
         trades.TryToLoadPositionOpenTicket(methodName);
        }

      if(trades.IsOnSellTrade())
        {
         string methodName=trades.Name()+"::TradeSellOpen()";
         trades.TryToLoadPositionOpenTicket(methodName);
        }
     }
  }
//+------------------------------------------------------------------+
//| Load current take profit ticket is there'is a position ticket and take profit ticket is not loaded
//+------------------------------------------------------------------+
void CHiLoController::VerifyIfLoadTakeProfitTicket(CTrades *trades)
  {
   if(trades.IsOnTradeOperation() && trades.IsPositionTicketLoaded() && !trades.IsTakeProfitTicketLoaded())
     {
      if(trades.IsOnBuyTrade())
        {
         string  methodName=trades.Name()+"::TradeBuyOpen::TP()";
         trades.TryToLoadTakeProfitTicket(methodName);
        }

      if(trades.IsOnSellTrade())
        {
         string methodName=trades.Name()+"::TradeSellOpen::TP()";
         trades.TryToLoadTakeProfitTicket(methodName);
        }
     }
  }
//+------------------------------------------------------------------+
//| Load current stop loss ticket is there'is a position ticket and stop loss ticket is not loaded
//+------------------------------------------------------------------+
void CHiLoController::VerifyIfLoadStopLossTicket(CTrades *trades)
  {
   if(trades.IsOnTradeOperation() && trades.IsPositionTicketLoaded() && !trades.IsStopLossTicketLoaded())
     {
      if(trades.IsOnBuyTrade())
        {
         string  methodName=trades.Name()+"::TradeBuyOpen::SL()";
         trades.TryToLoadStopLossTicket(methodName);
        }

      if(trades.IsOnSellTrade())
        {
         string methodName=trades.Name()+"::TradeSellOpen::SL()";
         trades.TryToLoadStopLossTicket(methodName);
        }
     }
  }
//+------------------------------------------------------------------+
//| Verify if place Take Profit
//+------------------------------------------------------------------+
void CHiLoController::VerifyIfPlaceTakeProfit(CTrades *trades)
  {
   if(trades.IsOnTradeOperation() && trades.IsPositionTicketLoaded() && !trades.IsTakeProfitPlaced())
     {
      if(trades.IsOnBuyTrade())
        {
         string  methodName=trades.Name()+"::TradeBuyOpen::TP()";
         trades.PlaceTakeProfitOrder(methodName);
        }

      if(trades.IsOnSellTrade())
        {
         string methodName=trades.Name()+"::TradeSellOpen::TP()";
         trades.PlaceTakeProfitOrder(methodName);
        }
     }
  }
//+------------------------------------------------------------------+
//| Verify if place Take Profit
//+------------------------------------------------------------------+
void CHiLoController::VerifyIfPlaceStopLoss(CTrades *trades)
  {
   if(trades.IsOnTradeOperation() && trades.IsPositionTicketLoaded() && !trades.IsStopLossPlaced())
     {
      if(trades.IsOnBuyTrade())
        {
         string methodName=trades.Name()+"::TradeBuyOpen::SL()";
         trades.PlaceStopLossOrder(methodName);
        }

      if(trades.IsOnSellTrade())
        {
         string methodName=trades.Name()+"::TradeSellOpen::SL()";
         trades.PlaceStopLossOrder(methodName);
        }
     }
  }
//+------------------------------------------------------------------+
//| Destroy the tick of Take Profit or Stop Loss if one was executed
//+------------------------------------------------------------------+
void CHiLoController::DestroyTpSlIfTicketAddedToHistory(ulong ticketOrder)
  {
// verify operation for each trade
   for(int i=0;i<m_list_hilo_ma.Total();i++)
     {
      CHiLoMaHandle *hma=m_list_hilo_ma.GetNodeAtIndex(i);
      CTrades *trades=hma.GetTrades();

      bool existTakeProfitTicket=trades.VerifyIfExistTakeProfitTicket(ticketOrder);
      bool existStopLossTicket=trades.VerifyIfExistStopLossTicket(ticketOrder);

      // take profit order was executed, remove stop loss
      if(existTakeProfitTicket)
        {
         string methodName=trades.Name()+"::DestroySlIfExistTp";
         trades.DeleteStopLossOrder(methodName);

         trades.UpdateCountTakeProfitOperations();
         trades.DisableOnMaxTakeProfitOperations();
        }

      // stop loss was executed, remove take profit order
      if(existStopLossTicket)
        {
         string methodName=trades.Name()+"::DestroyTpIfExistSl";
         trades.DeleteTakeProfitOrder(methodName);
        }

      if(existTakeProfitTicket || existStopLossTicket)
        {
         trades.ResetVolumeToZero();
         m_hilo_multi_dialog.UpdateAllDialog(i,trades);
        }
     }
  }
//+------------------------------------------------------------------+
