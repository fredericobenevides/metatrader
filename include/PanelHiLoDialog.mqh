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
//--- sizes
#define WIDTH_DEFAULT                       (80)      // size by X coordinate
#define WIDTH_SHORT                         (45)      // size by X coordinate

#define HEIGHT_DEFAULT                      (20)      // size by X coordinate
//+------------------------------------------------------------------+
//| Class CPanelHiLoDialog                                           
//| Usage: main dialog of the Controls application                   
//+------------------------------------------------------------------+
class CPanelHiLoDialog : public CAppDialog
  {
private:
   CCheckBox         pBuyCheckBox;
   CCheckBox         pSellCheckBox;
   CCheckBox         pClosePLCheckBox;

   CButton           pStartButton;
   CButton           pStopButton;
   CButton           pResetDefaultsButton;

   CLabel            pLabelVolume;
   CEdit             pEditVolume;
   CLabel            pLabelNextVolume;
   CEdit             pEditNextVolume;

   CLabel            pLabelMartingale;
   CButton           pUpMgButton;
   CButton           pDownMgButton;

   CCheckBox         pCheckBoxTakeProfit;
   CEdit             pEditTakeProfit;
   CCheckBox         pCheckBoxStopLoss;
   CEdit             pEditStopLoss;
   CButton           pUpdateTpSlButton;

   int               currentVolume;
   int               nextVolume;

public:
                     CPanelHiLoDialog(void);
                    ~CPanelHiLoDialog(void);
   //--- create
   virtual bool      Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2);
   //--- chart event handler
   virtual bool      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   virtual bool      ChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam);

   void              initToDefaults();
   void              resetVolumesToDefault();

   bool              isBuyChecked(void);
   bool              isSellChecked(void);
   bool              isClosePLChecked(void);

   bool              isTakeProfitChecked(void);
   bool              isStopLossChecked(void);

   void              upMartingale(void);
   void              downMartingale(void);

   int               getCurrentVolume();
   double            getTakeProfit();
   double            getStopLoss();

protected:
   //--- create dependent controls
   bool              CreateBuyCheckBox(void);
   bool              CreateSellCheckBox(void);
   bool              CreateClosePLCheckBox(void);

   bool              CreateStartButton(void);
   bool              CreateStopButton(void);
   bool              CreateResetDefaultsButton(void);

   bool              CreateEditVolume(void);
   bool              CreateNextVolume(void);
   bool              CreateMartingale(void);

   bool              CreateTakeProfit(void);
   bool              CreateStopLoss(void);
   bool              CreateUpdateTpSlButton(void);

   //--- handlers of the dependent controls events
   void              OnClickBuyCheckBox(void);
   void              OnClickSellCheckBox(void);
   void              OnClickClosePLCheckBox(void);

   void              OnClickStartButton(void);
   void              OnClickStopButton(void);
   void              OnClickResetDefaultsButton(void);

   void              OnChangeEditVolume(void);

   void              OnChangeButtonUpdateTpSl(void);

   void              OnClickUpMgButton(void);
   void              OnClickDownMgButton(void);

   //--- methods
   void              loadVolumesToEditBox(void);
  };
//+------------------------------------------------------------------+
//| Event Handling                                                   |
//+------------------------------------------------------------------+
EVENT_MAP_BEGIN(CPanelHiLoDialog)
ON_EVENT(ON_CLICK,pBuyCheckBox,OnClickBuyCheckBox)
ON_EVENT(ON_CLICK,pSellCheckBox,OnClickSellCheckBox)
ON_EVENT(ON_CLICK,pClosePLCheckBox,OnClickClosePLCheckBox)

ON_EVENT(ON_CLICK,pStartButton,OnClickStartButton)
ON_EVENT(ON_CLICK,pStopButton,OnClickStopButton)
ON_EVENT(ON_CLICK,pResetDefaultsButton,OnClickResetDefaultsButton)

ON_EVENT(ON_CHANGE,pEditVolume,OnChangeEditVolume)

ON_EVENT(ON_CLICK,pUpdateTpSlButton,OnChangeButtonUpdateTpSl)

