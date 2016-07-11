//+------------------------------------------------------------------+
//|                                              HiLoMultiDialog.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Frederico Benevides"
#property link      "fredbene@gmail.com"
#property version   "1.00"

#include <Controls\Dialog.mqh>
#include <Controls\CheckBox.mqh>   
#include <Controls\Button.mqh>
#include <Controls\Label.mqh>
#include <Controls\Edit.mqh>
#include <Controls\SpinEdit.mqh>

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
   CCheckBox         m_checkbox_buy;
   CCheckBox         m_checkbox_sell;
   CCheckBox         m_checkbox_close_on_hilo;
   CCheckBox         m_checkbox_close_on_tp;

   CLabel            m_label_trade1_info;
   CCheckBox         m_checkbox_trade1_enabled;
   CLabel            m_label_trade1_hilo;
   CEdit             m_edit_trade1_hilo;
   CLabel            m_label_trade1_ma;
   CEdit             m_edit_trade1_ma;
   CLabel            m_label_trade1_take_profit;
   CEdit             m_edit_trade1_take_profit;

   //   CButton           m_button_start;
   //   CButton           m_button_stop;
   //   CButton           m_button_reset_to_defaults;
   //
   //   CLabel            m_label_volume;
   //   CEdit             m_edit_volume;
   //
   //   CCheckBox         m_checkbox_take_profit;
   //   CEdit             m_edit_take_profit;
   //   CCheckBox         m_checkbox_stop_loss;
   //   CEdit             m_edit_stop_loss;
   //   CButton           m_button_update_tpsl;
   //
   //   CLabel            m_label_volume_status;
   //
   //   double            m_current_volume;

public:
                     CHiLoMultiDialog(void);
                    ~CHiLoMultiDialog(void);
   //--- create
   bool              Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2);
   //--- chart event handler
   bool              OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   bool              ChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam);

   void              InitToDefaults();
   //   void              InitWhenTradeIsOn();
   //   void              InitForTest();
   //   void              ResetVolumesToDefault();
   //   void              PrintAllStatus();
   //
   //   bool              IsBuyChecked(void);
   //   bool              IsSellChecked(void);
   //   bool              IsCloseHiLoChecked(void);
   //   bool              IsCloseTpChecked(void);
   //
   //   bool              IsTakeProfitChecked(void);
   //   bool              IsStopLossChecked(void);
   //
   //   void              LoadVolumesToEditBox(void);
   //   void              LoadVolumeStatusToLabel(void);
   //
   //   double            CurrentVolume();
   //   double            NextVolume();
   //
   //   double            TakeProfit();
   //   double            StopLoss();
   //
   //   void              CalculateVolumeFactor();

protected:
   //--- create dependent controls
   bool              CreateCheckBoxBuy(void);
   bool              CreateCheckBoxSell(void);
   bool              CreateCheckBoxCloseOnHiLo(void);
   bool              CreateCheckBoxCloseOnTp(void);

   bool              CreateConfigsTrade1();
   //
   //   bool              CreateButtonStart(void);
   //   bool              CreateButtonStop(void);
   //   bool              CreateButtonResetToDefaults(void);
   //
   //   bool              CreateEditVolume(void);
   //
   //   bool              CreateTakeProfit(void);
   //   bool              CreateStopLoss(void);
   //   bool              CreateButtonUpdateTpSl(void);
   //
   //   bool              CreateEditVolumeStatus(void);

   //--- handlers of the dependent controls events
   //   void              OnChangeCheckBoxBuy(void);
   //   void              OnChangeCheckBoxSell(void);
   //   void              OnChangeCheckBoxCloseHiLo(void);
   //
   //   void              OnClickButtonStart(void);
   //   void              OnClickButtonStop(void);
   //   void              OnClickButtonResetToDefaults(void);
   //
   //   void              OnChangeEditVolume(void);
   //
   //   void              OnChangeUpdateTpSlButton(void);
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

   if(!CreateConfigsTrade1())
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

