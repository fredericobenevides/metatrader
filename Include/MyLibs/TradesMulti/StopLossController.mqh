//+------------------------------------------------------------------+
//|                                           StopLossController.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Frederico Benevides"
#property link      "fredbene@gmail.com"

#include <Arrays\List.mqh>

#include <MyLibs\Trades\StopLossOrder.mqh>

#include <MyLibs\Trades\StopLossProfile.mqh>
//+------------------------------------------------------------------+
//| Controller of Stop Loss Orders
//+------------------------------------------------------------------+
class CStopLossController
  {
   CTradesService   *m_trades_service;
   string            m_trade_name;
   CPositionOrder   *m_position_order;

   CList            *m_list_stop_loss_orders;
   int               m_stops_to_create;
   int               m_stops_to_delete;

   double            m_stop_loss_points;
   int               m_stop_loss_profile;
   CStopLossProfile *m_stop_loss_object_profile;

public:
                     CStopLossController(string tradeName,CPositionOrder *positionOrder);
                    ~CStopLossController();

   void              InitTrade(double stopLossPoints,int stopLossProfile);

   void              AddTradesService(CTradesService *tradesService) { m_trades_service=tradesService; }

   double           StopLossPoints() { return m_stop_loss_points; }
   CStopLossOrder   *StopLossOrder();
   CStopLossOrder   *StopLossOrderByTicket(ulong ticket);

   void              SetToCreateNewStop() { m_stops_to_create+=1; }
   void              SetToDeleteAllStopLoss();

   bool              VerifyIfPlaceStopLossOrder();
   bool              VerifyIfDeleteStopLossOrder();
   void              ExecutedDeleteOperationByMetatrader(CStopLossOrder *stopLossOrder);
   bool              VerifyIfHasOpenStop() { return verifyIfNeedToDeleteStop(); }
   bool              VerifyIfHasOrders() { return m_list_stop_loss_orders.Total()>0; }

   bool              VerifyIfLoadStopLossTicket();

   void              ResetToDefault();

private:

   bool              isValidToPlaceOrder();

   bool              verifyIfNeedToCreateNewStop() { return m_stops_to_create>m_list_stop_loss_orders.Total(); }
   bool              verifyIfNeedToDeleteStop() { return m_stops_to_delete>0; }

   CStopLossOrder   *createStopLossOrder();
   double            calculateStopLossPrice(CStopLossOrder *stopLossOrder);

   void              stopLossOrderWasPlaced(CStopLossOrder *stopLossOrder);
   void              stopLossOrderIsNotPlacedAnymore(CStopLossOrder *stopLossOrder);
   void              stopLossOrderIsNotPlacedAnymoreByMetatrader(CStopLossOrder *stopLossOrder);

public:

   bool              VerifyIfHasProfileActivated() { return m_stop_loss_profile>0; }
   bool              VerifyIfChangeStopLossBasedOnProfile(double currentMarketPrice);

private:

   bool              VerifyIfIsValidToChangeStopBasedOnProfile();
   bool              VerifyIfIsUsingStopBasedOnProfile();

   void              ResetStopLossProfileToDefault();
  };
//+------------------------------------------------------------------+
//| Constructor
//+------------------------------------------------------------------+
CStopLossController::CStopLossController(string tradeName,CPositionOrder *positionOrder)
  {
   m_trade_name=tradeName;
   m_position_order=positionOrder;
   m_list_stop_loss_orders=new CList;
  }
//+------------------------------------------------------------------+
//| Destructor
//+------------------------------------------------------------------+
CStopLossController::~CStopLossController()
  {
   m_list_stop_loss_orders.Clear();
   delete m_list_stop_loss_orders;
  }
//+------------------------------------------------------------------+
//| Init CTrades
//+------------------------------------------------------------------+
CStopLossController::InitTrade(double stopLossPoints,int stopLossProfile)
  {
   m_stop_loss_points=stopLossPoints;

   m_stop_loss_profile=stopLossProfile;
   ResetStopLossProfileToDefault();
  }
//+------------------------------------------------------------------+
//| Return the last placed stop loss order
//+------------------------------------------------------------------+
CStopLossOrder *CStopLossController::StopLossOrder()
  {
   for(int i=m_list_stop_loss_orders.Total()-1; i>=0; i--)
     {
      CStopLossOrder *stopLossOrder=m_list_stop_loss_orders.GetNodeAtIndex(i);
      if(stopLossOrder.IsOrderWasPlaced())
         return stopLossOrder;
     }

   return NULL;
  }
//+------------------------------------------------------------------+
//| Return the stop loss order by ticket
//+------------------------------------------------------------------+
CStopLossOrder *CStopLossController::StopLossOrderByTicket(ulong ticket)
  {
   for(int i=0; i<m_list_stop_loss_orders.Total(); i++)
     {
      CStopLossOrder *stopLossOrder=m_list_stop_loss_orders.GetNodeAtIndex(i);
      if(stopLossOrder.IsTicketEqual(ticket))
         return stopLossOrder;
     }

   return NULL;
  }
