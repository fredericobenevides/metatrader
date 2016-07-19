//+------------------------------------------------------------------+
//|                                               HiLoController.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Frederico Benevides"
#property link      "fredbene@gmail.com"

#include <Arrays\List.mqh>

#include <MyLibs\HiLoMulti\Models\HiLoMa.mqh>
#include <MyLibs\HiLoMulti\Models\EnumOperations.mqh>
#include <MyLibs\HiLoMulti\Views\HiLoMultiDialog.mqh>
#include <MyLibs\Trade\TradeController.mqh>
//+------------------------------------------------------------------+
//| Controller for HiLo
//+------------------------------------------------------------------+
class CHiLoController
  {
   CList            *m_list_hilo_ma;
   CTradeController *m_trade_controller;

protected:
   CHiLoMultiDialog  m_hilo_multi_dialog;

public:
                     CHiLoController();
                    ~CHiLoController();

   void              Destroy(int reason);
   void              OnTick();

   void              AddModel(CHiLoMa *hiloMa);

   void              InitTradeSound(string sellSoundName,string buySoundName);
   bool              InitAll();

protected:
   bool              InitModels();
   bool              InitView();

   void              AddModelsToView();
  };
//+------------------------------------------------------------------+
//| Constructor
//+------------------------------------------------------------------+
CHiLoController::CHiLoController(void)
  {
   m_list_hilo_ma=new CList;
   m_trade_controller=new CTradeController();
  }
//+------------------------------------------------------------------+
//| Destructor
//+------------------------------------------------------------------+
CHiLoController::~CHiLoController(void)
  {
// destroy the models
   for(int i=0;i<m_list_hilo_ma.Total();i++)
     {
      CHiLoMa *hma=m_list_hilo_ma.GetNodeAtIndex(i);
      delete hma;
     }
     
   delete m_list_hilo_ma;   
   delete m_trade_controller;
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
      CHiLoMa *hma=m_list_hilo_ma.GetNodeAtIndex(i);
      hma.Destroy();
     }
  }
//+------------------------------------------------------------------+
//| Verify is there any operation for each candle. 
//+------------------------------------------------------------------+
void CHiLoController::OnTick()
  {
   for(int i=0;i<m_list_hilo_ma.Total();i++)
     {
      CHiLoMa *hma=m_list_hilo_ma.GetNodeAtIndex(i);
      ENUM_OPERATIONS operation=(ENUM_OPERATIONS)hma.ExecuteOperation();
      Print("aqui"+EnumToString(operation));
     }
  }
//+------------------------------------------------------------------+
//| Add the HiLoMa to the controller
//+------------------------------------------------------------------+
void CHiLoController::AddModel(CHiLoMa *hiloMa)
  {
   m_list_hilo_ma.Add(hiloMa);
  }
//+------------------------------------------------------------------+
//| Init the Trade's sound
//+------------------------------------------------------------------+
void CHiLoController::InitTradeSound(string sellSoundName,string buySoundName)
  {
   m_trade_controller.EnableSoundOnOperation(sellSoundName,buySoundName);
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
      CHiLoMa *hma=m_list_hilo_ma.GetNodeAtIndex(i);

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

   if(!m_hilo_multi_dialog.Create(0,"",0,20,y1,335,y2))
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
   CHiLoMa *current=m_list_hilo_ma.GetCurrentNode();
   while(current!=NULL)
     {
      m_hilo_multi_dialog.AddModel(current);
      current=m_list_hilo_ma.GetNextNode();
     }
  }
//+------------------------------------------------------------------+
