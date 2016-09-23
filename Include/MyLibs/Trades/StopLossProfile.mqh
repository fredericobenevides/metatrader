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
   CPositionOrder   *m_position_order;
   CList            *m_list_price_control;

   int               m_profile;
   bool              m_need_to_change;
   bool              m_using_stop_profile;

public:
                     CStopLossProfile(int profile,CPositionOrder *positionOrder);
                    ~CStopLossProfile();

   void              VerifyIfNeedToChangeStopLoss(double currentMarketPrice);
   void              StopLossProfileWasPlaced(void);
   void              StopLossProfileWasRemoved(void);

   CPriceControl    *CurrentEnableProfile();

   bool              IsNeedToChange() { return m_need_to_change; }
   bool              IsUsingStopProfile() { return m_using_stop_profile; }

   void              EnableAllProfiles();
   void              DisableFirstEnabledProfile();

   void              Restart();
   void              ResetToDefault();

private:
   void              InitProfiles();
  };
//+------------------------------------------------------------------+
//| Constructor
//+------------------------------------------------------------------+
CStopLossProfile::CStopLossProfile(int profile,CPositionOrder *positionOrder)
  {
   m_list_price_control=new CList;

   m_profile=profile;
   m_position_order=positionOrder;

   m_need_to_change=false;
   m_using_stop_profile=false;

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
  }
//+------------------------------------------------------------------+
//| Verify if the current market price is at least equal to 
//| current profile price to change the stop loss value
//+------------------------------------------------------------------+
void CStopLossProfile::VerifyIfNeedToChangeStopLoss(double currentMarketPrice)
  {
   if(m_need_to_change)
      return;

   if(m_profile==0)
      return;

   CPriceControl *currentProfile=CurrentEnableProfile();
   if(currentProfile==NULL)
      return;

   double openPrice=m_position_order.Price();

   double diffPrice=0;
   if(m_position_order.IsOnBuyTrade())
      diffPrice=currentMarketPrice-openPrice;
   else
      diffPrice=openPrice-currentMarketPrice;

   if(diffPrice>=0 && diffPrice>=currentProfile.PointsToChange())
      m_need_to_change=true;
  }
//+------------------------------------------------------------------+
//| Inform that stop loss profile was placed on market
//+------------------------------------------------------------------+
void CStopLossProfile::StopLossProfileWasPlaced(void)
  {
   if(m_need_to_change)
     {
      DisableFirstEnabledProfile();
      m_need_to_change=false;
      m_using_stop_profile=true;
     }
  }
//+------------------------------------------------------------------+
//| Inform that stop loss profile was removed from market
//+------------------------------------------------------------------+
void CStopLossProfile::StopLossProfileWasRemoved(void)
  {
   if(m_using_stop_profile)
      m_using_stop_profile=false;
  }
//+------------------------------------------------------------------+
//| Return the current enable profile
//+------------------------------------------------------------------+
CPriceControl *CStopLossProfile::CurrentEnableProfile()
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
//| Enable all profiles
//+------------------------------------------------------------------+
void CStopLossProfile::EnableAllProfiles(void)
  {
   for(int i=0;i<m_list_price_control.Total();i++)
     {
      CPriceControl *p=m_list_price_control.GetNodeAtIndex(i);
      p.Enable();
     }
  }
//+------------------------------------------------------------------+
//| Disable the first found profile
//+------------------------------------------------------------------+
void CStopLossProfile::DisableFirstEnabledProfile()
  {
   for(int i=0;i<m_list_price_control.Total();i++)
     {
      CPriceControl *p=m_list_price_control.GetNodeAtIndex(i);
      if(p.IsEnable())
        {
         p.Disable();
         return;
        }
     }
  }
//+------------------------------------------------------------------+
//| Restart profile to default
//+------------------------------------------------------------------+
void CStopLossProfile::Restart()
  {
   ResetToDefault();
  }
//+------------------------------------------------------------------+
//| Reset the profile to default
//+------------------------------------------------------------------+
void CStopLossProfile::ResetToDefault()
  {
   EnableAllProfiles();
   m_need_to_change=false;
   m_using_stop_profile=false;
  }
//+------------------------------------------------------------------+
//| Init the profiles
//+------------------------------------------------------------------+
void CStopLossProfile::InitProfiles()
  {
   if(m_profile==1)
     {
      CPriceControl *p=new CPriceControl();
      p.Init(80,120);
      m_list_price_control.Add(p);

      p=new CPriceControl();
      p.Init(120,0);
      m_list_price_control.Add(p);
     }
  }
//+------------------------------------------------------------------+