//+------------------------------------------------------------------+
//| Set to delete all stop loss
//+------------------------------------------------------------------+
void CStopLossController::SetToDeleteAllStopLoss()
  {
   for(int i=0; i<m_list_stop_loss_orders.Total(); i++)
     {
      CStopLossOrder *stopLossOrder=m_list_stop_loss_orders.GetNodeAtIndex(i);
      if(stopLossOrder.IsOrderWasPlaced())
         m_stops_to_delete+=1;
     }
  }
//+------------------------------------------------------------------+
//| Place Stop Loss Order
//+------------------------------------------------------------------+
bool CStopLossController::VerifyIfPlaceStopLossOrder()
  {
   if(!isValidToPlaceOrder())
      return false;

   CStopLossOrder *stopLossOrder=createStopLossOrder();
   string comentOpenOperation=stopLossOrder.BuySellOpenName();

   double positionVolume=m_position_order.Volume();
   double stopLossPrice=calculateStopLossPrice(stopLossOrder);

   if(!VerifyIfIsUsingStopBasedOnProfile())
      PrintFormat("%s will be executed the stop loss with price: %.2f",comentOpenOperation,stopLossPrice);
   else
      PrintFormat("%s will change the stop loss based on profile with price: %.2f",comentOpenOperation,stopLossPrice);

   bool result=false;
   if(m_trades_service.ExecuteBuySellStop(m_position_order.IsOnBuyTrade(),positionVolume,stopLossPrice,comentOpenOperation))
     {
      PrintFormat("%s operation executed: true",comentOpenOperation);
      stopLossOrderWasPlaced(stopLossOrder);
      stopLossOrder.AddComentOpenExecutedOperation(m_trades_service.LastCommentOperation());

      if(VerifyIfIsUsingStopBasedOnProfile())
         m_stop_loss_object_profile.SetProfileAsUsed();

      result=true;
     }
   else
      PrintFormat("%s operation executed: false",comentOpenOperation);

   return result;
  }
