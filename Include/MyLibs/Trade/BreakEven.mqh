//+------------------------------------------------------------------+
//|                                                    BreakEven.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//| Class responsible to Show and Hide BreakEven
//+------------------------------------------------------------------+
class CBreakEven
  {
private:
   string            name;
public:
   void              Show(int baseVolume,double pricePerVolume);
   void              Hide(void);
  };
//+------------------------------------------------------------------+
//| Show the BreakEven
//+------------------------------------------------------------------+
void CBreakEven::Show(int baseVolume,double pricePerVolume=0)
  {
   double breakEvenPrice=MyTrade.CalculateBreakEvenWithLastDeal(baseVolume,pricePerVolume);

   name="BreakEven";
   if(!ObjectCreate(0,name,OBJ_HLINE,0,0,breakEvenPrice))
     {
      Print(__FUNCTION__,
            ": failed to create a horizontal line! Error code = ",GetLastError());
     }
   ObjectSetInteger(0,name,OBJPROP_COLOR,clrBlueViolet);
   ObjectSetInteger(0,name,OBJPROP_BACK,true);
   ChartRedraw();
  }
//+------------------------------------------------------------------+
//| Hide the BreakEven
//+------------------------------------------------------------------+
void CBreakEven::Hide()
  {
   ObjectDelete(0,name);
   ChartRedraw();
  }
//+------------------------------------------------------------------+