ON_EVENT(ON_CLICK,pUpMgButton,OnClickUpMgButton)
ON_EVENT(ON_CLICK,pDownMgButton,OnClickDownMgButton)
EVENT_MAP_END(CAppDialog)
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CPanelHiLoDialog::CPanelHiLoDialog(void)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CPanelHiLoDialog::~CPanelHiLoDialog(void)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CPanelHiLoDialog::Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2)
  {
   if(!CAppDialog::Create(chart,name,subwin,x1,y1,x2,y2))
      return false;

   if(!CreateBuyCheckBox())
      return false;
   if(!CreateSellCheckBox())
      return false;
   if(!CreateClosePLCheckBox())
      return false;

   if(!CreateStartButton())
      return false;
   if(!CreateStopButton())
      return false;
   if(!CreateResetDefaultsButton())
      return false;

   if(!CreateEditVolume())
      return false;
   if(!CreateNextVolume())
      return false;
   if(!CreateMartingale())
      return false;

   if(!CreateTakeProfit())
      return false;
   if(!CreateStopLoss())
      return false;
   if(!CreateUpdateTpSlButton())
      return false;

   initToDefaults();

   return true;
  }
//+------------------------------------------------------------------+
//| Update the current controls on a ChartEvent
//+------------------------------------------------------------------+
bool      CPanelHiLoDialog::ChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
//--- Run the parent ChartEvent
   CAppDialog::ChartEvent(id,lparam,dparam,sparam);

   if(id==CHARTEVENT_CLICK)
     {
      if(sparam=="pStartButton")
         OnClickStartButton();
      if(sparam=="pStopButton")
         OnClickStopButton();
     }
   if(sparam=="pEditVolume")
     {
      OnChangeEditVolume();
      ChartRedraw();
     }

   return true;
  }
//+------------------------------------------------------------------+
//| Init the defaults values
//+------------------------------------------------------------------+
void CPanelHiLoDialog::initToDefaults(void)
  {
   resetVolumesToDefault();

   pBuyCheckBox.Checked(false);
   pSellCheckBox.Checked(false);
   pClosePLCheckBox.Checked(false);

   pEditTakeProfit.Text(DoubleToString(InpTradeTakeProfit,0));
   pEditStopLoss.Text(DoubleToString(InpTradeStopLoss,0));
  }
//+------------------------------------------------------------------+
//| Reset the current volume to default value.                                                                 
//+------------------------------------------------------------------+
void CPanelHiLoDialog::resetVolumesToDefault(void)
  {
   currentVolume=InpTradeVolume;
   nextVolume=2*currentVolume;
   loadVolumesToEditBox();
  }
//+------------------------------------------------------------------+
//| Verify if the BuyCheckBox is Checked
//+------------------------------------------------------------------+
bool CPanelHiLoDialog::isBuyChecked(void)
  {
   return pBuyCheckBox.Checked();
  }
//+------------------------------------------------------------------+
//| Verify if the SellCheckBox is Checked
//+------------------------------------------------------------------+
bool CPanelHiLoDialog::isSellChecked(void)
  {
   return pSellCheckBox.Checked();
  }
//+------------------------------------------------------------------+
//| Verify if the ClosePLCheckBox is Checked
//+------------------------------------------------------------------+
bool CPanelHiLoDialog::isClosePLChecked(void)
  {
   return pClosePLCheckBox.Checked();
  }
//+------------------------------------------------------------------+
//| Verify if the pCheckBoxTakeProfit is Checked
//+------------------------------------------------------------------+
bool CPanelHiLoDialog::isTakeProfitChecked(void)
  {
   return pCheckBoxTakeProfit.Checked();
  }
//+------------------------------------------------------------------+
//| Verify if the pCheckBoxStopLoss is Checked
//+------------------------------------------------------------------+
bool CPanelHiLoDialog::isStopLossChecked(void)
  {
   return pCheckBoxStopLoss.Checked();
  }
//+------------------------------------------------------------------+
//| Returns the current Volume
//+------------------------------------------------------------------+
int CPanelHiLoDialog::getCurrentVolume(void)
  {
   return currentVolume;
  }
//+------------------------------------------------------------------+
//| Returns the TakeProfit
//+------------------------------------------------------------------+
double CPanelHiLoDialog::getTakeProfit()
  {
   double takeProfit=StringToDouble(pEditTakeProfit.Text());
   return takeProfit;
  }
//+------------------------------------------------------------------+
//| Returns the StopLoss                                                              
//+------------------------------------------------------------------+
double CPanelHiLoDialog::getStopLoss()
  {
   double stopLoss=StringToDouble(pEditStopLoss.Text());
   return stopLoss;
  }
