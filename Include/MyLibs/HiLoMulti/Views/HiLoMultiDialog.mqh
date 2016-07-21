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
#include <MyLibs\Trade\Trades.mqh>
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
#define WIDTH_SHORT                         (40)      // size by X coordinate
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
   CList             m_list_hilo_ma;

   CCheckBox         m_checkbox_buy;
   CCheckBox         m_checkbox_sell;
   CCheckBox         m_checkbox_close_on_hilo;
   CCheckBox         m_checkbox_close_on_tp;

   // hilo items
   CList             m_list_trade_l_name;          // CLabel
   CList             m_list_trade_c_enable;        // CCheckBox
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

   void              AddModel(CHiLoMaHandle *hiloMa);
   //--- create
   bool              Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2);
   //--- chart event handler
   bool              OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   bool              ChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam);

   void              InitToDefaults();
   void              UpdateDialog(int index,CTrades *trades);

protected:
   //--- create dependent controls
   bool              CreateCheckBoxBuy(void);
   bool              CreateCheckBoxSell(void);
   bool              CreateCheckBoxCloseOnHiLo(void);
   bool              CreateCheckBoxCloseOnTp(void);

   bool              CreateConfigsTrade1();
   bool              CreateTradesConfig();
  };
//+------------------------------------------------------------------+
//| Event Handling                                                   |
//+------------------------------------------------------------------+
EVENT_MAP_BEGIN(CHiLoMultiDialog)
//ON_EVENT(ON_CHANGE,m_checkbox_buy,OnChangeCheckBoxBuy)
//ON_EVENT(ON_CHANGE,m_checkbox_sell,OnChangeCheckBoxSell)
//ON_EVENT(ON_CHANGE,m_checkbox_close_on_hilo,OnChangeCheckBoxCloseHiLo)
//
//ON_EVENT(ON_CLICK,m_button_start,OnClickButtonStart)
//ON_EVENT(ON_CLICK,m_button_stop,OnClickButtonStop)
//ON_EVENT(ON_CLICK,m_button_reset_to_defaults,OnClickButtonResetToDefaults)
//
//ON_EVENT(ON_CHANGE,m_edit_volume,OnChangeEditVolume)
//
//ON_EVENT(ON_CLICK,m_button_update_tpsl,OnChangeUpdateTpSlButton)
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
//| Add the HiLoMa to the HiLoMulTiDialog
//+------------------------------------------------------------------+
void CHiLoMultiDialog::AddModel(CHiLoMaHandle *hiloMa)
  {
   m_list_hilo_ma.Add(hiloMa);
  }
//+------------------------------------------------------------------+
//| Create the interface
//+------------------------------------------------------------------+
bool CHiLoMultiDialog::Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2)
  {
   if(!CAppDialog::Create(chart,name,subwin,x1,y1,x2,y2))
      return false;

   if(!CreateCheckBoxBuy())
      return false;
   if(!CreateCheckBoxSell())
      return false;
   if(!CreateCheckBoxCloseOnHiLo())
      return false;
   if(!CreateCheckBoxCloseOnTp())
      return false;

//if(!CreateConfigsTrade1())
//   return false;

   if(!CreateTradesConfig())
      return false;
//
//   if(!CreateButtonStart())
//      return false;
//   if(!CreateButtonStop())
//      return false;
//   if(!CreateButtonResetToDefaults())
//      return false;
//
//   if(!CreateEditVolume())
//      return false;
//
//   if(!CreateTakeProfit())
//      return false;
//   if(!CreateStopLoss())
//      return false;
//   if(!CreateButtonUpdateTpSl())
//      return false;
//
//   if(!CreateEditVolumeStatus())
//      return false;
//
   InitToDefaults();
//   InitWhenTradeIsOn();

   return true;
  }
//+------------------------------------------------------------------+
//| Update the current controls on a ChartEvent
//+------------------------------------------------------------------+
bool CHiLoMultiDialog::ChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
//--- Run the parent ChartEvent
//   CAppDialog::ChartEvent(id,lparam,dparam,sparam);
//
//   if(id==CHARTEVENT_CLICK)
//     {
//      if(sparam=="m_button_start")
//         OnClickButtonStart();
//      if(sparam=="m_button_stop")
//         OnClickButtonStop();
//     }
//   if(sparam=="m_edit_volume")
//     {
//      OnChangeEditVolume();
//      ChartRedraw();
//     }

   return true;
  }