//--- label hilo
   x1=INDENT_LEFT+2*(8*CONTROLS_GAP_X);
   y1=INDENT_TOP+2*(2*CONTROLS_GAP_Y);
   x2=x1+WIDTH_DEFAULT;
   y2=y1+HEIGHT_DEFAULT;

   if(!m_label_trade1_hilo.Create(m_chart_id,"m_label_trade1_hilo",m_subwin,x1,y1,x2,y2))
      return false;
   if(!m_label_trade1_hilo.Text("HiLo"))
      return false;
   if(!Add(m_label_trade1_hilo))
      return false;

//--- edit hilo
   x1=INDENT_LEFT+2*(10*CONTROLS_GAP_X);
   y1=INDENT_TOP+2*(2*CONTROLS_GAP_Y);
   x2=x1+WIDTH_SHORT;
   y2=y1+HEIGHT_DEFAULT;

   if(!m_edit_trade1_hilo.Create(m_chart_id,"m_edit_trade1_hilo",m_subwin,x1,y1,x2,y2))
      return false;
   if(!Add(m_edit_trade1_hilo))
      return false;
   m_edit_trade1_hilo.TextAlign(ALIGN_CENTER);

//--- label ma
   x1=INDENT_LEFT+2*(14*CONTROLS_GAP_X);
   y1=INDENT_TOP+2*(2*CONTROLS_GAP_Y);
   x2=x1+WIDTH_DEFAULT;
   y2=y1+HEIGHT_DEFAULT;

   if(!m_label_trade1_ma.Create(m_chart_id,"m_label_trade1_ma",m_subwin,x1,y1,x2,y2))
      return false;
   if(!m_label_trade1_ma.Text("Ma"))
      return false;
   if(!Add(m_label_trade1_ma))
      return false;

//--- edit ma
   x1=INDENT_LEFT+2*(16*CONTROLS_GAP_X);
   y1=INDENT_TOP+2*(2*CONTROLS_GAP_Y);
   x2=x1+WIDTH_SHORT;
   y2=y1+HEIGHT_DEFAULT;

   if(!m_edit_trade1_ma.Create(m_chart_id,"m_edit_trade1_ma",m_subwin,x1,y1,x2,y2))
      return false;
   if(!Add(m_edit_trade1_ma))
      return false;
   m_edit_trade1_ma.TextAlign(ALIGN_CENTER);

//--- label take profit
   x1=INDENT_LEFT+2*(19*CONTROLS_GAP_X);
   y1=INDENT_TOP+2*(2*CONTROLS_GAP_Y);
   x2=x1+WIDTH_DEFAULT;
   y2=y1+HEIGHT_DEFAULT;

   if(!m_label_trade1_take_profit.Create(m_chart_id,"m_label_trade1_take_profit",m_subwin,x1,y1,x2,y2))
      return false;
   if(!m_label_trade1_take_profit.Text("Take Profit"))
      return false;
   if(!Add(m_label_trade1_take_profit))
      return false;

//--- edit take profit
   x1=INDENT_LEFT+2*(24*CONTROLS_GAP_X);
   y1=INDENT_TOP+2*(2*CONTROLS_GAP_Y);
   x2=x1+WIDTH_SHORT;
   y2=y1+HEIGHT_DEFAULT;

   if(!m_edit_trade1_take_profit.Create(m_chart_id,"m_edit_trade1_take_profit",m_subwin,x1,y1,x2,y2))
      return false;
   if(!Add(m_edit_trade1_take_profit))
      return false;
   m_edit_trade1_take_profit.TextAlign(ALIGN_CENTER);

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
   m_edit_trade1_hilo.Text(IntegerToString(InpTrade1HiLoPeriod));
   m_edit_trade1_ma.Text(IntegerToString(InpTrade1MaPeriod));
   m_edit_trade1_take_profit.Text(DoubleToString(InpTrade1TakeProfit,0));

   //PrintAllStatus();
  }
//+------------------------------------------------------------------+
