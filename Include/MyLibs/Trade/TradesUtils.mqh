//+------------------------------------------------------------------+
//|                                                  TradesUtils.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Frederico Benevides"
#property link      "fredbene@gmail.com"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CTradesUtils
  {
public:

   double            CTradesUtils::FixPriceByTickSize(double price,bool adjustPositive=true);
  };
//+------------------------------------------------------------------+
//| Fix a value based on his tick size
//| Example:
//| Value: 50544.
//| Value: 50544 * 0.1 = 5054.4
//| Verifying: 50544 - 50540 = 4
//| Tick size: 5
//| 4 % 5 == 0? False. Fixit it.
//| 50544 + 1 = 50545 (adjust positive as true)
//| Verifying: 50545 - 50540 = 5
//| 5 % 5 == 0? True. Fixed it.
//+------------------------------------------------------------------+
double CTradesUtils::FixPriceByTickSize(double price,bool adjustPositive=true)
  {
   int digits=(int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS);
   double tickSize=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);

   int i=0;
   double newPrice=price;
   double mod=0;

// zero the decimal: 50544 = 5054.4 = 5054 = 50540
   double p2=NormalizeDouble((int)(price*0.1),digits);
   p2=NormalizeDouble(p2*10,digits);

   do
     {
      if(adjustPositive)
         newPrice=NormalizeDouble((price+i),digits);
      else
         newPrice=NormalizeDouble((price-i),digits);

      double p1=NormalizeDouble(newPrice,digits);

      // calculate the mod
      mod=NormalizeDouble(p1-p2,digits); // 50544 - 50540 = 4
      mod=MathMod(mod,tickSize); // 4 % 5 = 4
      mod=NormalizeDouble(mod,digits);

      i=i+1;
     }
   while(mod!=0 && mod!=tickSize);

   return newPrice;
  }
//+------------------------------------------------------------------+
