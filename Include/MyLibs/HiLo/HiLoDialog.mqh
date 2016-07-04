//+------------------------------------------------------------------+
//|                                        Exp Panel HiLo Dialog.mqh |
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
#define WIDTH_BIG                           (160)     // size by X coordinate
#define WIDTH_ADJUST                        (10)      // size by X coordinate
//-- height sizes
#define HEIGHT_DEFAULT                      (20)      // size by X coordinate
//+------------------------------------------------------------------+
//| Class CPanelHiLoDialog                                           
//| Usage: main dialog of the Controls application                                                                 |
//+------------------------------------------------------------------+
class CHiLoDialog : public CAppDialog
  {
   CCheckBox         m_checkbox_buy;
   CCheckBox         m_checkbox_sell;
   CCheckBox         m_checkbox_close_on_hilo;
   CCheckBox         m_checkbox_close_on_tp;

   CButton           m_button_start;
   CButton           m_button_stop;
   CButton           m_button_reset_to_defaults;

   CLabel            m_label_volume;
   CEdit             m_edit_volume;

   CCheckBox         m_checkbox_take_profit;
   CEdit             m_edit_take_profit;
   CCheckBox         m_checkbox_stop_loss;
   CEdit             m_edit_stop_loss;
   CButton           m_button_update_tpsl;

   CLabel            m_label_volume_status;

   double            m_current_volume;

public:
                     CHiLoDialog(void);
                    ~CHiLoDialog(void);
   //--- create
   bool              Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2);
   //--- chart event handler
   bool              OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   bool              ChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam);

   void              InitToDefaults();
   void              InitWhenTradeIsOn();
   void              InitForTest();
   void              ResetVolumesToDefault();
   void              PrintAllStatus();

   bool              IsBuyChecked(void);
   bool              IsSellChecked(void);
   bool              IsCloseHiLoChecked(void);
   bool              IsCloseTpChecked(void);

   bool              IsTakeProfitChecked(void);
   bool              IsStopLossChecked(void);

   void              LoadVolumesToEditBox(void);
   void              LoadVolumeStatusToLabel(void);

   double            CurrentVolume();
   double            NextVolume();

   double            TakeProfit();
   double            StopLoss();

   void              CalculateVolumeFactor();

protected:
   //--- create dependent controls
   bool              CreateCheckBoxBuy(void);
   bool              CreateCheckBoxSell(void);
   bool              CreateCheckBoxCloseOnHiLo(void);
   bool              CreateCheckBoxCloseOnTp(void);

   bool              CreateButtonStart(void);
   bool              CreateButtonStop(void);
   bool              CreateButtonResetToDefaults(void);

   bool              CreateEditVolume(void);

   bool              CreateTakeProfit(void);
   bool              CreateStopLoss(void);
   bool              CreateButtonUpdateTpSl(void);

   bool              CreateEditVolumeStatus(void);

   //--- handlers of the dependent controls events
   void              OnChangeCheckBoxBuy(void);
   void              OnChangeCheckBoxSell(void);
   void              OnChangeCheckBoxCloseHiLo(void);

   void              OnClickButtonStart(void);
   void              OnClickButtonStop(void);
   void              OnClickButtonResetToDefaults(void);

   void              OnChangeEditVolume(void);

   void              OnChangeUpdateTpSlButton(void);
  };
//+------------------------------------------------------------------+
//| Event Handling                                                   |
//+------------------------------------------------------------------+
EVENT_MAP_BEGIN(CHiLoDialog)
ON_EVENT(ON_CHANGE,m_checkbox_buy,OnChangeCheckBoxBuy)
ON_EVENT(ON_CHANGE,m_checkbox_sell,OnChangeCheckBoxSell)
ON_EVENT(ON_CHANGE,m_checkbox_close_on_hilo,OnChangeCheckBoxCloseHiLo)

ON_EVENT(ON_CLICK,m_button_start,OnClickButtonStart)
ON_EVENT(ON_CLICK,m_button_stop,OnClickButtonStop)
ON_EVENT(ON_CLICK,m_button_reset_to_defaults,OnClickButtonResetToDefaults)

