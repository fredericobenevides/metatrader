//+------------------------------------------------------------------+
//|                                               obj_vline_fred.mq5 |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {

//long chartId=ChartID();
   long chartId=0;
   string name="teste";

   int bars=(int)ChartGetInteger(0,CHART_VISIBLE_BARS);
   datetime date[];
   ArrayResize(date,bars);
   ResetLastError();
   if(CopyTime(Symbol(),Period(),0,bars,date)==-1)
     {
      Print("Failed to copy time values! Error code = ",GetLastError());
      return;
     }

   if(!createVLine(chartId,name,date[0]))
     {
      return;
     }
   ChartRedraw();
   Sleep(1000);

   for(int i=0;i<58;i++)
     {
      if(!moveVLine(chartId,name,date[i]))
        {
         return;
        }
        Sleep(30);
     }

   deleteVLine(chartId,name);
   ChartRedraw();
   Sleep(5000);
  }

//+------------------------------------------------------------------+
//| Create a VLine                                                                  |
//+------------------------------------------------------------------+
bool createVLine(long charId,string name,datetime time=0)
  {
   ResetLastError();
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(!ObjectCreate(charId,name,OBJ_VLINE,0,time,0))
     {
      Print(__FUNCTION__,": Não foi possível criar o gráfico. Erro: ",GetLastError());
      return false;
        } else {
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      Comment("Foi criado o gráfico");
     }

   ObjectSetInteger(charId,name,OBJPROP_WIDTH,3);
   ObjectSetInteger(charId,name,OBJPROP_STYLE,STYLE_DASHDOTDOT);
   ObjectSetInteger(charId,name,OBJPROP_COLOR,clrRed);
   ObjectSetInteger(charId,name,OBJPROP_BACK,false);

   return true;
  }
//+------------------------------------------------------------------+
//| Remove o VLine do gráfico                                                                  |
//+------------------------------------------------------------------+
bool deleteVLine(long chartId,string name)
  {
   ResetLastError();
   if(!ObjectDelete(chartId,name))
     {
      Print(__FUNCTION__,": Não foi possível criar o gráfico. Erro: ",GetLastError());
      return false;
     }

   return true;
  }
//+------------------------------------------------------------------+
//| Move o VLine no Gráfico                                                                  |
//+------------------------------------------------------------------+
bool moveVLine(long chartId,string name,datetime time=0)
  {
   ResetLastError();
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(!ObjectMove(chartId,name,0,time,0))
     {
      Print(__FUNCTION__,": Não foi possível mover o gráfico. Erro: ",GetLastError());
      return false;
        } else {
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      Comment("Foi criado o gráfico");
     }
   return true;
  }
//+------------------------------------------------------------------+
