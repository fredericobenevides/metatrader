//+------------------------------------------------------------------+
//|                                                       Dialog.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Frederico Benevides"
#property link      "fredbene@gmail.com"

// libs for dialog
#include <Controls\Dialog.mqh>
#include <Controls\CheckBox.mqh>   
#include <Controls\Button.mqh>
#include <Controls\Label.mqh>
#include <Controls\Edit.mqh>
#include <Controls\SpinEdit.mqh>

// libs dependencies
#include <Arrays\List.mqh>

// my libs
#include <MyLibs\Trades\TradesController.mqh>
#include <MyLibs\HiLoMulti\Models\HiLoMaHandle.mqh>

//--- indents and gaps
#define INDENT_LEFT                         (15)      // indent from left (with allowance for border width)
#define INDENT_TOP                          (15)      // indent from top (with allowance for border width)
#define INDENT_RIGHT                        (15)      // indent from right (with allowance for border width)
#define INDENT_BOTTOM                       (15)      // indent from bottom (with allowance for border width)
#define CONTROLS_GAP_X                      (5)       // gap by X coordinate
#define CONTROLS_GAP_Y                      (5)       // gap by Y coordinate
//--- width sizes
#define WIDTH_DEFAULT                       (80)      // size by X coordinate
#define WIDTH_SHORT                         (35)      // size by X coordinate
#define WIDTH_SHORT_VERY                    (35)      // size by X coordinate
#define WIDTH_BIG                           (160)     // size by X coordinate
#define WIDTH_ADJUST                        (10)      // size by X coordinate
//-- height sizes
#define HEIGHT_DEFAULT                      (20)      // size by X coordinate
//+------------------------------------------------------------------+
//| Class CHiLoMultiDialog                                           
//| Usage: main dialog of the Controls application
//+------------------------------------------------------------------+
class CHiLoMultiDialog : public CAppDialog
  {
   CList            *m_list_hilo_ma;

   CButton           m_button_enable_all;
   CButton           m_button_disable_all;

   // hilo items
   CList             m_list_trade_l_name;          // CLabel
   CList             m_list_trade_c_enable;        // CCheckBox
   CList             m_list_trade_l_bs_status;     // CLabel
   CList             m_list_trade_e_bs_status;     // CEdit
   CList             m_list_trade_l_volume;        // CLabel
   CList             m_list_trade_e_volume;        // CEdit
   CList             m_list_trade_l_next_volume;   // CLabel
   CList             m_list_trade_e_next_volume;   // CEdit
   CList             m_list_trade_l_take_profit;   // CLabel
   CList             m_list_trade_e_take_profit;   // CEdit
   CList             m_list_trade_l_stop_loss;     // CLabel
   CList             m_list_trade_e_stop_loss;     // CEdit

   CLabel            m_label_trade1_info;
   CCheckBox         m_checkbox_trade1_enabled;

public:
                     CHiLoMultiDialog(void);
                    ~CHiLoMultiDialog(void);

   void              AddListHiLoMaHandle(CList *listHiLoMa) { m_list_hilo_ma=listHiLoMa; }

   //--- create
   bool              Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2);
   //--- chart event handler
   bool              OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   bool              ChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam);

   void              UpdateAllDialog(int index,CTradesController *tradesController);
   void              UpdateEnableDisableTrades(int index,CTradesController *tradesController);

protected:
   //--- create dependent controls
   bool              CreateEnableDisableButtons(void);

   bool              CreateTradesConfig();

   void              OnClickEnableAllTrades();
   void              OnClickDisableAllTrades();
  };
//+------------------------------------------------------------------+
//| Event Handling                                                   |
//+------------------------------------------------------------------+
EVENT_MAP_BEGIN(CHiLoMultiDialog)

ON_EVENT(ON_CLICK,m_button_enable_all,OnClickEnableAllTrades)
ON_EVENT(ON_CLICK,m_button_disable_all,OnClickDisableAllTrades)

EVENT_MAP_END(CAppDialog)
//+------------------------------------------------------------------+
//| Constructor
//+------------------------------------------------------------------+
CHiLoMultiDialog::CHiLoMultiDialog(void)
  {
  }
//+------------------------------------------------------------------+
//| Destructor
//+------------------------------------------------------------------+
CHiLoMultiDialog::~CHiLoMultiDialog(void)
  {
  }
//+------------------------------------------------------------------+
//| Create the interface
//+------------------------------------------------------------------+
bool CHiLoMultiDialog::Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2)
  {
   if(!CAppDialog::Create(chart,name,subwin,x1,y1,x2,y2))
      return false;

   if(!CreateEnableDisableButtons())
      return false;

   if(!CreateTradesConfig())
      return false;

   return true;
  }