ON_EVENT(ON_CHANGE,m_edit_volume,OnChangeEditVolume)

ON_EVENT(ON_CLICK,m_button_update_tpsl,OnChangeUpdateTpSlButton)
EVENT_MAP_END(CAppDialog)
//+------------------------------------------------------------------+
//| Constructor
//+------------------------------------------------------------------+
CHiLoDialog::CHiLoDialog(void)
  {
  }
//+------------------------------------------------------------------+
//| Destructor
//+------------------------------------------------------------------+
CHiLoDialog::~CHiLoDialog(void)
  {
  }
//+------------------------------------------------------------------+
//| Create the interface
//+------------------------------------------------------------------+
bool CHiLoDialog::Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2)
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

   if(!CreateButtonStart())
      return false;
   if(!CreateButtonStop())
      return false;
   if(!CreateButtonResetToDefaults())
      return false;

   if(!CreateEditVolume())
      return false;

   if(!CreateTakeProfit())
      return false;
   if(!CreateStopLoss())
      return false;
   if(!CreateButtonUpdateTpSl())
      return false;

   if(!CreateEditVolumeStatus())
      return false;

   InitToDefaults();
   InitWhenTradeIsOn();

   return true;
  }
//+------------------------------------------------------------------+
//| Update the current controls on a ChartEvent
//+------------------------------------------------------------------+
bool CHiLoDialog::ChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
//--- Run the parent ChartEvent
   CAppDialog::ChartEvent(id,lparam,dparam,sparam);

   if(id==CHARTEVENT_CLICK)
     {
      if(sparam=="m_button_start")
         OnClickButtonStart();
      if(sparam=="m_button_stop")
         OnClickButtonStop();
     }
   if(sparam=="m_edit_volume")
     {
      OnChangeEditVolume();
      ChartRedraw();
     }

   return true;
  }
//+------------------------------------------------------------------+
//| Init the defaults values
//+------------------------------------------------------------------+
void CHiLoDialog::InitToDefaults(void)
  {
   ResetVolumesToDefault();

   m_checkbox_buy.Checked(false);
   m_checkbox_sell.Checked(false);
   m_checkbox_close_on_hilo.Checked(false);
   m_checkbox_close_on_tp.Checked(true);

   m_checkbox_take_profit.Checked(true);
   m_edit_take_profit.Text(DoubleToString(InpTradeTakeProfit,0));
   m_edit_stop_loss.Text(DoubleToString(InpTradeStopLoss,0));

   PrintAllStatus();
  }
//+------------------------------------------------------------------+
//| Init when there is already current position
//+------------------------------------------------------------------+
void CHiLoDialog::InitWhenTradeIsOn()
  {
   MyTrade.LoadTradeOperationFromPosition();

   if(MyTrade.IsOnTradeOperation())
     {
      if(MyTrade.IsOnBuyTrade())
         m_checkbox_buy.Checked(true);
      else
         m_checkbox_sell.Checked(true);

      m_current_volume=MyTrade.CurrentTradeVolume();

      LoadVolumesToEditBox();
      HiLoTrades.BreakEvenShow();

      Print("******** Printing again the status since there is a current position ******** ");
      PrintAllStatus();
     }
  }
//+------------------------------------------------------------------+
//| Init the dialog for test
//+------------------------------------------------------------------+
void CHiLoDialog::InitForTest()
  {
   m_checkbox_buy.Checked(true);
   m_checkbox_sell.Checked(true);
   ResetVolumesToDefault();
  }
//+------------------------------------------------------------------+
//| Reset the current volume to default value.                                                                 
//+------------------------------------------------------------------+
void CHiLoDialog::ResetVolumesToDefault(void)
  {
   m_current_volume=InpTradeVolume;
   LoadVolumesToEditBox();
  }
