//+------------------------------------------------------------------+
//|                                                     MdJumper.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Frederico Benevides"
#property link      "fredbene@gmail.com"

#include <Object.mqh>
//+------------------------------------------------------------------+
//| Class To Map the Month and Day to Jumper
//+------------------------------------------------------------------+
class CMdJumper : public CObject
  {
   int               m_year;
   int               m_month;
   int               m_day;

public:
   void              Add(int year,int month,int day);
   int               Year();
   int               Month();
   int               Day();
  };
//+------------------------------------------------------------------+
//| Add year, month and day
//+------------------------------------------------------------------+
void CMdJumper::Add(int year,int month,int day)
  {
   m_year=year;
   m_month=month;
   m_day=day;
  }
//+------------------------------------------------------------------+
//| Return the year
//+------------------------------------------------------------------+
int CMdJumper::Year()
  {
   return m_year;
  }
//+------------------------------------------------------------------+
//| Return the month
//+------------------------------------------------------------------+
int CMdJumper::Month()
  {
   return m_month;
  }
//+------------------------------------------------------------------+
//| Return the Day
//+------------------------------------------------------------------+
int CMdJumper::Day()
  {
   return m_day;
  }
//+------------------------------------------------------------------+
