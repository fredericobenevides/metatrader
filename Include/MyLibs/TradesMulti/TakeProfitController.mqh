//+------------------------------------------------------------------+
//|                                         TakeProfitController.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Frederico Benevides"
#property link      "fredbene@gmail.com"

#include <Arrays\List.mqh>

#include <MyLibs\Trades\TakeProfitOrder.mqh>
//+------------------------------------------------------------------+
//| Controller of Take Profit Orders
//+------------------------------------------------------------------+
class CTakeProfitController
  {
   CTradesService   *m_trades_service;
   string            m_trade_name;
   CPositionOrder   *m_position_order;

   CList            *m_list_take_profit_orders;
   int               m_take_profit_to_create;
   int               m_take_profit_to_delete;

   double            m_take_profit_points;
   int               m_max_take_profit_operations;
   int               m_count_take_profit_operations;

public:
                     CTakeProfitController(string tradeName,CPositionOrder *positionOrder);
                    ~CTakeProfitController();

   void              InitTrade(double takeProfitPoints,int maxTakeProfitOperations);

   void              AddTradesService(CTradesService *tradesService) { m_trades_service=tradesService; }

   double           TakeProfitPoints() { return m_take_profit_points; }
   CTakeProfitOrder *TakeProfitOrder();
   CTakeProfitOrder *TakeProfitOrderByTicket(ulong ticket);

   void              SetToCreateNewTakeProfit() { m_take_profit_to_create+=1; }
   void              SetToDeleteAllTakeProfit();

   bool              VerifyIfPlaceTakeProfitOrder();
   bool              VerifyIfDeleteTakeProfitOrder();
   void              ExecutedDeleteOperationByMetatrader(CTakeProfitOrder *takeProfitOrder);
   bool              VerifyIfHasOpenTakeProfit() { return verifyIfNeedToDeleteTakeProfit(); }
   bool              VerifyIfHasOrders() { return m_list_take_profit_orders.Total()>0; }

   //bool              VerifyIfThereIsAnyTicketLoaded();
   bool              VerifyIfLoadTakeProfitTicket();

   void              ResetToDefault();
private:

   bool              isValidToPlaceOrder();

   bool              verifyIfNeedToCreateNewTakeProfit() { return m_take_profit_to_create>m_list_take_profit_orders.Total(); }
   bool              verifyIfNeedToDeleteTakeProfit() { return m_take_profit_to_delete>0; }

   CTakeProfitOrder *createTakeProfitOrder();
   double            calculateTakeProfitPrice(CTakeProfitOrder *takeProfitOrder);

   void              takeProfitOrderWasPlaced(CTakeProfitOrder *takeProfitOrder);
   void              takeProfitOrderIsNotPlacedAnymore(CTakeProfitOrder *takeProfitOrder);
   void              takeProfitOrderIsNotPlacedAnymoreByMetatrader(CTakeProfitOrder *takePofitOrder);

public:
   // max take profit points
   string            MaxTakeProfitStatus();

   void              UpdateTakeProfitOperations();
   void              DisablePositionOnMaxTakeProfitOperations();
  };
//+------------------------------------------------------------------+
//| Constructor
//+------------------------------------------------------------------+
CTakeProfitController::CTakeProfitController(string tradeName,CPositionOrder *positionOrder)
  {
   m_trade_name=tradeName;
   m_position_order=positionOrder;
   m_list_take_profit_orders=new CList;
  }
//+------------------------------------------------------------------+
//| Destructor
//+------------------------------------------------------------------+
CTakeProfitController::~CTakeProfitController()
  {
   m_list_take_profit_orders.Clear();
   delete m_list_take_profit_orders;
  }
//+------------------------------------------------------------------+
//| Init CTrades
//+------------------------------------------------------------------+
CTakeProfitController::InitTrade(double stopLossPoints,int maxTakeProfitOperations)
  {
   m_take_profit_points=stopLossPoints;
   m_max_take_profit_operations=maxTakeProfitOperations;
  }
//+------------------------------------------------------------------+
//| Return the last placed take profit order
//+------------------------------------------------------------------+
CTakeProfitOrder *CTakeProfitController::TakeProfitOrder()
  {
   for(int i=m_list_take_profit_orders.Total()-1; i>=0; i--)
     {
      CTakeProfitOrder *takeProfitOrder=m_list_take_profit_orders.GetNodeAtIndex(i);
      if(takeProfitOrder.IsOrderWasPlaced())
         return takeProfitOrder;
     }

   return NULL;
  }