//+------------------------------------------------------------------+
//| Print All Status                                                                 |
//+------------------------------------------------------------------+
void CHiLoDialog::PrintAllStatus(void)
  {
   string buyChecked=m_checkbox_buy.Checked() ? "Y" : "N";
   string sellChecked=m_checkbox_sell.Checked() ? "Y" : "N";
   string closeTpSlChecked=m_checkbox_close_on_hilo.Checked() ? "Y" : "N";

   string buyTrade=MyTrade.IsOnBuyTrade() ? "Y" : "N";
   string sellTrade=MyTrade.IsOnSellTrade() ? "Y" : "N";

   string tpChecked=m_checkbox_take_profit.Checked() ? "Y" : "N";
   string tpValue=m_edit_take_profit.Text();

   string slChecked=m_checkbox_stop_loss.Checked() ? "Y" : "N";
   string slValue=m_edit_stop_loss.Text();

   string tEnabled=InpTimeEnabled ? "Y" : "N";
   datetime dtStart=Time.IntToDatetime(InpTimeStartHour,InpTimeStartMinute);
   string timeStart=TimeToString(dtStart);
   datetime dtEnd=Time.IntToDatetime(InpTimeEndHour,InpTimeEndMinute);
   string timeEnd=TimeToString(dtEnd);

   string volumeFactorBreakevenEnabled=InpTradeVolumeFactorBreakEvenEnabled? "Y" : "N";

   PrintFormat("Status for: %s",_Symbol);
   PrintFormat("Buy: (%s), Sell: (%s), Close P/L: (%s)",buyChecked,sellChecked,closeTpSlChecked);
   PrintFormat("Buy Trade: (%s), Sell Trade: (%s)",buyTrade,sellTrade);
   PrintFormat("Volume: (%.2f), Price Per Volume: (%.2f)",m_current_volume,InpTradePricePerVolume);
   PrintFormat("Take Profit: (%s - %s), Stop Loss: (%s - %s)",tpChecked,tpValue,slChecked,slValue);
   PrintFormat("Time Enabled: (%s), Time Start: (%s), Time End: (%s)",tEnabled,timeStart,timeEnd);
   PrintFormat("Volume Factor (Martingale): (%.2f)",InpTradeVolumeFactor);
   PrintFormat("Volume Factor BreakEven Points Enabled: (%s) Points to BreakEven: (%.2f)",volumeFactorBreakevenEnabled,InpTradeVolumeFactorBreakEvenPoints);
   PrintFormat("Finished Status for: %s",_Symbol);
  }
//+------------------------------------------------------------------+
//| Verify if the m_checkbox_buy is Checked
//+------------------------------------------------------------------+
bool CHiLoDialog::IsBuyChecked(void)
  {
   return m_checkbox_buy.Checked();
  }
//+------------------------------------------------------------------+
//| Verify if the m_checkbox_sell is Checked
//+------------------------------------------------------------------+
bool CHiLoDialog::IsSellChecked(void)
  {
   return m_checkbox_sell.Checked();
  }
//+------------------------------------------------------------------+
//| Verify if the m_checkbox_close_on_hilo is Checked
//+------------------------------------------------------------------+
bool CHiLoDialog::IsCloseHiLoChecked(void)
  {
   return m_checkbox_close_on_hilo.Checked();
  }
//+------------------------------------------------------------------+
//| Verify if the m_checkbox_close_on_tp is Checked
//+------------------------------------------------------------------+
bool CHiLoDialog::IsCloseTpChecked(void)
  {
   return m_checkbox_close_on_tp.Checked();
  }
//+------------------------------------------------------------------+
//| Verify if the m_checkbox_take_profit is Checked
//+------------------------------------------------------------------+
bool CHiLoDialog::IsTakeProfitChecked(void)
  {
   return m_checkbox_take_profit.Checked();
  }
//+------------------------------------------------------------------+
//| Verify if the m_checkbox_stop_loss is Checked
//+------------------------------------------------------------------+
bool CHiLoDialog::IsStopLossChecked(void)
  {
   return m_checkbox_stop_loss.Checked();
  }
//+------------------------------------------------------------------+
//| Load volumes to Edit Box
//+------------------------------------------------------------------+
void CHiLoDialog::LoadVolumesToEditBox(void)
  {
   m_edit_volume.Text(DoubleToString(m_current_volume,2));
   ChartRedraw();
  }