//+------------------------------------------------------------------+
//| Init the defaults values
//+------------------------------------------------------------------+
void CHiLoMultiDialog::InitToDefaults(void)
  {
//ResetVolumesToDefault();

   m_checkbox_buy.Checked(false);
   m_checkbox_sell.Checked(false);
   m_checkbox_close_on_hilo.Checked(false);
   m_checkbox_close_on_tp.Checked(true);

// trade 1
   m_checkbox_trade1_enabled.Checked(true);

//PrintAllStatus();
  }
//+------------------------------------------------------------------+
//| Update dialog based on CTrades
//+------------------------------------------------------------------+
void CHiLoMultiDialog::UpdateDialog(int index,CTrades *trades)
  {
   if(trades.IsTradeEnable())
     {
      CCheckBox *m_trade_c_enable=m_list_trade_c_enable.GetNodeAtIndex(index);
      m_trade_c_enable.Checked(true);
     }

   CEdit *m_edit_e_volume=m_list_trade_e_volume.GetNodeAtIndex(index);
   m_edit_e_volume.Text(DoubleToString(trades.CurrentVolume(),0));

   CEdit *m_edit_e_next_volume=m_list_trade_e_next_volume.GetNodeAtIndex(index);
   m_edit_e_next_volume.Text(DoubleToString(trades.NextVolume(),0));

//m_trade_e_take_profit.Text(DoubleToString(trades.GetTakeProfit(),0));
//m_trade_e_stop_loss.Text(DoubleToString(trades.GetStopLoss(),0));
  }
//+------------------------------------------------------------------+
//| Create the Buy CheckBox
//+------------------------------------------------------------------+
bool CHiLoMultiDialog::CreateCheckBoxBuy(void)
  {
//--- coordinates
   int x1=INDENT_LEFT;
   int y1=INDENT_TOP;
   int x2=x1+WIDTH_DEFAULT;
   int y2=y1+HEIGHT_DEFAULT;

//--- create
   if(!m_checkbox_buy.Create(m_chart_id,"m_checkbox_buy",m_subwin,x1,y1,x2,y2))
      return false;
   if(!m_checkbox_buy.Text("Buy"))
      return false;
   if(!Add(m_checkbox_buy))
      return false;

   return true;
  }
//+------------------------------------------------------------------+
//| Create the Sell CheckBox
//+------------------------------------------------------------------+
bool CHiLoMultiDialog::CreateCheckBoxSell(void)
  {
//--- coordinates
   int x1=INDENT_LEFT+2*(5*CONTROLS_GAP_X);
   int y1=INDENT_TOP;
   int x2=x1+WIDTH_DEFAULT;
   int y2=y1+HEIGHT_DEFAULT;

//--- create
   if(!m_checkbox_sell.Create(m_chart_id,"m_checkbox_sell",m_subwin,x1,y1,x2,y2))
      return false;
   if(!m_checkbox_sell.Text("Sell"))
      return false;
   if(!Add(m_checkbox_sell))
      return false;

   return true;
  }
//+------------------------------------------------------------------+
//| Create the Close If Profit / Loss CheckBox
//+------------------------------------------------------------------+
bool CHiLoMultiDialog::CreateCheckBoxCloseOnHiLo(void)
  {
//--- coordinates
   int x1=INDENT_LEFT+3*(7*CONTROLS_GAP_X);
   int y1=INDENT_TOP;
   int x2=x1+WIDTH_DEFAULT+WIDTH_ADJUST;
   int y2=y1+HEIGHT_DEFAULT;

//--- create
   if(!m_checkbox_close_on_hilo.Create(m_chart_id,"m_checkbox_close_on_hilo",m_subwin,x1,y1,x2,y2))
      return false;
   if(!m_checkbox_close_on_hilo.Text("Close HiLo"))
      return false;
   if(!Add(m_checkbox_close_on_hilo))
      return false;
//--- succeed
   return true;
  }