//+------------------------------------------------------------------+
//| Return the take profit order by ticket
//+------------------------------------------------------------------+
CTakeProfitOrder *CTakeProfitController::TakeProfitOrderByTicket(ulong ticket)
  {
   for(int i=0; i<m_list_take_profit_orders.Total(); i++)
     {
      CTakeProfitOrder *takeProfitOrder=m_list_take_profit_orders.GetNodeAtIndex(i);
      if(takeProfitOrder.IsTicketEqual(ticket))
         return takeProfitOrder;
     }

   return NULL;
  }
//+------------------------------------------------------------------+
//| Set to delete all take profit
//+------------------------------------------------------------------+
void CTakeProfitController::SetToDeleteAllTakeProfit()
  {
   for(int i=0; i<m_list_take_profit_orders.Total(); i++)
     {
      CTakeProfitOrder *takeProfitOrder=m_list_take_profit_orders.GetNodeAtIndex(i);
      if(takeProfitOrder.IsOrderWasPlaced())
         m_take_profit_to_delete+=1;
     }
  }
//+------------------------------------------------------------------+
//| Place take profit Order
//+------------------------------------------------------------------+
bool CTakeProfitController::VerifyIfPlaceTakeProfitOrder()
  {
   if(!isValidToPlaceOrder())
      return false;

   CTakeProfitOrder *takeProfitOrder=createTakeProfitOrder();
   string comentOpenOperation=takeProfitOrder.BuySellOpenName();

   double positionVolume=m_position_order.Volume();
   double takeProfitPrice=calculateTakeProfitPrice(takeProfitOrder);

   PrintFormat("%s will be executed the take profit with price: %.2f",comentOpenOperation,takeProfitPrice);

   bool result=false;
   if(m_trades_service.ExecuteBuySellLimit(m_position_order.IsOnBuyTrade(),positionVolume,takeProfitPrice,comentOpenOperation))
     {
      PrintFormat("%s operation executed: true",comentOpenOperation);
      takeProfitOrderWasPlaced(takeProfitOrder);
      takeProfitOrder.AddComentOpenExecutedOperation(m_trades_service.LastCommentOperation());

      result=true;
     }
   else
      PrintFormat("%s operation executed: false",comentOpenOperation);

   return result;
  }
//+------------------------------------------------------------------+
//| Delete the take profit ticket
//+------------------------------------------------------------------+
bool CTakeProfitController::VerifyIfDeleteTakeProfitOrder()
  {
   bool result=false;

   if(verifyIfNeedToDeleteTakeProfit())
     {
      for(int i=0; i<m_list_take_profit_orders.Total();i++)
        {
         CTakeProfitOrder *takeProfitOrder=m_list_take_profit_orders.GetNodeAtIndex(i);
         if(takeProfitOrder.IsOrderWasPlaced())
           {
            string commentCloseOperation=takeProfitOrder.BuySellCloseName();
            ulong ticket=takeProfitOrder.Ticket();
            if(m_trades_service.ExecuteOrderDelete(ticket,commentCloseOperation))
              {
               PrintFormat("%s operation executed: true",commentCloseOperation);

               if(takeProfitOrder.IsBuyStopLoss())
                  m_trades_service.PlaySellSound();
               if(takeProfitOrder.IsSellStopLoss())
                  m_trades_service.PlayBuySound();

               takeProfitOrderIsNotPlacedAnymore(takeProfitOrder);
               result=true;
              }
            else
               PrintFormat("%s operation executed: false",commentCloseOperation);
           }
        }
     }
   return result;
  }
//+------------------------------------------------------------------+
//| Find the takeProfitOrder to inform that it was removed by metatrader
//+------------------------------------------------------------------+
void CTakeProfitController::ExecutedDeleteOperationByMetatrader(CTakeProfitOrder *takeProfitOrder)
  {
// Order still exist on market, the take profit was not removed by metatrader
   if(takeProfitOrder==NULL)
      SetToDeleteAllTakeProfit();
   else
     {
      // take profit was removed by metatrader.
      takeProfitOrderIsNotPlacedAnymoreByMetatrader(takeProfitOrder);

      m_position_order.ResetNextVolumeToInitialVolume();

      UpdateTakeProfitOperations();
      DisablePositionOnMaxTakeProfitOperations();
     }
  }
//+------------------------------------------------------------------+
//| Try to load take profit ticket
//+------------------------------------------------------------------+
bool CTakeProfitController::VerifyIfLoadTakeProfitTicket()
  {
   bool ticketLoaded=false;

   if(m_position_order.IsOnTradeOperation())
     {
      for(int i=0; i<m_list_take_profit_orders.Total();i++)
        {
         CTakeProfitOrder *takeProfitOrder=m_list_take_profit_orders.GetNodeAtIndex(i);
         if(takeProfitOrder.IsOrderWasPlaced() && !takeProfitOrder.IsTicketLoaded())
           {
            string commentOperation=takeProfitOrder.CommentOpenExecutedOperation();
            ulong ticket=m_trades_service.TryToLoadOrderTicket(commentOperation);
            if(ticket!=0)
              {
               takeProfitOrder.AddTicket(ticket);
               ticketLoaded=true;
               break;
              }
           }
        }
     }

   return ticketLoaded;
  }
