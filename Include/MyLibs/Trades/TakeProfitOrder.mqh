//+------------------------------------------------------------------+
//|                                              TakeProfitOrder.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Frederico Benevides"
#property link      "fredbene@gmail.com"

#include <Object.mqh>

#include <MyLibs\Trades\PositionOrder.mqh>

#include <MyLibs\Trades\TradesService.mqh>
//+------------------------------------------------------------------+
//| Class to map take profit order
//+------------------------------------------------------------------+
class CTakeProfitOrder : public CObject
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
                     CTakeProfitOrder(string tradeName,int indexTakeProfit,CPositionOrder *positionOrder);
                    ~CTakeProfitOrder();

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
CTakeProfitOrder::CTakeProfitOrder(string tradeName,int indexTakeProfit,CPositionOrder *positionOrder)
  {
   m_buy_open_name=tradeName+"::BuyOpen::TP("+IntegerToString(indexTakeProfit)+")";
   m_sell_open_name=tradeName+"::SellOpen::TP("+IntegerToString(indexTakeProfit)+")";
   m_buy_close_name=tradeName+"::BuyClose::DTP("+IntegerToString(indexTakeProfit)+")";
   m_sell_close_name=tradeName+"::SellClose::DTP("+IntegerToString(indexTakeProfit)+")";

   m_position_order=positionOrder;
  }
//+------------------------------------------------------------------+
//| Destructor
//+------------------------------------------------------------------+
CTakeProfitOrder::~CTakeProfitOrder()
  {
  }
//+------------------------------------------------------------------+
//| Returns the Buy or Sell Open Name
//+------------------------------------------------------------------+
string CTakeProfitOrder::BuySellOpenName()
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
string CTakeProfitOrder::BuySellCloseName()
  {
   if(m_open_on_buy_trade)
      return m_buy_close_name;
   else
      return m_sell_close_name;
  }
//+------------------------------------------------------------------+
