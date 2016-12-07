//+------------------------------------------------------------------+
//|                                                StopLossOrder.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Frederico Benevides"
#property link      "fredbene@gmail.com"

#include <Object.mqh>
//+------------------------------------------------------------------+
//| Control the Stop Loss Price
//+------------------------------------------------------------------+
class CPriceControl : public CObject
  {
private:
   bool              m_enable;

   double            m_points_to_change;
   double            m_new_points;

public:
                     CPriceControl();
   void              Init(double priceToChange,double newPrice);

   double            PointsToChange() { return m_points_to_change; }
   double            NewPoints() { return m_new_points; }

   void              Enable() { m_enable=true; }
   void              Disable() { m_enable=false; }
   bool              IsEnable() { return m_enable; }
  };
//+------------------------------------------------------------------+
//| Constructor
//+------------------------------------------------------------------+
CPriceControl::CPriceControl()
  {
  }
//+------------------------------------------------------------------+
//| Init
//+------------------------------------------------------------------+
void CPriceControl::Init(double pointsToChange,double newPoints)
  {
   m_enable=true;
   m_points_to_change=pointsToChange;
   m_new_points=newPoints;
  }
//+------------------------------------------------------------------+