//+------------------------------------------------------------------+
//| Update the current controls on a ChartEvent
//+------------------------------------------------------------------+
bool CHiLoMultiDialog::ChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
//--- Run the parent ChartEvent
   CAppDialog::ChartEvent(id,lparam,dparam,sparam);

//if(id==CHARTEVENT_CLICK)
//  {
//   if(sparam=="m_button_enable_all")
//     {
//      OnClickEnableAllTrades();
//      ChartRedraw();
//     }
//   if(sparam=="m_button_disable_all")
//     {
//      OnClickDisableAllTrades();
//      ChartRedraw();
//     }
//  }

   return true;
  }
//+------------------------------------------------------------------+
//| Update dialog based on CTrades
//+------------------------------------------------------------------+
void CHiLoMultiDialog::UpdateAllDialog(int index,CTradesController *tradesController)
  {
   UpdateEnableDisableTrades(index,tradesController);

   CEdit *m_edit_e_volume=m_list_trade_e_volume.GetNodeAtIndex(index);
   m_edit_e_volume.Text(DoubleToString(tradesController.PositionOrder().Volume(),0));
   m_edit_e_volume.TextAlign(ALIGN_CENTER);

   CEdit *m_edit_e_next_volume=m_list_trade_e_next_volume.GetNodeAtIndex(index);
   m_edit_e_next_volume.Text(DoubleToString(tradesController.PositionOrder().NextVolume(),0));
   m_edit_e_next_volume.TextAlign(ALIGN_CENTER);

   CEdit *m_edit_e_take_profit=m_list_trade_e_take_profit.GetNodeAtIndex(index);
   m_edit_e_take_profit.Text(DoubleToString(tradesController.TakeProfitOrder().Points(),0));
   m_edit_e_take_profit.TextAlign(ALIGN_CENTER);

   CEdit *m_edit_e_stop_loss=m_list_trade_e_stop_loss.GetNodeAtIndex(index);
   m_edit_e_stop_loss.Text(DoubleToString(tradesController.StopLossOrder().Points(),0));
   m_edit_e_stop_loss.TextAlign(ALIGN_CENTER);

   CEdit *m_edit_e_bs_status=m_list_trade_e_bs_status.GetNodeAtIndex(index);
   m_edit_e_bs_status.Text(tradesController.PositionOrder().BuySellOperationStatus());
   m_edit_e_bs_status.TextAlign(ALIGN_CENTER);
  }
//+------------------------------------------------------------------+
//| Update Enable and Disable Trades
//+------------------------------------------------------------------+
void CHiLoMultiDialog::UpdateEnableDisableTrades(int index,CTradesController *tradesController)
  {
   CCheckBox *m_trade_c_enable=m_list_trade_c_enable.GetNodeAtIndex(index);
   if(tradesController.PositionOrder().IsTradeEnable())
      m_trade_c_enable.Checked(true);
   else
      m_trade_c_enable.Checked(false);
  }
//+------------------------------------------------------------------+
//| Create the Enable and Disable Buttons
//+------------------------------------------------------------------+
bool CHiLoMultiDialog::CreateEnableDisableButtons(void)
  {
//--- button enable all
   int x1=INDENT_LEFT;
   int y1=INDENT_TOP;
   int x2=x1+WIDTH_DEFAULT;
   int y2=y1+HEIGHT_DEFAULT;

   if(!m_button_enable_all.Create(m_chart_id,"m_button_enable_all",m_subwin,x1,y1,x2,y2))
      return false;
   if(!m_button_enable_all.Text("Enable All"))
      return false;
   if(!Add(m_button_enable_all))
      return false;

//--- button disable all
   x1=INDENT_LEFT+2*(9*CONTROLS_GAP_X);
   y1=INDENT_TOP;
   x2=x1+1*WIDTH_DEFAULT;
   y2=y1+HEIGHT_DEFAULT;

//--- create
   if(!m_button_disable_all.Create(m_chart_id,"m_button_disable_all",m_subwin,x1,y1,x2,y2))
      return false;
   if(!m_button_disable_all.Text("Disable All"))
      return false;
   if(!Add(m_button_disable_all))
      return false;

   return true;
  }
