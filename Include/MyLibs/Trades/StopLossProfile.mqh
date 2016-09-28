//+------------------------------------------------------------------+
//|                                                StopLossOrder.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Frederico Benevides"
#property link      "fredbene@gmail.com"

#include <Arrays\List.mqh>

#include <MyLibs\Trades\PositionOrder.mqh>
#include <MyLibs\Trades\PriceControl.mqh>
//+------------------------------------------------------------------+
//| Class to map take profit order
//+------------------------------------------------------------------+
class CStopLossProfile
  {
private:
   CList            *m_list_price_control;

   int               m_profile;

   CPriceControl    *m_last_profile_calculated;

public:
                     CStopLossProfile(int profile);
                    ~CStopLossProfile();

   bool              VerifyIfNeedToChangeStopLoss(bool isOnBuyTrade,double positionOrderPrice,double currentMarketPrice);
   bool              VerifyIfExistEnabledProfiles();
   void              SetProfileAsUsed() { m_last_profile_calculated=NULL; }

   CPriceControl    *LastProfileCalculated();

   void              Restart();
   void              ResetToDefault();

private:
   void              InitProfiles();

   CPriceControl    *firstEnabledProfile();
  };
//+------------------------------------------------------------------+
//| Constructor
//+------------------------------------------------------------------+
CStopLossProfile::CStopLossProfile(int profile)
  {
   m_list_price_control=new CList;

   m_profile=profile;
   InitProfiles();
  }
//+------------------------------------------------------------------+
//| Destructor
//+------------------------------------------------------------------+
CStopLossProfile::~CStopLossProfile()
  {
   for(int i=0;i<m_list_price_control.Total();i++)
     {
      CPriceControl *p=m_list_price_control.GetNodeAtIndex(i);
      delete p;
     }
   delete m_list_price_control;
  }
//+------------------------------------------------------------------+
//| Verify if the current market price is at least equal to 
//| current profile price to change the stop loss value
//+------------------------------------------------------------------+
bool CStopLossProfile::VerifyIfNeedToChangeStopLoss(bool isOnBuyTrade,double positionOrderPrice,double currentMarketPrice)
  {
   bool result=false;

   if(m_profile==0)
      return false;

   CPriceControl *currentProfile=firstEnabledProfile();
   if(currentProfile==NULL)
      return false;

   double openPrice=positionOrderPrice;

   double diffPrice=0;
   if(isOnBuyTrade)
      diffPrice=currentMarketPrice-openPrice;
   else
      diffPrice=openPrice-currentMarketPrice;

   if(diffPrice>=0 && diffPrice>=currentProfile.PointsToChange())
     {
      currentProfile.Disable();
      m_last_profile_calculated=currentProfile;
      return true;
     }

   return false;
  }
//+------------------------------------------------------------------+
//| Verify if there is at least one enabled profile;
//+------------------------------------------------------------------+
bool CStopLossProfile::VerifyIfExistEnabledProfiles()
  {
   for(int i=0;i<m_list_price_control.Total();i++)
     {
      CPriceControl *p=m_list_price_control.GetNodeAtIndex(i);
      if(p.IsEnable())
         return true;
     }

   return false;
  }
//+------------------------------------------------------------------+
//| Return the current enable profile
//+------------------------------------------------------------------+
CPriceControl *CStopLossProfile::LastProfileCalculated(void)
  {
   return m_last_profile_calculated;
  }
//+------------------------------------------------------------------+
//| Init the profiles
//+------------------------------------------------------------------+
void CStopLossProfile::InitProfiles()
  {
   if(m_profile==1)
     {
      CPriceControl *p=new CPriceControl();
      p.Init(80,-120);
      m_list_price_control.Add(p);

      p=new CPriceControl();
      p.Init(120,20);
      m_list_price_control.Add(p);
      
      p=new CPriceControl();
      p.Init(140,100);
      m_list_price_control.Add(p);
     }
  }
//+------------------------------------------------------------------+
//| Return the firt enabled profile
//+------------------------------------------------------------------+
CPriceControl *CStopLossProfile::firstEnabledProfile()
  {
   for(int i=0;i<m_list_price_control.Total();i++)
     {
      CPriceControl *p=m_list_price_control.GetNodeAtIndex(i);
      if(p.IsEnable())
         return p;
     }

   return NULL;
  }
//+------------------------------------------------------------------+