//+------------------------------------------------------------------+
//| Create the Buy CheckBox
//+------------------------------------------------------------------+
bool CPanelHiLoDialog::CreateBuyCheckBox(void)
  {
//--- coordinates
   int x1=INDENT_LEFT;
   int y1=INDENT_TOP;
   int x2=x1+WIDTH_DEFAULT;
   int y2=y1+HEIGHT_DEFAULT;

//--- create
   if(!pBuyCheckBox.Create(m_chart_id,"pBuyCheckBox",m_subwin,x1,y1,x2,y2))
      return false;
   if(!pBuyCheckBox.Text("Buy"))
      return false;
   if(!Add(pBuyCheckBox))
      return false;

   return true;
  }
//+------------------------------------------------------------------+
//| Create the Sell CheckBox
//+------------------------------------------------------------------+
bool CPanelHiLoDialog::CreateSellCheckBox(void)
  {
//--- coordinates
   int x1=INDENT_LEFT+(WIDTH_DEFAULT+CONTROLS_GAP_X);
   int y1=INDENT_TOP;
   int x2=x1+WIDTH_DEFAULT;
   int y2=y1+HEIGHT_DEFAULT;

//--- create
   if(!pSellCheckBox.Create(m_chart_id,"pSellCheckBox",m_subwin,x1,y1,x2,y2))
      return false;
   if(!pSellCheckBox.Text("Sell"))
      return false;
   if(!Add(pSellCheckBox))
      return false;

   return true;
  }
//+------------------------------------------------------------------+
//| Create the Close If Profit / Loss CheckBox
//+------------------------------------------------------------------+
bool CPanelHiLoDialog::CreateClosePLCheckBox(void)
  {
//--- coordinates
   int x1=INDENT_LEFT+1.6*(WIDTH_DEFAULT+CONTROLS_GAP_X);
   int y1=INDENT_TOP;
   int x2=x1+1*WIDTH_DEFAULT;
   int y2=y1+HEIGHT_DEFAULT;

//--- create
   if(!pClosePLCheckBox.Create(m_chart_id,"pClosePLCheckBox",m_subwin,x1,y1,x2,y2))
      return false;
   if(!pClosePLCheckBox.Text("Close P/L"))
      return false;
   if(!Add(pClosePLCheckBox))
      return false;
//--- succeed
   return true;
  }
//+------------------------------------------------------------------+
//| Create the Start Button
//+------------------------------------------------------------------+
bool CPanelHiLoDialog::CreateStartButton(void)
  {
//--- coordinates
   int x1=INDENT_LEFT;
   int y1=INDENT_TOP+(HEIGHT_DEFAULT+CONTROLS_GAP_Y);
   int x2=x1+WIDTH_DEFAULT;
   int y2=y1+HEIGHT_DEFAULT;

//--- create
   if(!pStartButton.Create(m_chart_id,"pStartButton",m_subwin,x1,y1,x2,y2))
      return false;
   if(!pStartButton.Text("Start"))
      return false;
   if(!Add(pStartButton))
      return false;

   return true;
  }
//+------------------------------------------------------------------+
//| Create the Stop Button
//+------------------------------------------------------------------+
bool CPanelHiLoDialog::CreateStopButton(void)
  {
//--- coordinates
   int x1=(2*INDENT_LEFT)+(WIDTH_DEFAULT+CONTROLS_GAP_X);
   int y1=INDENT_TOP+(HEIGHT_DEFAULT+CONTROLS_GAP_Y);
   int x2=x1+WIDTH_DEFAULT;
   int y2=y1+HEIGHT_DEFAULT;

//--- create
   if(!pStopButton.Create(m_chart_id,"pStopButton",m_subwin,x1,y1,x2,y2))
      return false;
   if(!pStopButton.Text("Stop"))
      return false;
   if(!Add(pStopButton))
      return false;

   return true;
  }
