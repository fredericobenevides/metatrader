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

#include <MyLibs\Trades\TradesUtils.mqh>
#include <MyLibs\Trades\TradesService.mqh>
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
   void              ReInitTradesToDefault();

protected:
   bool              InitModels();
   bool              InitView();

   void              AddModelsToView();

   void              TradeBuyOpen(int index,bool initializeTpSl,CPositionController *positionController,CTakeProfitController *takeProfitController,CStopLossController *stopLossController);
   void              TradeSellOpen(int index,bool initializeTpSl,CPositionController *positionController,CTakeProfitController *takeProfitController,CStopLossController *stopLossController);
   void              TradeBuyClose(int index,CPositionController *positionController,CTakeProfitController *takeProfitController,CStopLossController *stopLossController);
   void              TradeSellClose(int index,CPositionController *positionController,CTakeProfitController *takeProfitController,CStopLossController *stopLossController);
   void              placeTakeProfitAndLoadTheTicket(CTakeProfitController *takeProfitController);
   void              placeStopLossAndLoadTheTicket(CStopLossController *stopLossController);
   void              deleteTakeProfit(CTakeProfitController *takeProfitController);
   void              deleteStopLoss(CStopLossController *stopLossController);

   void              RemoveTakeProfitDestroyedByMetatrader(ulong ticket);
   void              RemoveStopLossDestroyedByMetatrader(ulong ticket);
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
  }