//+------------------------------------------------------------------+
//| Create the Close If Profit / Loss CheckBox
//+------------------------------------------------------------------+
bool CHiLoMultiDialog::CreateCheckBoxCloseOnTp(void)
  {
//--- coordinates
   int x1=INDENT_LEFT+4*(10*CONTROLS_GAP_X);
   int y1=INDENT_TOP;
   int x2=x1+1*WIDTH_DEFAULT;
   int y2=y1+HEIGHT_DEFAULT;

//--- create
   if(!m_checkbox_close_on_tp.Create(m_chart_id,"m_checkbox_close_on_tp",m_subwin,x1,y1,x2,y2))
      return false;
   if(!m_checkbox_close_on_tp.Text("Close Tp"))
      return false;
   if(!Add(m_checkbox_close_on_tp))
      return false;
//--- succeed
   return true;
  }
//+------------------------------------------------------------------+
//| Create buttons config for Trade 1
//+------------------------------------------------------------------+
bool CHiLoMultiDialog::CreateConfigsTrade1()
  {
//--- label enabled
   int x1=INDENT_LEFT;
   int y1=INDENT_TOP+2*(2*CONTROLS_GAP_Y);
   int x2=x1+WIDTH_DEFAULT;
   int y2=y1+HEIGHT_DEFAULT;

   if(!m_label_trade1_info.Create(m_chart_id,"m_label_trade1_info",m_subwin,x1,y1,x2,y2))
      return false;
   if(!m_label_trade1_info.Text("Trade 1"))
      return false;
   if(!Add(m_label_trade1_info))
      return false;

//--- checkbox enabled
   x1=INDENT_LEFT+2*(2*CONTROLS_GAP_X);
   y1=INDENT_TOP+2*(2*CONTROLS_GAP_Y);
   x2=x1+WIDTH_DEFAULT;
   y2=y1+HEIGHT_DEFAULT;

   if(!m_checkbox_trade1_enabled.Create(m_chart_id,"m_checkbox_trade1_enabled",m_subwin,x1,y1,x2,y2))
      return false;
   if(!m_checkbox_trade1_enabled.Text("Enable"))
      return false;
   if(!Add(m_checkbox_trade1_enabled))
      return false;

   return true;
  }