//+------------------------------------------------------------------+
//| Create the Reset to Defaults Button
//+------------------------------------------------------------------+
bool CPanelHiLoDialog::CreateResetDefaultsButton(void)
  {
//--- coordinates
   int x1=(2*INDENT_LEFT)+2*(WIDTH_DEFAULT+CONTROLS_GAP_X);
   int y1=INDENT_TOP+(HEIGHT_DEFAULT+CONTROLS_GAP_Y);
   int x2=x1+WIDTH_DEFAULT;
   int y2=y1+HEIGHT_DEFAULT;

//--- create
   if(!pResetDefaultsButton.Create(m_chart_id,"pResetDefaultsButton",m_subwin,x1,y1,x2,y2))
      return false;
   if(!pResetDefaultsButton.Text("Defaults"))
      return false;
   if(!Add(pResetDefaultsButton))
      return false;

   return true;
  }
//+------------------------------------------------------------------+
//| Create the label and button for Volume
//+------------------------------------------------------------------+
bool CPanelHiLoDialog::CreateEditVolume(void)
  {
//--- coordinates label volume
   int x1=INDENT_LEFT;
   int y1=INDENT_TOP+2*(HEIGHT_DEFAULT+CONTROLS_GAP_Y);
   int x2=x1+WIDTH_DEFAULT;
   int y2=y1+HEIGHT_DEFAULT;

//--- create label volume
   if(!pLabelVolume.Create(m_chart_id,"pLabelVolume",m_subwin,x1,y1,x2,y2))
      return false;
   if(!pLabelVolume.Text("Volume"))
      return false;
   if(!Add(pLabelVolume))
      return false;

//--- coordinates edit volume
   x1=INDENT_LEFT;
   y1=(INDENT_TOP/2)+3*(HEIGHT_DEFAULT+CONTROLS_GAP_Y);
   x2=x1+WIDTH_DEFAULT;
   y2=y1+HEIGHT_DEFAULT;

//--- create edit volume
   if(!pEditVolume.Create(m_chart_id,"pEditVolume",m_subwin,x1,y1,x2,y2))
      return false;
   if(!Add(pEditVolume))
      return false;

   pEditVolume.TextAlign(ALIGN_CENTER);
   return true;
  }
//+------------------------------------------------------------------+
//| Create the label and button for Next Volume
//+------------------------------------------------------------------+
bool CPanelHiLoDialog::CreateNextVolume(void)
  {
//--- coordinates label
   int x1=int(1.8*INDENT_LEFT)+(WIDTH_DEFAULT+CONTROLS_GAP_X);
   int y1=INDENT_TOP+2*(HEIGHT_DEFAULT+CONTROLS_GAP_Y);
   int x2=x1+WIDTH_DEFAULT;
   int y2=y1+HEIGHT_DEFAULT;

//--- create label
   if(!pLabelNextVolume.Create(m_chart_id,"pLabelNextVolume",m_subwin,x1,y1,x2,y2))
      return false;
   if(!pLabelNextVolume.Text("Next"))
      return false;
   if(!Add(pLabelNextVolume))
      return false;

//--- coordinates edit
   x1=INDENT_LEFT+(WIDTH_DEFAULT+CONTROLS_GAP_X);
   y1=(INDENT_TOP/2)+3*(HEIGHT_DEFAULT+CONTROLS_GAP_Y);
   x2=x1+WIDTH_DEFAULT;
   y2=y1+HEIGHT_DEFAULT;

//--- create label
   if(!pEditNextVolume.Create(m_chart_id,"pEditNextVolume",m_subwin,x1,y1,x2,y2))
      return false;
   if(!Add(pEditNextVolume))
      return false;

   pEditNextVolume.TextAlign(ALIGN_CENTER);
   pEditNextVolume.ReadOnly(true);

   return true;
  }