//+------------------------------------------------------------------+
//| Verify is there any operation for each candle. 
//+------------------------------------------------------------------+
void CHiLoController::OnTick()
  {
   MqlTick lastTick;
   SymbolInfoTick(Symbol(),lastTick);
   double currentMarketPrice=lastTick.last;

// verify operation for each trade
   for(int i=0;i<m_list_hilo_ma.Total();i++)
     {
      CHiLoMaHandle *hma=m_list_hilo_ma.GetNodeAtIndex(i);

      CPositionController *positionController=hma.PositionController();
      CTakeProfitController *takeProfitController=hma.TakeProfitController();
      CStopLossController *stopLossController=hma.StopLossController();

      if(stopLossController.VerifyIfHasProfileActivated() && stopLossController.VerifyIfChangeStopLossBasedOnProfile(currentMarketPrice))
        {
         deleteStopLoss(stopLossController);
         placeStopLossAndLoadTheTicket(stopLossController);
        }

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
               TradeBuyOpen(i,true,positionController,takeProfitController,stopLossController);
               break;
            case SELL_OPEN_OPERATION:
               TradeSellOpen(i,true,positionController,takeProfitController,stopLossController);
               break;
            case BUY_CLOSE_OPERATION:
               TradeBuyClose(i,positionController,takeProfitController,stopLossController);
               break;
            case SELL_CLOSE_OPERATION:
               TradeSellClose(i,positionController,takeProfitController,stopLossController);
               break;
            default: // NO_OPERATION
               continue;
           }
        }

      // remove this list operation
      listOperations.Shutdown();
      delete listOperations;
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

      ENUM_ORDER_STATE orderState=trans.order_state;

      if(orderState==ORDER_STATE_CANCELED)
         return;

      ENUM_ORDER_TYPE orderType=trans.order_type;

      if(orderType==ORDER_TYPE_BUY_LIMIT || orderType==ORDER_TYPE_SELL_LIMIT)
         RemoveTakeProfitDestroyedByMetatrader(trans.order);

      if(orderType==ORDER_TYPE_BUY_STOP || orderType==ORDER_TYPE_SELL_STOP)
         RemoveStopLossDestroyedByMetatrader(trans.order);

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
   hiloMa.PositionController().AddTradesService(m_trades_service);
   hiloMa.TakeProfitController().AddTradesService(m_trades_service);
   hiloMa.StopLossController().AddTradesService(m_trades_service);


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
//| Reset all trades to default.
//+------------------------------------------------------------------+
void CHiLoController::ReInitTradesToDefault()
  {
   for(int i=0;i<m_list_hilo_ma.Total();i++)
     {
      CHiLoMaHandle *hma=m_list_hilo_ma.GetNodeAtIndex(i);

      hma.PositionController().ResetToDefault();
      hma.TakeProfitController().ResetToDefault();
      hma.StopLossController().ResetToDefault();

      m_hilo_multi_dialog.UpdateAllDialog(i,hma.PositionController(),hma.TakeProfitController(),hma.StopLossController());
     }
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

   if(!m_hilo_multi_dialog.Create(0,"",0,20,y1,580,y2))
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
void CHiLoController::TradeBuyOpen(int index,bool initializeTpSl,CPositionController *positionController,CTakeProfitController *takeProfitController,CStopLossController *stopLossController)
  {
   if(positionController.BuyOpen(initializeTpSl))
     {
      placeTakeProfitAndLoadTheTicket(takeProfitController);
      placeStopLossAndLoadTheTicket(stopLossController);

      m_hilo_multi_dialog.UpdateAllDialog(index,positionController,takeProfitController,stopLossController);
     }
  }
//+------------------------------------------------------------------+
//| Open a SELL operation
//+------------------------------------------------------------------+
void CHiLoController::TradeSellOpen(int index,bool initializeTpSl,CPositionController *positionController,CTakeProfitController *takeProfitController,CStopLossController *stopLossController)
  {
   if(positionController.SellOpen(initializeTpSl))
     {
      placeTakeProfitAndLoadTheTicket(takeProfitController);
      placeStopLossAndLoadTheTicket(stopLossController);

      m_hilo_multi_dialog.UpdateAllDialog(index,positionController,takeProfitController,stopLossController);
     }
  }
//+------------------------------------------------------------------+
//| Close a BUY operation|
//+------------------------------------------------------------------+
void CHiLoController::TradeBuyClose(int index,CPositionController *positionController,CTakeProfitController *takeProfitController,CStopLossController *stopLossController)
  {
   if(positionController.BuyClose())
     {
      deleteTakeProfit(takeProfitController);
      deleteStopLoss(stopLossController);

      m_hilo_multi_dialog.UpdateAllDialog(index,positionController,takeProfitController,stopLossController);
     }
  }
//+------------------------------------------------------------------+
//| Close a SELL operation
//+------------------------------------------------------------------+
void CHiLoController::TradeSellClose(int index,CPositionController *positionController,CTakeProfitController *takeProfitController,CStopLossController *stopLossController)
  {
   if(positionController.SellClose())
     {
      deleteTakeProfit(takeProfitController);
      deleteStopLoss(stopLossController);

      m_hilo_multi_dialog.UpdateAllDialog(index,positionController,takeProfitController,stopLossController);
     }
  }
//+------------------------------------------------------------------+
//| Place take profit and read the ticket
//+------------------------------------------------------------------+
void CHiLoController::placeTakeProfitAndLoadTheTicket(CTakeProfitController *takeProfitController)
  {
   bool takeProfitPlaced=false;
   while(!takeProfitPlaced)
     {
      takeProfitPlaced=takeProfitController.VerifyIfPlaceTakeProfitOrder();
      Sleep(100);
     }

   bool takeProfitTicketLoaded=false;
   while(!takeProfitTicketLoaded)
     {
      takeProfitTicketLoaded=takeProfitController.VerifyIfLoadTakeProfitTicket();
      Sleep(100);
     }
  }
//+------------------------------------------------------------------+
//| Place stop loss and read the ticket
//+------------------------------------------------------------------+
void CHiLoController::placeStopLossAndLoadTheTicket(CStopLossController *stopLossController)
  {
   bool stopPlaced=false;
   while(!stopPlaced)
     {
      stopPlaced=stopLossController.VerifyIfPlaceStopLossOrder();
      Sleep(100);
     }

   bool stopTicketLoaded=false;
   while(!stopTicketLoaded)
     {
      stopTicketLoaded=stopLossController.VerifyIfLoadStopLossTicket();
      Sleep(100);
     }
  }
//+------------------------------------------------------------------+
//| Delete the current take profit
//+------------------------------------------------------------------+
void CHiLoController::deleteTakeProfit(CTakeProfitController *takeProfitController)
  {
   bool hasOpenTakeProfit=!takeProfitController.VerifyIfHasOpenTakeProfit();
   while(!hasOpenTakeProfit)
     {
      takeProfitController.VerifyIfDeleteTakeProfitOrder();
      hasOpenTakeProfit=!takeProfitController.VerifyIfHasOpenTakeProfit();
      Sleep(100);
     }
  }
//+------------------------------------------------------------------+
//| Delete the current stop loss
//+------------------------------------------------------------------+
void CHiLoController::deleteStopLoss(CStopLossController *stopLossController)
  {
   bool hasOpenStopLoss=!stopLossController.VerifyIfHasOpenStop();
   int limit = 0;
   while(!hasOpenStopLoss && limit <= 10)
     {
      stopLossController.VerifyIfDeleteStopLossOrder();
      hasOpenStopLoss=!stopLossController.VerifyIfHasOpenStop();
      limit++;
      Sleep(100);
     }
  }
//+------------------------------------------------------------------+
//| Remove take profit(already removed from market) and stop loss (still on market) destroyed by metatrader
//+------------------------------------------------------------------+
void CHiLoController::RemoveTakeProfitDestroyedByMetatrader(ulong ticket)
  {
   for(int i=0;i<m_list_hilo_ma.Total();i++)
     {
      bool result=false;
      CHiLoMaHandle *hma=m_list_hilo_ma.GetNodeAtIndex(i);

      CTakeProfitController *takeProfitController=hma.TakeProfitController();
      CTakeProfitOrder *takeProfitOrder=takeProfitController.TakeProfitOrderByTicket(ticket);

      if(takeProfitOrder!=NULL)
        {
         takeProfitController.ExecutedDeleteOperationByMetatrader(takeProfitOrder);

         hma.PositionController().ExecutedClosedOperationByMetatrader();

         CStopLossController *stopLossController=hma.StopLossController();
         if(stopLossController.VerifyIfHasOrders())
           {
            stopLossController.ExecutedDeleteOperationByMetatrader(NULL);
            deleteStopLoss(stopLossController);
           }

         result=true;
        }

      if(result)
        {
         Print("The ticket "+IntegerToString(ticket)+" had Take Profit");
         m_hilo_multi_dialog.UpdateAllDialog(i,hma.PositionController(),hma.TakeProfitController(),hma.StopLossController());
         break;
        }
     }
  }
//+------------------------------------------------------------------+
//| Remove stop loss (already removed from market) and take profit (still on market) destroyed by metatrader
//+------------------------------------------------------------------+
void CHiLoController::RemoveStopLossDestroyedByMetatrader(ulong ticket)
  {
   for(int i=0;i<m_list_hilo_ma.Total();i++)
     {
      bool result=false;
      CHiLoMaHandle *hma=m_list_hilo_ma.GetNodeAtIndex(i);

      CStopLossController *stopLossController=hma.StopLossController();
      CStopLossOrder *stopLossOrder=stopLossController.StopLossOrderByTicket(ticket);

      if(stopLossOrder!=NULL)
        {
         stopLossController.ExecutedDeleteOperationByMetatrader(stopLossOrder);

         hma.PositionController().ExecutedClosedOperationByMetatrader();

         CTakeProfitController *takeProfitController=hma.TakeProfitController();
         if(takeProfitController.VerifyIfHasOrders())
           {
            takeProfitController.ExecutedDeleteOperationByMetatrader(NULL);
            deleteTakeProfit(takeProfitController);
            result=true;
           }

         result=true;
        }

      if(result)
        {
         Print("The ticket "+IntegerToString(ticket)+" had Stop Loss");
         m_hilo_multi_dialog.UpdateAllDialog(i,hma.PositionController(),hma.TakeProfitController(),hma.StopLossController());
         break;
        }
     }
  }
//+------------------------------------------------------------------+