//+------------------------------------------------------------------+
//| Load the volume status (Volume/Profit/Points) in the Edit Box
//+------------------------------------------------------------------+
void CHiLoDialog::LoadVolumeStatusToLabel(void)
  {
   string newStatus=MyTrade.CurrentPositionStatus();
   string currentStatus=m_label_volume_status.Text();

   if(currentStatus!=newStatus)
     {
      m_label_volume_status.Text(newStatus);
      ChartRedraw();
     }
  }
//+------------------------------------------------------------------+
//| Returns the current Volume
//+------------------------------------------------------------------+
double CHiLoDialog::CurrentVolume(void)
  {
   return m_current_volume;
  }
//+------------------------------------------------------------------+
//| Returns the TakeProfit
//+------------------------------------------------------------------+
double CHiLoDialog::TakeProfit()
  {
   double takeProfit=StringToDouble(m_edit_take_profit.Text());
   return takeProfit;
  }
//+------------------------------------------------------------------+
//| Returns the StopLoss                                                              
//+------------------------------------------------------------------+
double CHiLoDialog::StopLoss()
  {
   double stopLoss=StringToDouble(m_edit_stop_loss.Text());
   return stopLoss;
  }
//+------------------------------------------------------------------+
//| Calculate the volume to use for Trade
//+------------------------------------------------------------------+
void CHiLoDialog::CalculateVolumeFactor()
  {
   Sleep(500); // give a time to update the history.
   Print("Calculating the next volume");

   if(InpTradeVolumeFactorBreakEvenEnabled)
      m_current_volume=MyTrade.CalculateVolumeFactorOnBreakEven(InpTradeVolumeFactorBreakEvenPoints,InpTradeVolumeFactor,InpTradePricePerVolume);
   else
      m_current_volume=MyTrade.CalculateVolumeFactor(InpTradeVolumeFactor,m_current_volume);

   if(m_current_volume>InpTradeMaxVolume)
      InitToDefaults();

   LoadVolumesToEditBox();
  }
//+------------------------------------------------------------------+
//| Create the Buy CheckBox
//+------------------------------------------------------------------+
bool CHiLoDialog::CreateCheckBoxBuy(void)
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
bool CHiLoDialog::CreateCheckBoxSell(void)
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
bool CHiLoDialog::CreateCheckBoxCloseOnHiLo(void)
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
bool CHiLoDialog::CreateCheckBoxCloseOnTp(void)
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
//| Create the Start Button
//+------------------------------------------------------------------+
bool CHiLoDialog::CreateButtonStart(void)
  {
//--- coordinates
   int x1=INDENT_LEFT;
   int y1=INDENT_TOP+2*(3*CONTROLS_GAP_Y);
   int x2=x1+WIDTH_DEFAULT;
   int y2=y1+HEIGHT_DEFAULT;

//--- create
   if(!m_button_start.Create(m_chart_id,"m_button_start",m_subwin,x1,y1,x2,y2))
      return false;
   if(!m_button_start.Text("Start"))
      return false;
   if(!Add(m_button_start))
      return false;

   return true;
  }
//+------------------------------------------------------------------+
//| Create the Stop Button
//+------------------------------------------------------------------+
bool CHiLoDialog::CreateButtonStop(void)
  {
//--- coordinates
   int x1=INDENT_LEFT+2*(9.8*CONTROLS_GAP_X);
   int y1=INDENT_TOP+2*(3*CONTROLS_GAP_Y);
   int x2=x1+WIDTH_DEFAULT;
   int y2=y1+HEIGHT_DEFAULT;

//--- create
   if(!m_button_stop.Create(m_chart_id,"m_button_stop",m_subwin,x1,y1,x2,y2))
      return false;
   if(!m_button_stop.Text("Stop"))
      return false;
   if(!Add(m_button_stop))
      return false;

   return true;
  }
//+------------------------------------------------------------------+
//| Create the Reset to Defaults Button
//+------------------------------------------------------------------+
bool CHiLoDialog::CreateButtonResetToDefaults(void)
  {
//--- coordinates
   int x1=INDENT_LEFT+3*(13*CONTROLS_GAP_X);
   int y1=INDENT_TOP+2*(3*CONTROLS_GAP_Y);
   int x2=x1+WIDTH_DEFAULT;
   int y2=y1+HEIGHT_DEFAULT;

//--- create
   if(!m_button_reset_to_defaults.Create(m_chart_id,"m_button_reset_to_defaults",m_subwin,x1,y1,x2,y2))
      return false;
   if(!m_button_reset_to_defaults.Text("Defaults"))
      return false;
   if(!Add(m_button_reset_to_defaults))
      return false;

   return true;
  }
