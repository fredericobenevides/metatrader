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
//#include <MyLibs\Trade\TradesService.mqh>
//+------------------------------------------------------------------+
//| Controller for HiLo
//+------------------------------------------------------------------+
class CHiLoController
  {
   CList            *m_list_hilo_ma;
   CTradesService   *m_trades_service;

protected:
   CHiLoMultiDialog  m_hilo_multi_dialog;

public:
                     CHiLoController();
                    ~CHiLoController();

   void              Destroy(int reason);
   void              OnTick();
   void              OnTradeTransaction(const MqlTradeTransaction &trans,const MqlTradeRequest &request,const MqlTradeResult &result);

   void              AddModel(CHiLoMaHandle *hiloMa);

   void              InitTradeSound(string sellSoundName,string buySoundName);
   bool              InitAll();

protected:
   bool              InitModels();
   bool              InitView();

   void              AddModelsToView();

   void              TradeBuyOpen(int index,CTrades *trades);
   void              TradeSellOpen(int index,CTrades *trades);
   void              TradeBuyClose(CTrades *trades);
   void              TradeSellClose(CTrades *trades);

   void              DestroyTpSlIfTicketAddedToHistory(ulong ticket);
  };
//+------------------------------------------------------------------+
//| Constructor
//+------------------------------------------------------------------+
CHiLoController::CHiLoController(void)
  {
   m_list_hilo_ma=new CList;
   m_trades_service=new CTradesService();
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

      CArrayInt *listOperations=hma.VerifyTypeOperation();

      // there isn't current operation for current trade
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
               TradeBuyClose(trades);
               break;
            case SELL_CLOSE_OPERATION:
               TradeSellClose(trades);
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
void  CHiLoController::OnTradeTransaction(const MqlTradeTransaction &trans,
                                          const MqlTradeRequest &request,
                                          const MqlTradeResult &result)
  {
   if(trans.type==TRADE_TRANSACTION_HISTORY_ADD)
     {
      if(trans.order_type== ORDER_TYPE_BUY_LIMIT
         || trans.order_type== ORDER_TYPE_BUY_STOP
         || trans.order_type== ORDER_TYPE_SELL_LIMIT
         || trans.order_type== ORDER_TYPE_SELL_STOP)
        {
         DestroyTpSlIfTicketAddedToHistory(trans.order);
        }
     }
  }
//+------------------------------------------------------------------+
//| Add the HiLoMa to the controller
//+------------------------------------------------------------------+
void CHiLoController::AddModel(CHiLoMaHandle *hiloMa)
  {
   m_list_hilo_ma.Add(hiloMa);
  }
//+------------------------------------------------------------------+
//| Init the Trade's sound
//+------------------------------------------------------------------+
void CHiLoController::InitTradeSound(string sellSoundName,string buySoundName)
  {
   m_trades_service.EnableSoundOnOperation(sellSoundName,buySoundName);
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

// Add models to view
//CHiLoMa *current=m_list_hilo_ma.GetCurrentNode();
//while(current!=NULL)
//  {
//   HiLoMultiDialog.AddModel(current);
//  }

   int y1=int(ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS)-250);
   int y2=int(ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS)-20);

   if(!m_hilo_multi_dialog.Create(0,"",0,20,y1,450,y2))
      return(INIT_FAILED);

//      //if(!HiLoMALoader.Init())
//      //   return(INIT_FAILED);

   m_hilo_multi_dialog.Run();
//
//      //if(InpAllSetTradeSound)
//      //   MyTrade.EnableSoundOnOperation(InpAllSellTradeSound,InpAllBuyTradeSound);
//     }

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Add models to view
//+------------------------------------------------------------------+
void CHiLoController::AddModelsToView()
  {
   CHiLoMaHandle *current=m_list_hilo_ma.GetCurrentNode();
   while(current!=NULL)
     {
      m_hilo_multi_dialog.AddModel(current);
      current=m_list_hilo_ma.GetNextNode();
     }
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
   trades.DisableOnMaxMartingaleOperations();
   m_hilo_multi_dialog.UpdateDialog(index,trades);

   string methodName=trades.Name()+"::TradeBuyOpen()";
   if(trades.BuyOpen(methodName))
     {
      Print("Inserir take profit");
      trades.PlaceTakeProfitOrder(methodName);
      trades.PlaceStopLossOrder(methodName);
     }

//   if(!IsTimeToOpenOperation())
//      return;
//
//   double volume=HiLoDialog.CurrentVolume();
//   if(MyTrade.TradeBuyOpen("TradeBuyOpen",volume))
//     {
//      ModifyTpSl();
//      BreakEvenShow();
//     }
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
   trades.DisableOnMaxMartingaleOperations();
   m_hilo_multi_dialog.UpdateDialog(index,trades);

   string methodName=trades.Name()+"::TradeSellOpen()";
   if(trades.SellOpen(methodName))
     {
      Print("Inserir take profit");
      trades.PlaceTakeProfitOrder(methodName);
      trades.PlaceStopLossOrder(methodName);
     }

//   if(!IsTimeToOpenOperation())
//      return;
//
//   double volume=HiLoDialog.CurrentVolume();
//   if(MyTrade.TradeSellOpen("TradeSellOpen",volume))
//     {
//      ModifyTpSl();
//      BreakEvenShow();
//     }
  }
//+------------------------------------------------------------------+
//| Close a BUY operation|
//+------------------------------------------------------------------+
void CHiLoController::TradeBuyClose(CTrades *trades)
  {
   string methodName=trades.Name()+"::TradeBuyClose()";
   if(trades.BuyClose(methodName))
     {
      Print("calcular volume factor");
      trades.DeleteTakeProfitOrder(methodName);
      trades.DeleteStopLossOrder(methodName);
     }

//if(MyTrade.TradeBuyClose("TradeBuyClose"))
//  {
//   HiLoDialog.CalculateVolumeFactor();
//   BreakEvenHide();
//  }
  }
//+------------------------------------------------------------------+
//| Close a SELL operation
//+------------------------------------------------------------------+
void CHiLoController::TradeSellClose(CTrades *trades)
  {
   string methodName=trades.Name()+"::TradeSellClose()";
   if(trades.SellClose(methodName))
     {
      Print("calcular volume factor");
      trades.DeleteTakeProfitOrder(methodName);
      trades.DeleteStopLossOrder(methodName);
     }

//if(MyTrade.TradeSellClose("TradeSellClose"))
//  {
//   HiLoDialog.CalculateVolumeFactor();
//   BreakEvenHide();
//  }
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
         trades.DeleteStopLossOrder("DestroyTpSlIfTicketAddedToHistory");

      // stop loss was executed, remove take profit order
      if(existStopLossTicket)
         trades.DeleteTakeProfitOrder("DestroyTpSlIfTicketAddedToHistory");
     }
  }
//+------------------------------------------------------------------+