//+------------------------------------------------------------------+
//| Delete the stop loss ticket
//+------------------------------------------------------------------+
bool CStopLossController::VerifyIfDeleteStopLossOrder()
  {
   bool result=false;

   if(verifyIfNeedToDeleteStop())
     {
      for(int i=0; i<m_list_stop_loss_orders.Total();i++)
        {
         CStopLossOrder *stopLossOrder=m_list_stop_loss_orders.GetNodeAtIndex(i);
         if(stopLossOrder.IsOrderWasPlaced())
           {
            string commentCloseOperation=stopLossOrder.BuySellCloseName();
            ulong ticket=stopLossOrder.Ticket();
            if(m_trades_service.ExecuteOrderDelete(ticket,commentCloseOperation))
              {
               PrintFormat("%s operation executed: true",commentCloseOperation);

               if(stopLossOrder.IsBuyStopLoss())
                  m_trades_service.PlaySellSound();
               if(stopLossOrder.IsSellStopLoss())
                  m_trades_service.PlayBuySound();

               stopLossOrderIsNotPlacedAnymore(stopLossOrder);
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
//| Find the stopLossOrder to inform that it was removed by metatrader
//+------------------------------------------------------------------+
void CStopLossController::ExecutedDeleteOperationByMetatrader(CStopLossOrder *stopLossOrder)
  {
// Order still exist on market, the stop loss was not removed by metatrader
   if(stopLossOrder==NULL)
      SetToDeleteAllStopLoss();
   else
     {
      // stop loss was removed by metatrader
      stopLossOrderIsNotPlacedAnymoreByMetatrader(stopLossOrder);
     }
  }
//+------------------------------------------------------------------+
//| Try to load stop loss ticket
//+------------------------------------------------------------------+
bool CStopLossController::VerifyIfLoadStopLossTicket()
  {
   bool ticketLoaded=false;

   if(m_position_order.IsOnTradeOperation())
     {
      for(int i=0; i<m_list_stop_loss_orders.Total();i++)
        {
         CStopLossOrder *stopLossOrder=m_list_stop_loss_orders.GetNodeAtIndex(i);
         if(stopLossOrder.IsOrderWasPlaced() && !stopLossOrder.IsTicketLoaded())
           {
            string commentOperation=stopLossOrder.CommentOpenExecutedOperation();
            ulong ticket=m_trades_service.TryToLoadOrderTicket(commentOperation);
            if(ticket!=0)
              {
               stopLossOrder.AddTicket(ticket);
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
void CStopLossController::ResetToDefault()
  {
   SetToDeleteAllStopLoss();
   if(verifyIfNeedToDeleteStop())
      return;

   m_stops_to_create=0;
   m_stops_to_delete=0;

   m_list_stop_loss_orders.Clear();
   delete m_list_stop_loss_orders;
   m_list_stop_loss_orders=new CList;

   ResetStopLossProfileToDefault();
  }
//+------------------------------------------------------------------+
//| Verify if is valid to place a take profit order
//+------------------------------------------------------------------+
bool CStopLossController::isValidToPlaceOrder()
  {
   if(m_stop_loss_points==0.0)
      return false;

   if(!m_position_order.IsOrderPlaced())
      return false;

   if(!m_position_order.IsOnTradeOperation())
      return false;

   if(!verifyIfNeedToCreateNewStop())
      return false;

   return true;
  }
//+------------------------------------------------------------------+
//| Create the stop loss order
//+------------------------------------------------------------------+
CStopLossOrder *CStopLossController::createStopLossOrder()
  {
   int stopLossIndex=m_list_stop_loss_orders.Total()+1;
   CStopLossOrder *stopLossOrder=new CStopLossOrder(m_trade_name,stopLossIndex,m_position_order);

   m_list_stop_loss_orders.Add(stopLossOrder);
   return stopLossOrder;
  }
//+------------------------------------------------------------------+
//| Calculate the stop loss price
//+------------------------------------------------------------------+
double CStopLossController::calculateStopLossPrice(CStopLossOrder *stopLossOrder)
  {
   double openPrice=m_position_order.Price();
   double stopLossPrice=0;

   double pointsToStop=m_stop_loss_points;

   if(VerifyIfIsUsingStopBasedOnProfile())
      pointsToStop=m_stop_loss_object_profile.LastProfileCalculated().NewPoints();

   if(m_position_order.IsOnBuyTrade())
     {
      stopLossPrice=openPrice-pointsToStop;
      stopLossOrder.SetAsBuyStopLoss();
     }
   else
     {
      stopLossPrice=openPrice+pointsToStop;
      stopLossOrder.SetAsSellStopLoss();
     }

   stopLossOrder.AddStopLossPrice(stopLossPrice);
   return stopLossPrice;
  }
//+------------------------------------------------------------------+
//| Inform that stop loss was placed
//+------------------------------------------------------------------+
void CStopLossController::stopLossOrderWasPlaced(CStopLossOrder *stopLossOrder)
  {
   stopLossOrder.SetOrderAsPlaced();
  }
//+------------------------------------------------------------------+
//| Inform that stop loss was placed not anymore (Was Removed)
//+------------------------------------------------------------------+
void CStopLossController::stopLossOrderIsNotPlacedAnymore(CStopLossOrder *stopLossOrder)
  {
   m_stops_to_delete-=1;
   if(m_stops_to_delete<0)
      m_stops_to_delete=0;

   stopLossOrder.SetOrderAsNotPlaced();
//stopLossOrder.RemoveTicket();
  }
//+------------------------------------------------------------------+
//| Inform that stop loss was placed not anymore by metatrader (Was Removed By metatrader)
//+------------------------------------------------------------------+
void CStopLossController::stopLossOrderIsNotPlacedAnymoreByMetatrader(CStopLossOrder *stopLossOrder)
  {
   stopLossOrder.SetOrderAsNotPlaced();
//stopLossOrder.RemoveTicket();
  }
//+------------------------------------------------------------------+
//| Verify if change the stop loss based on Profile
//+------------------------------------------------------------------+
bool CStopLossController::VerifyIfChangeStopLossBasedOnProfile(double currentMarketPrice)
  {
   MqlTick lastTick;
   SymbolInfoTick(Symbol(),lastTick);
   double lastMarketPrice=lastTick.last;

   if(VerifyIfIsValidToChangeStopBasedOnProfile())
     {
      if(m_stop_loss_object_profile.VerifyIfExistEnabledProfiles()
         && m_stop_loss_object_profile.VerifyIfNeedToChangeStopLoss(m_position_order.IsOnBuyTrade(),m_position_order.Price(),currentMarketPrice))
        {
         SetToDeleteAllStopLoss();
         SetToCreateNewStop();
         return true;
        }
     }

   return false;
  }
//+------------------------------------------------------------------+
//| Verify if need to change the stop loss value
//+------------------------------------------------------------------+
bool CStopLossController::VerifyIfIsValidToChangeStopBasedOnProfile()
  {
   if(m_stop_loss_points==0.0)
      return false;

   if(!m_position_order.IsOrderPlaced())
      return false;

   if(!m_position_order.IsOnTradeOperation())
      return false;

   if(VerifyIfHasOrders() && !VerifyIfHasOpenStop())
      return true;

   return false;
  }
//+------------------------------------------------------------------+
//| Verify if is using stop profile
//+------------------------------------------------------------------+
bool CStopLossController::VerifyIfIsUsingStopBasedOnProfile()
  {
   CPriceControl *priceControl=m_stop_loss_object_profile.LastProfileCalculated();
   return priceControl!=NULL;
  }
//+------------------------------------------------------------------+
//| Reset StopLoss to default
//+------------------------------------------------------------------+
void CStopLossController::ResetStopLossProfileToDefault()
  {
   delete m_stop_loss_object_profile;
   m_stop_loss_object_profile=new CStopLossProfile(m_stop_loss_profile);
  }
//+------------------------------------------------------------------+