//+------------------------------------------------------------------+
//| Create the label and buttons for Martingale
//+------------------------------------------------------------------+
bool CPanelHiLoDialog::CreateMartingale(void)
  {
//--- coordinates label
   int x1=INDENT_LEFT+2*(WIDTH_DEFAULT+CONTROLS_GAP_X);
   int y1=INDENT_TOP+2*(HEIGHT_DEFAULT+CONTROLS_GAP_Y);
   int x2=x1+WIDTH_DEFAULT;
   int y2=y1+HEIGHT_DEFAULT;

//--- create label
   if(!pLabelMartingale.Create(m_chart_id,"pLabelMartingale",m_subwin,x1,y1,x2,y2))
      return false;
   if(!pLabelMartingale.Text("Martingale"))
      return false;
   if(!Add(pLabelMartingale))
      return false;

//--- coordinates up button
   x1=INDENT_LEFT+2*(WIDTH_DEFAULT+CONTROLS_GAP_X);
   y1=int(0.5*INDENT_TOP)+3*(HEIGHT_DEFAULT+CONTROLS_GAP_Y);
   x2=x1+int(0.5*WIDTH_DEFAULT);
   y2=y1+HEIGHT_DEFAULT;

//
////--- create up button 
   if(!pUpMgButton.Create(m_chart_id,"pUpMgButton",m_subwin,x1,y1,x2,y2))
      return false;
   if(!pUpMgButton.Text("Up"))
      return false;
   if(!Add(pUpMgButton))
      return false;

//--- coordinates up button
   x1=INDENT_LEFT+2.6*(WIDTH_DEFAULT+CONTROLS_GAP_X);
   y1=int(0.5*INDENT_TOP)+3*(HEIGHT_DEFAULT+CONTROLS_GAP_Y);
   x2=x1+int(0.5*WIDTH_DEFAULT);
   y2=y1+HEIGHT_DEFAULT;


////--- create up button 
   if(!pDownMgButton.Create(m_chart_id,"pDownMgButton",m_subwin,x1,y1,x2,y2))
      return false;
   if(!pDownMgButton.Text("Down"))
      return false;
   if(!Add(pDownMgButton))
      return false;

   return true;
  }
//+------------------------------------------------------------------+
//| Create the checkbox for TakeProfit
//+------------------------------------------------------------------+
bool CPanelHiLoDialog::CreateTakeProfit(void)
  {
//--- checkbox take profit
   int x1=INDENT_LEFT;
   int y1=INDENT_TOP+4*(HEIGHT_DEFAULT+CONTROLS_GAP_Y);
   int x2=x1+WIDTH_DEFAULT;
   int y2=y1+HEIGHT_DEFAULT;

   if(!pCheckBoxTakeProfit.Create(m_chart_id,"pCheckBoxTakeProfit",m_subwin,x1,y1,x2,y2))
      return false;
   if(!pCheckBoxTakeProfit.Text("Profit"))
      return false;
   if(!Add(pCheckBoxTakeProfit))
      return false;

//--- edit take profit
   x1=INDENT_LEFT;
   y1=(INDENT_TOP/2)+5*(HEIGHT_DEFAULT+CONTROLS_GAP_Y);
   x2=x1+WIDTH_DEFAULT;
   y2=y1+HEIGHT_DEFAULT;

   if(!pEditTakeProfit.Create(m_chart_id,"pEditTakeProfit",m_subwin,x1,y1,x2,y2))
      return false;
   if(!Add(pEditTakeProfit))
      return false;

   pEditTakeProfit.TextAlign(ALIGN_CENTER);
   return true;
  }
//+------------------------------------------------------------------+
//| Create the checkbox for StopLoss
//+------------------------------------------------------------------+
bool CPanelHiLoDialog::CreateStopLoss(void)
  {
//--- checkbox stop loss
   int x1=INDENT_LEFT+(WIDTH_DEFAULT+CONTROLS_GAP_X);
   int y1=INDENT_TOP+4*(HEIGHT_DEFAULT+CONTROLS_GAP_Y);
   int x2=x1+WIDTH_DEFAULT;
   int y2=y1+HEIGHT_DEFAULT;

   if(!pCheckBoxStopLoss.Create(m_chart_id,"pCheckBoxStopLoss",m_subwin,x1,y1,x2,y2))
      return false;
   if(!pCheckBoxStopLoss.Text("Loss"))
      return false;
   if(!Add(pCheckBoxStopLoss))
      return false;

//--- edit take profit
   x1=INDENT_LEFT+(WIDTH_DEFAULT+CONTROLS_GAP_Y);
   y1=(INDENT_TOP/2)+5*(HEIGHT_DEFAULT+CONTROLS_GAP_Y);
   x2=x1+WIDTH_DEFAULT;
   y2=y1+HEIGHT_DEFAULT;

   if(!pEditStopLoss.Create(m_chart_id,"pEditStopLoss",m_subwin,x1,y1,x2,y2))
      return false;
   if(!Add(pEditStopLoss))
      return false;

   pEditStopLoss.TextAlign(ALIGN_CENTER);
   return true;
  }
