//+---------------------------------------------------------------------------+
//|                                                     MyTradesOperation.mqh |
//|                                              Frederico Benevides          |
//|                                               fredbene@gmail.com          |
//+---------------------------------------------------------------------------+
#property copyright "Frederico Benevides"
#property link      "fredbene@gmail.com"
#property version   "1.00"

#include <Object.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CTradeOperation : public CObject
  {
private:
   string            m_typeDescription;

   double            m_priceOpen;
   double            m_priceClose;
   double            m_volume;
   double            m_factor;

   double            m_profit;

public:
                     CTradeOperation() {}
                    ~CTradeOperation() {}

   void calculateProfit()
     {
      int digits=(int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS);
      double point=SymbolInfoDouble(_Symbol,SYMBOL_POINT);

      if(m_typeDescription=="buy")
         m_profit=NormalizeDouble(m_priceOpen-(m_volume*point),digits);
      else
         m_profit=NormalizeDouble(m_priceOpen+(m_volume*point),digits);

      if(m_typeDescription=="buy")
         m_profit=NormalizeDouble(m_priceClose-m_priceOpen-(m_volume*point),digits);
      else
         m_profit=NormalizeDouble(m_priceClose+m_priceOpen+(m_volume*point),digits);
     }

   void typeDescription(string description)
     {
      m_typeDescription=description;
     }

   void priceOpen(double priceOpen)
     {
      m_priceOpen=priceOpen;
     }

   void priceClose(double priceClose)
     {
      m_priceClose=priceClose;
     }

   void volume(double volume)
     {
      m_volume=volume;
     }

   void factor(double factor)
     {
      m_factor=factor;
     }

   double profit()
     {
      return m_profit;
     }
  };
//+------------------------------------------------------------------+
