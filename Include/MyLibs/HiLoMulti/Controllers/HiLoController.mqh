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

   void              TradeBuyOpen(int index,CTradesController *tradesController);
   void              TradeSellOpen(int index,CTradesController *tradesController);
   void              TradeBuyClose(int index,CTradesController *tradesController);
   void              TradeSellClose(int index,CTradesController *tradesController);

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
      CTradesController *tradesController=hma.GetTradesController();

      // Delete and update the interface since can be a disable trade.
      if(tradesController.VerifyIfDeleteTakeProfitOrder())
         m_hilo_multi_dialog.UpdateAllDialog(i,tradesController);
      if(tradesController.VerifyIfDeleteStopLossOrder())
         m_hilo_multi_dialog.UpdateAllDialog(i,tradesController);

      tradesController.VerifyIfPlaceTakeProfitOrder();
      tradesController.VerifyIfPlaceStopLossOrder();

      tradesController.VerifyIfLoadTakeProfitTicket();
      tradesController.VerifyIfLoadStopLossTicket();

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
               TradeBuyOpen(i,tradesController);
               break;
            case SELL_OPEN_OPERATION:
               TradeSellOpen(i,tradesController);
               break;
            case BUY_CLOSE_OPERATION:
               TradeBuyClose(i,tradesController);
               break;
            case SELL_CLOSE_OPERATION:
               TradeSellClose(i,tradesController);
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
   hiloMa.GetTradesController().AddTradesService(m_trades_service);
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
      CTradesController *tradesController=hma.GetTradesController();
      tradesController.ResetToDefault();

      m_hilo_multi_dialog.UpdateAllDialog(i,tradesController);
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

   if(!m_hilo_multi_dialog.Create(0,"",0,20,y1,505,y2))
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
void CHiLoController::TradeBuyOpen(int index,CTradesController *tradesController)
  {
   if(tradesController.PositionBuyOpen())
      m_hilo_multi_dialog.UpdateAllDialog(index,tradesController);
  }
//+------------------------------------------------------------------+
//| Open a SELL operation
//+------------------------------------------------------------------+
void CHiLoController::TradeSellOpen(int index,CTradesController *tradesController)
  {
   if(tradesController.PositionSellOpen())
      m_hilo_multi_dialog.UpdateAllDialog(index,tradesController);
  }
//+------------------------------------------------------------------+
//| Close a BUY operation|
//+------------------------------------------------------------------+
void CHiLoController::TradeBuyClose(int index,CTradesController *tradesController)
  {
   if(tradesController.PositionBuyClose())
      m_hilo_multi_dialog.UpdateAllDialog(index,tradesController);
  }
//+------------------------------------------------------------------+
//| Close a SELL operation
//+------------------------------------------------------------------+
void CHiLoController::TradeSellClose(int index,CTradesController *tradesController)
  {
   if(tradesController.PositionSellClose())
      m_hilo_multi_dialog.UpdateAllDialog(index,tradesController);
  }
//+------------------------------------------------------------------+
//| Destroy the tick of Take Profit or Stop Loss if one was executed
//+------------------------------------------------------------------+
void CHiLoController::DestroyTpSlIfTicketAddedToHistory(ulong ticketOrder)
  {
   Print("The ticket "+IntegerToString(ticketOrder)+" had TP/SL");

// verify operation for each trade
   for(int i=0;i<m_list_hilo_ma.Total();i++)
     {
      CHiLoMaHandle *hma=m_list_hilo_ma.GetNodeAtIndex(i);
      CTradesController *tradesController=hma.GetTradesController();

      if(tradesController.VerifyIfDestroyTpSlWhenExecutedByMetatrader(ticketOrder))
         m_hilo_multi_dialog.UpdateAllDialog(i,tradesController);
     }
  }
//+------------------------------------------------------------------+