//+------------------------------------------------------------------+
//| Reset everything to Default
//+------------------------------------------------------------------+
void CTakeProfitController::ResetToDefault()
  {
   SetToDeleteAllTakeProfit();
   if(verifyIfNeedToDeleteTakeProfit())
      return;

   m_take_profit_to_create=0;
   m_take_profit_to_delete=0;

   m_list_take_profit_orders.Clear();
   delete m_list_take_profit_orders;
   m_list_take_profit_orders=new CList;
  }
//+------------------------------------------------------------------+
//| Verify if is valid to place a take profit order
//+------------------------------------------------------------------+
bool CTakeProfitController::isValidToPlaceOrder()
  {
   if(m_take_profit_points==0.0)
      return false;

   if(!m_position_order.IsOrderPlaced())
      return false;

   if(!m_position_order.IsOnTradeOperation())
      return false;

   if(!verifyIfNeedToCreateNewTakeProfit())
      return false;

   return true;
  }
//+------------------------------------------------------------------+
//| Create the take profit order
//+------------------------------------------------------------------+
CTakeProfitOrder *CTakeProfitController::createTakeProfitOrder()
  {
   int takeProfitIndex=m_list_take_profit_orders.Total()+1;
   CTakeProfitOrder *takeProfitOrder=new CTakeProfitOrder(m_trade_name,takeProfitIndex,m_position_order);

   m_list_take_profit_orders.Add(takeProfitOrder);
   return takeProfitOrder;
  }
//+------------------------------------------------------------------+
//| Calculate the take profit price
//+------------------------------------------------------------------+
double CTakeProfitController::calculateTakeProfitPrice(CTakeProfitOrder *takeProfitOrder)
  {
   double openPrice=m_position_order.Price();
   double takeProfitPrice=0;

   double pointsToStop=m_take_profit_points;

   if(m_position_order.IsOnBuyTrade())
     {
      takeProfitPrice=openPrice+pointsToStop;
      takeProfitOrder.SetAsBuyStopLoss();
     }
   else
     {
      takeProfitPrice=openPrice-pointsToStop;
      takeProfitOrder.SetAsSellStopLoss();
     }

   takeProfitOrder.AddStopLossPrice(takeProfitPrice);
   return takeProfitPrice;
  }
//+------------------------------------------------------------------+
//| Inform that take profit was placed
//+------------------------------------------------------------------+
void CTakeProfitController::takeProfitOrderWasPlaced(CTakeProfitOrder *takeProfitOrder)
  {
   takeProfitOrder.SetOrderAsPlaced();
  }
//+------------------------------------------------------------------+
//| Inform that take profit was placed not anymore (Was Removed)
//+------------------------------------------------------------------+
void CTakeProfitController::takeProfitOrderIsNotPlacedAnymore(CTakeProfitOrder *takeProfitOrder)
  {
   m_take_profit_to_delete-=1;
   if(m_take_profit_to_delete<0)
      m_take_profit_to_delete=0;

   takeProfitOrder.SetOrderAsNotPlaced();
//takeProfitOrder.RemoveTicket();
  }
//+------------------------------------------------------------------+
//| Inform that take profit was placed not anymore by metatrader (Was Removed By metatrader)
//+------------------------------------------------------------------+
void CTakeProfitController::takeProfitOrderIsNotPlacedAnymoreByMetatrader(CTakeProfitOrder *takeProfitOrder)
  {
   takeProfitOrder.SetOrderAsNotPlaced();
//takeProfitOrder.RemoveTicket();
  }
//+------------------------------------------------------------------+
//| Returns the Max Take Profit Status
//+------------------------------------------------------------------+
string CTakeProfitController::MaxTakeProfitStatus()
  {
   string s=IntegerToString(m_count_take_profit_operations);
   s += "/";
   s += IntegerToString(m_max_take_profit_operations);

   return s;
  }
//+------------------------------------------------------------------+
//| Update the Count of take profit operations
//+------------------------------------------------------------------+
void CTakeProfitController::UpdateTakeProfitOperations()
  {
   m_count_take_profit_operations+=1;
  }
//+------------------------------------------------------------------+
//| Disable Position Order on Max take profit operations
//+------------------------------------------------------------------+
void CTakeProfitController::DisablePositionOnMaxTakeProfitOperations()
  {
   if(m_count_take_profit_operations>=m_max_take_profit_operations)
      m_position_order.DisableTrade();
  }
//+------------------------------------------------------------------+