//+------------------------------------------------------------------+
//| Create the label and button for Volume
//+------------------------------------------------------------------+
bool CHiLoDialog::CreateEditVolume(void)
  {
//--- coordinates label volume
   int x1=(int)(INDENT_LEFT+1*(3.5*CONTROLS_GAP_X));
   int y1=INDENT_TOP+3*(4*CONTROLS_GAP_Y);
   int x2=x1+WIDTH_DEFAULT;
   int y2=y1+HEIGHT_DEFAULT;

//--- create label volume
   if(!m_label_volume.Create(m_chart_id,"m_label_volume",m_subwin,x1,y1,x2,y2))
      return false;
   if(!m_label_volume.Text("Volume"))
      return false;
   if(!Add(m_label_volume))
      return false;

//--- coordinates edit volume
   x1=INDENT_LEFT;
   y1=(int)(INDENT_TOP+3*(5.5*CONTROLS_GAP_Y));
   x2=x1+WIDTH_DEFAULT;
   y2=y1+HEIGHT_DEFAULT;

//--- create edit volume
   if(!m_edit_volume.Create(m_chart_id,"m_edit_volume",m_subwin,x1,y1,x2,y2))
      return false;
   if(!Add(m_edit_volume))
      return false;

   m_edit_volume.TextAlign(ALIGN_CENTER);
   return true;
  }
//+------------------------------------------------------------------+
//| Create the checkbox for TakeProfit
//+------------------------------------------------------------------+
bool CHiLoDialog::CreateTakeProfit(void)
  {
//--- checkbox take profit
   int x1=INDENT_LEFT+2*(9.8*CONTROLS_GAP_X);
   int y1=INDENT_TOP+3*(4*CONTROLS_GAP_Y);
   int x2=x1+WIDTH_DEFAULT;
   int y2=y1+HEIGHT_DEFAULT;

   if(!m_checkbox_take_profit.Create(m_chart_id,"m_checkbox_take_profit",m_subwin,x1,y1,x2,y2))
      return false;
   if(!m_checkbox_take_profit.Text("Profit"))
      return false;
   if(!Add(m_checkbox_take_profit))
      return false;

//--- edit take profit
   x1=(int)(INDENT_LEFT+2*(9.8*CONTROLS_GAP_X));
   y1=(int)(INDENT_TOP+3*(5.5*CONTROLS_GAP_Y));
   x2=x1+WIDTH_DEFAULT;
   y2=y1+HEIGHT_DEFAULT;

   if(!m_edit_take_profit.Create(m_chart_id,"m_edit_take_profit",m_subwin,x1,y1,x2,y2))
      return false;
   if(!Add(m_edit_take_profit))
      return false;

   m_edit_take_profit.TextAlign(ALIGN_CENTER);
   return true;
  }
//+------------------------------------------------------------------+
//| Create the checkbox for StopLoss
//+------------------------------------------------------------------+
bool CHiLoDialog::CreateStopLoss(void)
  {
//--- checkbox stop loss
   int x1=INDENT_LEFT+3*(13*CONTROLS_GAP_X);
   int y1=INDENT_TOP+3*(4*CONTROLS_GAP_Y);
   int x2=x1+WIDTH_DEFAULT;
   int y2=y1+HEIGHT_DEFAULT;

   if(!m_checkbox_stop_loss.Create(m_chart_id,"m_checkbox_stop_loss",m_subwin,x1,y1,x2,y2))
      return false;
   if(!m_checkbox_stop_loss.Text("Loss"))
      return false;
   if(!Add(m_checkbox_stop_loss))
      return false;

//--- edit take profit
   x1=INDENT_LEFT+3*(13*CONTROLS_GAP_X);
   y1=(int)(INDENT_TOP+3*(5.5*CONTROLS_GAP_Y));
   x2=x1+WIDTH_DEFAULT;
   y2=y1+HEIGHT_DEFAULT;
   if(!m_edit_stop_loss.Create(m_chart_id,"m_edit_stop_loss",m_subwin,x1,y1,x2,y2))
      return false;
   if(!Add(m_edit_stop_loss))
      return false;

   m_edit_stop_loss.TextAlign(ALIGN_CENTER);
   return true;
  }
