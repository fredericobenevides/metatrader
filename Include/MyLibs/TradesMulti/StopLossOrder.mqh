//+------------------------------------------------------------------+
//|                                                StopLossOrder.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Frederico Benevides"
#property link      "fredbene@gmail.com"

#include <Object.mqh>

#include <MyLibs\Trades\PositionOrder.mqh>

#include <MyLibs\Trades\TradesService.mqh>
//+------------------------------------------------------------------+
//| Class to map stop loss order
//+------------------------------------------------------------------+
class CStopLossOrder : public CObject
  {
   CPositionOrder   *m_position_order;

   string            m_buy_open_name;
   string            m_sell_open_name;
   string            m_buy_close_name;
   string            m_sell_close_name;

   bool              m_open_on_buy_trade;
   bool              m_open_on_sell_trade;

   string            m_comment_operation;
   double            m_stop_loss_price;

   bool              m_order_placed;
   ulong             m_ticket;
public:

                     CStopLossOrder(string tradeName,int indexStopLoss,CPositionOrder *positionOrder);
                    ~CStopLossOrder();

   string            BuySellOpenName();
   string            BuySellCloseName();
   void              SetAsBuyStopLoss() { m_open_on_buy_trade=true; }
   void              SetAsSellStopLoss() { m_open_on_sell_trade=true; }
   bool              IsBuyStopLoss()  { return m_open_on_buy_trade; }
   bool              IsSellStopLoss() { return m_open_on_sell_trade; }

   string            CommentOpenExecutedOperation() { return m_comment_operation; }
   void              AddComentOpenExecutedOperation(string commentOperation) { m_comment_operation=commentOperation; }

   double            StopLossPrice() { return m_stop_loss_price; }
   void              AddStopLossPrice(double stopLossPrice) { m_stop_loss_price=stopLossPrice; }

   bool              IsOrderWasPlaced() { return m_order_placed; }
   void              SetOrderAsPlaced() { m_order_placed = true; }
   void              SetOrderAsNotPlaced() { m_order_placed=false; }

   bool              IsTicketLoaded() { return m_ticket>0; }
   bool              IsTicketEqual(ulong ticket) { return m_ticket==ticket; }
   void              AddTicket(ulong ticket) { m_ticket=ticket; }
   ulong             Ticket() { return m_ticket; }
  };
//+------------------------------------------------------------------+
//| Constructor
//+------------------------------------------------------------------+
CStopLossOrder::CStopLossOrder(string tradeName,int indexStopLoss,CPositionOrder *positionOrder)
  {
   m_buy_open_name=tradeName+"::BuyOpen::SL("+IntegerToString(indexStopLoss)+")";
   m_sell_open_name=tradeName+"::SellOpen::SL("+IntegerToString(indexStopLoss)+")";
   m_buy_close_name=tradeName+"::BuyClose::DSL("+IntegerToString(indexStopLoss)+")";
   m_sell_close_name=tradeName+"::SellClose::DSL("+IntegerToString(indexStopLoss)+")";

   m_position_order=positionOrder;
  }
//+------------------------------------------------------------------+
//| Destructor
//+------------------------------------------------------------------+
CStopLossOrder::~CStopLossOrder()
  {
  }
//+------------------------------------------------------------------+
//| Returns the Buy or Sell Open Name
//+------------------------------------------------------------------+
string CStopLossOrder::BuySellOpenName()
  {
   if(m_position_order.IsOnBuyTrade())
     {
      return m_buy_open_name;
     }
   else
     {
      return m_sell_open_name;
     }
  }
//+------------------------------------------------------------------+
//| Returns the Buy or Sell Open Name
//+------------------------------------------------------------------+
string CStopLossOrder::BuySellCloseName()
  {
   if(m_open_on_buy_trade)
      return m_buy_close_name;
   else
      return m_sell_close_name;
  }
//+------------------------------------------------------------------+