//+------------------------------------------------------------------+
//| Create Trades Config for all Trades
//+------------------------------------------------------------------+
bool CHiLoMultiDialog::CreateTradesConfig()
  {
   double yGap=2.6;

   int total=m_list_hilo_ma.Total();
   for(int i=0;i<m_list_hilo_ma.Total();i++)
     {
      int indexNameTrade=i+1;
      int yIndex=2+i;
      yGap+=0.8;

      int y1=int(INDENT_TOP+yIndex*(yGap*CONTROLS_GAP_Y));

      CHiLoMaHandle *hma=m_list_hilo_ma.GetNodeAtIndex(i);
      CTradesController *tradesController=hma.GetTradesController();

      CLabel *m_trade_l_name=new CLabel();
      CCheckBox *m_trade_c_enable=new CCheckBox();

      CLabel *m_trade_l_bs_status=new CLabel();
      CEdit *m_trade_e_bs_status=new CEdit();

      CLabel *m_trade_l_volume=new CLabel();
      CEdit *m_trade_e_volume=new CEdit();
      CLabel *m_trade_l_next_volume=new CLabel();
      CEdit *m_trade_e_next_volume=new CEdit();

      CLabel *m_trade_l_take_profit=new CLabel();
      CEdit *m_trade_e_take_profit=new CEdit();
      CLabel *m_trade_l_stop_loss=new CLabel();
      CEdit *m_trade_e_stop_loss=new CEdit();

      //--- label trade's name
      int x1=INDENT_LEFT;
      int x2=x1+WIDTH_DEFAULT;
      int y2=y1+HEIGHT_DEFAULT;

      if(!m_trade_l_name.Create(m_chart_id,"m_trade_l_name"+IntegerToString(indexNameTrade),m_subwin,x1,y1,x2,y2))
         return false;
      if(!m_trade_l_name.Text(tradesController.PositionOrder().Name()))
         return false;
      if(!Add(m_trade_l_name))
         return false;

      //--- checkbox enabled
      x1=INDENT_LEFT+2*(2*CONTROLS_GAP_X);
      x2=x1+WIDTH_DEFAULT;
      y2=y1+HEIGHT_DEFAULT;

      if(!m_trade_c_enable.Create(m_chart_id,"m_trade_c_enable"+IntegerToString(indexNameTrade),m_subwin,x1,y1,x2,y2))
         return false;
      if(!m_trade_c_enable.Text("Enable"))
         return false;
      if(!Add(m_trade_c_enable))
         return false;

      //--- Label Volume
      x1=int(INDENT_LEFT+3*(6*CONTROLS_GAP_X));
      x2=x1+WIDTH_DEFAULT;
      y2=y1+HEIGHT_DEFAULT;

      if(!m_trade_l_volume.Create(m_chart_id,"m_trade_l_volume"+IntegerToString(indexNameTrade),m_subwin,x1,y1,x2,y2))
         return false;
      if(!m_trade_l_volume.Text("Vol."))
         return false;
      if(!Add(m_trade_l_volume))
         return false;

      //--- Edit Volume
      x1=int(INDENT_LEFT+3*(7.8*CONTROLS_GAP_X));
      x2=x1+WIDTH_SHORT;
      y2=y1+HEIGHT_DEFAULT;

      if(!m_trade_e_volume.Create(m_chart_id,"m_trade_e_volume"+IntegerToString(indexNameTrade),m_subwin,x1,y1,x2,y2))
         return false;
      if(!Add(m_trade_e_volume))
         return false;

      //--- Label Next Volume
      x1=int(INDENT_LEFT+4*(8.2*CONTROLS_GAP_X));
      x2=x1+WIDTH_DEFAULT;
      y2=y1+HEIGHT_DEFAULT;

      if(!m_trade_l_next_volume.Create(m_chart_id,"m_trade_l_next_volume"+IntegerToString(indexNameTrade),m_subwin,x1,y1,x2,y2))
         return false;
      if(!m_trade_l_next_volume.Text("N Vol."))
         return false;
      if(!Add(m_trade_l_next_volume))
         return false;

      //--- Edit Next Volume
      x1=int(INDENT_LEFT+4*(10.2*CONTROLS_GAP_X));
      x2=x1+WIDTH_SHORT;
      y2=y1+HEIGHT_DEFAULT;

      if(!m_trade_e_next_volume.Create(m_chart_id,"m_trade_e_next_volume"+IntegerToString(indexNameTrade),m_subwin,x1,y1,x2,y2))
         return false;
      if(!Add(m_trade_e_next_volume))
         return false;

      //--- Label Take Profit
      x1=INDENT_LEFT+5*(10*CONTROLS_GAP_X);
      x2=x1+WIDTH_DEFAULT;
      y2=y1+HEIGHT_DEFAULT;

      if(!m_trade_l_take_profit.Create(m_chart_id,"m_trade_l_take_profit"+IntegerToString(indexNameTrade),m_subwin,x1,y1,x2,y2))
         return false;
      if(!m_trade_l_take_profit.Text("TP"))
         return false;
      if(!Add(m_trade_l_take_profit))
         return false;

      //--- Edit Take Profit
      x1=int(INDENT_LEFT+5*(10.8*CONTROLS_GAP_X));
      x2=x1+WIDTH_SHORT;
      y2=y1+HEIGHT_DEFAULT;

      if(!m_trade_e_take_profit.Create(m_chart_id,"m_trade_e_take_profit"+IntegerToString(indexNameTrade),m_subwin,x1,y1,x2,y2))
         return false;
      if(!Add(m_trade_e_take_profit))
         return false;

      //--- Label Stop Loss
      x1=int(INDENT_LEFT+6*(10.5*CONTROLS_GAP_X));
      x2=x1+WIDTH_DEFAULT;
      y2=y1+HEIGHT_DEFAULT;

      if(!m_trade_l_stop_loss.Create(m_chart_id,"m_trade_l_stop_loss"+IntegerToString(indexNameTrade),m_subwin,x1,y1,x2,y2))
         return false;
      if(!m_trade_l_stop_loss.Text("SL"))
         return false;
      if(!Add(m_trade_l_stop_loss))
         return false;

      //--- Edit Stop Loss
      x1=int(INDENT_LEFT+6*(11.2*CONTROLS_GAP_X));
      x2=x1+WIDTH_SHORT;
      y2=y1+HEIGHT_DEFAULT;

      if(!m_trade_e_stop_loss.Create(m_chart_id,"m_trade_e_stop_loss"+IntegerToString(indexNameTrade),m_subwin,x1,y1,x2,y2))
         return false;
      if(!Add(m_trade_e_stop_loss))
         return false;

      //--- Label Buy Sell Status
      x1=int(INDENT_LEFT+7*(10.9*CONTROLS_GAP_X));
      x2=x1+WIDTH_DEFAULT;
      y2=y1+HEIGHT_DEFAULT;

      if(!m_trade_l_bs_status.Create(m_chart_id,"m_trade_l_bs_status"+IntegerToString(indexNameTrade),m_subwin,x1,y1,x2,y2))
         return false;
      if(!m_trade_l_bs_status.Text("B/S"))
         return false;
      if(!Add(m_trade_l_bs_status))
         return false;

      //--- Edit Buy Sell Status
      x1=int(INDENT_LEFT+7*(11.6*CONTROLS_GAP_X));
      x2=x1+WIDTH_SHORT;
      y2=y1+HEIGHT_DEFAULT;

      if(!m_trade_e_bs_status.Create(m_chart_id,"m_trade_e_bs_status"+IntegerToString(indexNameTrade),m_subwin,x1,y1,x2,y2))
         return false;
      if(!Add(m_trade_e_bs_status))
         return false;

      // add the items to panel
      m_list_trade_l_name.Add(m_trade_l_name);
      m_list_trade_c_enable.Add(m_trade_c_enable);

      m_list_trade_l_bs_status.Add(m_trade_l_bs_status);
      m_list_trade_e_bs_status.Add(m_trade_e_bs_status);

      m_list_trade_l_volume.Add(m_trade_l_volume);
      m_list_trade_e_volume.Add(m_trade_e_volume);
      m_list_trade_l_next_volume.Add(m_trade_l_next_volume);
      m_list_trade_e_next_volume.Add(m_trade_e_next_volume);

      m_list_trade_l_take_profit.Add(m_trade_l_take_profit);
      m_list_trade_e_take_profit.Add(m_trade_e_take_profit);
      m_list_trade_l_stop_loss.Add(m_trade_l_stop_loss);
      m_list_trade_e_stop_loss.Add(m_trade_e_stop_loss);

      UpdateAllDialog(i,tradesController);
     }

   return true;
  }
//+------------------------------------------------------------------+
//| Enable All trades
//+------------------------------------------------------------------+
void CHiLoMultiDialog::OnClickEnableAllTrades()
  {
   for(int i=0;i<m_list_hilo_ma.Total();i++)
     {
      CHiLoMaHandle *hma=m_list_hilo_ma.GetNodeAtIndex(i);
      CTradesController *tradesController=hma.GetTradesController();

      tradesController.PositionOrder().EnableTrade();
      UpdateEnableDisableTrades(i,tradesController);
     }
  }
//+------------------------------------------------------------------+
//| Disable All trades
//+------------------------------------------------------------------+
void CHiLoMultiDialog::OnClickDisableAllTrades()
  {
   for(int i=0;i<m_list_hilo_ma.Total();i++)
     {
      CHiLoMaHandle *hma=m_list_hilo_ma.GetNodeAtIndex(i);
      CTradesController *tradesController=hma.GetTradesController();

      tradesController.PositionOrder().DisableTrade();
      UpdateEnableDisableTrades(i,tradesController);
     }
  }
//+------------------------------------------------------------------+