//+------------------------------------------------------------------+
//| Create the UpdateTpSlButton
//+------------------------------------------------------------------+
bool CPanelHiLoDialog::CreateUpdateTpSlButton(void)
  {
//-- button
   int x1=INDENT_LEFT+2*(WIDTH_DEFAULT+CONTROLS_GAP_X);
   int y1=INDENT_TOP+4*(HEIGHT_DEFAULT+CONTROLS_GAP_Y);
   int x2=x1+WIDTH_DEFAULT;
   int y2=y1+HEIGHT_DEFAULT;

   if(!pUpdateTpSlButton.Create(m_chart_id,"pUpdateTpSlButton",m_subwin,x1,y1,x2,y2))
      return false;
   if(!pUpdateTpSlButton.Text("Update TP/SL"))
      return false;
   if(!Add(pUpdateTpSlButton))
      return false;
   return true;
  }
//+------------------------------------------------------------------+
//| Event Buy CheckBox
//+------------------------------------------------------------------+
void CPanelHiLoDialog::OnClickBuyCheckBox(void)
  {

  }
//+------------------------------------------------------------------+
//| Event Sell CheckBox
//+------------------------------------------------------------------+
void CPanelHiLoDialog::OnClickSellCheckBox(void)
  {

  }
//+------------------------------------------------------------------+
//| Event Close Profit Loss CheckBox
//+------------------------------------------------------------------+
void CPanelHiLoDialog::OnClickClosePLCheckBox(void)
  {

  }
//+------------------------------------------------------------------+
//| Event Start Button
//+------------------------------------------------------------------+
void CPanelHiLoDialog::OnClickStartButton(void)
  {
   HiLoTrades.tradeStart(pBuyCheckBox.Checked(),pSellCheckBox.Checked());
  }
//+------------------------------------------------------------------+
//| Event Stop Button
//+------------------------------------------------------------------+
void CPanelHiLoDialog::OnClickStopButton(void)
  {
   HiLoTrades.tradeStop(pBuyCheckBox.Checked(),pSellCheckBox.Checked());
  }
//+------------------------------------------------------------------+
//| Event Reset To Defaults Button
//+------------------------------------------------------------------+
void CPanelHiLoDialog::OnClickResetDefaultsButton(void)
  {
   initToDefaults();
  }
//+------------------------------------------------------------------+
//| Event Change Edit Volume 
//+------------------------------------------------------------------+
void CPanelHiLoDialog::OnChangeEditVolume(void)
  {
   int v=StringToInteger(pEditVolume.Text());
   if(v!=currentVolume)
     {
      currentVolume=v;
      nextVolume=currentVolume*2;

      loadVolumesToEditBox();
     }
  }
//+------------------------------------------------------------------+
//| Event Change Button UpdateTpSl                                                              |
//+------------------------------------------------------------------+
void CPanelHiLoDialog::OnChangeButtonUpdateTpSl(void)
  {
   HiLoTrades.modifyBuyPosition();
   HiLoTrades.modifySellPosition();
  }
//+------------------------------------------------------------------+
//| Event Up for Matingale Button
//+------------------------------------------------------------------+
void CPanelHiLoDialog::OnClickUpMgButton(void)
  {
   upMartingale();
  }
//+------------------------------------------------------------------+
//| Event Down for Matingale Button
//+------------------------------------------------------------------+
void CPanelHiLoDialog::OnClickDownMgButton(void)
  {
   downMartingale();
  }
//+------------------------------------------------------------------+
//| Load volumes to Edit Box
//+------------------------------------------------------------------+
void CPanelHiLoDialog::loadVolumesToEditBox(void)
  {
   pEditVolume.Text(IntegerToString(currentVolume));
   pEditNextVolume.Text(IntegerToString(nextVolume));
  }
//+------------------------------------------------------------------+
//| Up the martingale
//+------------------------------------------------------------------+
void CPanelHiLoDialog::upMartingale(void)
  {
   currentVolume=currentVolume*2;
   nextVolume=currentVolume*2;

   loadVolumesToEditBox();
  }
//+------------------------------------------------------------------+
//| Down the martingale
//+------------------------------------------------------------------+
void CPanelHiLoDialog::downMartingale(void)
  {
   currentVolume=currentVolume/2;
   if(currentVolume==0)
      currentVolume=1;
   nextVolume=currentVolume*2;

   loadVolumesToEditBox();
  }
//+------------------------------------------------------------------+