//+------------------------------------------------------------------+
//| Create the UpdateTpSlButton
//+------------------------------------------------------------------+
bool CHiLoDialog::CreateButtonUpdateTpSl(void)
  {
//-- button
   int x1=INDENT_LEFT;
   int y1=INDENT_TOP+4*(6*CONTROLS_GAP_Y);
   int x2=(int)(x1+(1.7*WIDTH_BIG));
   int y2=y1+HEIGHT_DEFAULT;

   if(!m_button_update_tpsl.Create(m_chart_id,"m_button_update_tpsl",m_subwin,x1,y1,x2,y2))
      return false;
   if(!m_button_update_tpsl.Text("Update Take Profit / Stop Loss"))
      return false;
   if(!Add(m_button_update_tpsl))
      return false;
   return true;
  }
//+------------------------------------------------------------------+
//| Create the Edit Volume Status
//+------------------------------------------------------------------+
bool CHiLoDialog::CreateEditVolumeStatus(void)
  {
//-- edit
   int x1=INDENT_LEFT;
   int y1=(int)(INDENT_TOP+5*(6.2*CONTROLS_GAP_Y));
   int x2=(int)(x1+(1.7*WIDTH_BIG));
   int y2=y1+HEIGHT_DEFAULT;

   if(!m_label_volume_status.Create(m_chart_id,"m_edit_volume_status",m_subwin,x1,y1,x2,y2))
      return false;

   string status=MyTrade.CurrentPositionStatus();
   if(!m_label_volume_status.Text(status))
      return false;
   if(!Add(m_label_volume_status))
      return false;
   return true;
  }
//+------------------------------------------------------------------+
//| Event Buy CheckBox
//+------------------------------------------------------------------+
void CHiLoDialog::OnChangeCheckBoxBuy(void)
  {
   PrintAllStatus();
  }
//+------------------------------------------------------------------+
//| Event Sell CheckBox
//+------------------------------------------------------------------+
void CHiLoDialog::OnChangeCheckBoxSell(void)
  {
   PrintAllStatus();
  }
//+------------------------------------------------------------------+
//| Event Close Profit Loss CheckBox
//+------------------------------------------------------------------+
void CHiLoDialog::OnChangeCheckBoxCloseHiLo(void)
  {
   PrintAllStatus();
  }
//+------------------------------------------------------------------+
//| Event Start Button
//+------------------------------------------------------------------+
void CHiLoDialog::OnClickButtonStart(void)
  {
   HiLoTrades.TradeStart(m_checkbox_buy.Checked(),m_checkbox_sell.Checked());
  }
//+------------------------------------------------------------------+
//| Event Stop Button
//+------------------------------------------------------------------+
void CHiLoDialog::OnClickButtonStop(void)
  {
   HiLoTrades.TradeStop();
  }
//+------------------------------------------------------------------+
//| Event Reset To Defaults Button
//+------------------------------------------------------------------+
void CHiLoDialog::OnClickButtonResetToDefaults(void)
  {
   InitToDefaults();
  }
//+------------------------------------------------------------------+
//| Event Change Edit Volume 
//+------------------------------------------------------------------+
void CHiLoDialog::OnChangeEditVolume(void)
  {
   double v=StringToDouble(m_edit_volume.Text());
   if(v!=m_current_volume)
     {
      m_current_volume=v;
      LoadVolumesToEditBox();
     }
  }
//+------------------------------------------------------------------+
//| Event Change Button UpdateTpSl
//+------------------------------------------------------------------+
void CHiLoDialog::OnChangeUpdateTpSlButton(void)
  {
   HiLoTrades.ModifyTpSl();
  }
//+------------------------------------------------------------------+