//+------------------------------------------------------------------+
//| Create Trades Config for all Trades
//+------------------------------------------------------------------+
bool CHiLoMultiDialog::CreateTradesConfig()
  {
//CMdJumper *currentMd=m_md_jumpers.GetCurrentNode();
// while(currentMd!=NULL)
   for(int i=0;i<m_list_hilo_ma.Total();i++)
     {
      int indexNameTrade=i+1;

      CLabel *m_trade_l_name=new CLabel();
      CCheckBox *m_trade_c_enable=new CCheckBox();

      CLabel *m_trade_l_volume=new CLabel();
      CEdit *m_trade_e_volume=new CEdit();

      CLabel *m_trade_l_take_profit=new CLabel();
      CEdit *m_trade_e_take_profit=new CEdit();
      CLabel *m_trade_l_stop_loss=new CLabel();
      CEdit *m_trade_e_stop_loss=new CEdit();

      //--- label trade's name
      int x1=INDENT_LEFT;
      int y1=INDENT_TOP+2*(2*CONTROLS_GAP_Y);
      int x2=x1+WIDTH_DEFAULT;
      int y2=y1+HEIGHT_DEFAULT;


      if(!m_trade_l_name.Create(m_chart_id,"m_trade_l_name"+IntegerToString(indexNameTrade),m_subwin,x1,y1,x2,y2))
         return false;
      if(!m_trade_l_name.Text("Trade "+IntegerToString(indexNameTrade)))
         return false;
      if(!Add(m_trade_l_name))
         return false;

      //--- checkbox enabled
      x1=INDENT_LEFT+2*(3*CONTROLS_GAP_X);
      y1=INDENT_TOP+2*(2*CONTROLS_GAP_Y);
      x2=x1+WIDTH_DEFAULT;
      y2=y1+HEIGHT_DEFAULT;

      if(!m_trade_c_enable.Create(m_chart_id,"m_trade_c_enable"+IntegerToString(indexNameTrade),m_subwin,x1,y1,x2,y2))
         return false;
      if(!m_trade_c_enable.Text("Enable"))
         return false;
      if(!Add(m_trade_c_enable))
         return false;

      //--- Label Volume
      x1=INDENT_LEFT+3*(7*CONTROLS_GAP_X);
      y1=INDENT_TOP+2*(2*CONTROLS_GAP_Y);
      x2=x1+WIDTH_DEFAULT;
      y2=y1+HEIGHT_DEFAULT;

      if(!m_trade_l_volume.Create(m_chart_id,"m_trade_l_volume"+IntegerToString(indexNameTrade),m_subwin,x1,y1,x2,y2))
         return false;
      if(!m_trade_l_volume.Text("Volume"))
         return false;
      if(!Add(m_trade_l_volume))
         return false;

      //--- Edit Volume
      x1=INDENT_LEFT+4*(6*CONTROLS_GAP_X);
      y1=INDENT_TOP+2*(2*CONTROLS_GAP_Y);
      x2=x1+WIDTH_SHORT;
      y2=y1+HEIGHT_DEFAULT;

      if(!m_trade_e_volume.Create(m_chart_id,"m_trade_e_volume"+IntegerToString(indexNameTrade),m_subwin,x1,y1,x2,y2))
         return false;
      if(!Add(m_trade_e_volume))
         return false;

      //--- Label Take Profit
      x1=INDENT_LEFT+5*(7*CONTROLS_GAP_X);
      y1=INDENT_TOP+2*(2*CONTROLS_GAP_Y);
      x2=x1+WIDTH_DEFAULT;
      y2=y1+HEIGHT_DEFAULT;

      if(!m_trade_l_take_profit.Create(m_chart_id,"m_trade_l_take_profit"+IntegerToString(indexNameTrade),m_subwin,x1,y1,x2,y2))
         return false;
      if(!m_trade_l_take_profit.Text("TP"))
         return false;
      if(!Add(m_trade_l_take_profit))
         return false;

      //--- Edit Take Profit
      x1=INDENT_LEFT+6*(6*CONTROLS_GAP_X);
      y1=INDENT_TOP+2*(2*CONTROLS_GAP_Y);
      x2=x1+WIDTH_SHORT;
      y2=y1+HEIGHT_DEFAULT;

      if(!m_trade_e_take_profit.Create(m_chart_id,"m_trade_e_take_profit"+IntegerToString(indexNameTrade),m_subwin,x1,y1,x2,y2))
         return false;
      if(!Add(m_trade_e_take_profit))
         return false;

      //--- Label Stop Loss
      x1=INDENT_LEFT+7*(7*CONTROLS_GAP_X);
      y1=INDENT_TOP+2*(2*CONTROLS_GAP_Y);
      x2=x1+WIDTH_DEFAULT;
      y2=y1+HEIGHT_DEFAULT;

      if(!m_trade_l_stop_loss.Create(m_chart_id,"m_trade_l_stop_loss"+IntegerToString(indexNameTrade),m_subwin,x1,y1,x2,y2))
         return false;
      if(!m_trade_l_stop_loss.Text("SL"))
         return false;
      if(!Add(m_trade_l_stop_loss))
         return false;

      //--- Edit Stop Loss
      x1=INDENT_LEFT+8*(6*CONTROLS_GAP_X);
      y1=INDENT_TOP+2*(2*CONTROLS_GAP_Y);
      x2=x1+WIDTH_SHORT;
      y2=y1+HEIGHT_DEFAULT;

      if(!m_trade_e_stop_loss.Create(m_chart_id,"m_trade_e_stop_loss"+IntegerToString(indexNameTrade),m_subwin,x1,y1,x2,y2))
         return false;
      if(!Add(m_trade_e_stop_loss))
         return false;

      CHiLoMaHandle *hma=m_list_hilo_ma.GetNodeAtIndex(i);

      CTrades *trades=hma.GetTrades();

      m_trade_e_take_profit.TextAlign(ALIGN_CENTER);
      m_trade_e_stop_loss.TextAlign(ALIGN_CENTER);

      UpdateDialog(i,trades);

      // add the items to panel
      m_list_trade_l_name.Add(m_trade_l_name);
      m_list_trade_c_enable.Add(m_trade_c_enable);
      m_list_trade_l_take_profit.Add(m_trade_l_take_profit);
      m_list_trade_e_take_profit.Add(m_trade_e_take_profit);
      m_list_trade_l_stop_loss.Add(m_trade_l_stop_loss);
      m_list_trade_e_stop_loss.Add(m_trade_e_stop_loss);
     }

   return true;
  }
//+------------------------------------------------------------------+
