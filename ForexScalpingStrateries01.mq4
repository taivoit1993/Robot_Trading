//+------------------------------------------------------------------+
//|                                    ForexScalpingStrateries01.mq4 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
extern  int SMA_Period = 200;
extern  int EMA_Period = 21;
extern  int k_percent = 5;
extern  int d_percent = 3;
extern  int slowing = 3;
extern  int stopLoss = 10;
extern int magicNumber = 5555;
int orderNumber;
int lastbar;
int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
      double sma200 = iMA(NULL,0,SMA_Period,0,MODE_SMA,PRICE_CLOSE,0);
      double ema21 = iMA(NULL,0,EMA_Period,0,MODE_EMA,PRICE_CLOSE,0);
      double main_line_previous =  iStochastic(NULL,0,k_percent,d_percent,slowing,MODE_SMA,0,MODE_MAIN,1);
      double signal_line_previous = iStochastic(NULL,0,k_percent,d_percent,slowing,MODE_SMA,0,MODE_SIGNAL,1);
      double main_line = iStochastic(NULL,0,k_percent,d_percent,slowing,MODE_SMA,0,MODE_MAIN,0);
      double signal_line = iStochastic(NULL,0,k_percent,d_percent,slowing,MODE_SMA,0,MODE_SIGNAL,0);
      double SL = stopLoss * getPipValue();
      if(isConditionSendOrder()){
         //market bearish
         if(ema21 < sma200 && Open[0] < sma200){
            if(main_line_previous > 80 && main_line_previous > signal_line_previous && main_line < signal_line){
               //long position
               orderNumber = OrderSend(NULL,OP_SELL,0.01,Bid,0,Bid + SL ,NULL,"",magicNumber); 
            }
         }
         //market bullish
         if(ema21 > sma200 && Open[0] > sma200){
            if(main_line_previous < 20 && main_line_previous < signal_line_previous && main_line > signal_line){
               //short position
               orderNumber = OrderSend(NULL,OP_BUY,0.01,Ask,0,Ask - SL ,NULL,"",magicNumber); 
            }
         }
      }
      else{
         if(OrderSelect(orderNumber,SELECT_BY_TICKET)){
            //long position
            if(OrderType() == 0){
               if((main_line > 50 && main_line < signal_line) || main_line > 80){
                  OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),2,clrNONE);
               }
            }
            //short position
            else{
               if((main_line < 50 && main_line > signal_line) || main_line < 20){
                  OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),2,clrNONE);
               }
            }
         }
      }
    
  }
//+------------------------------------------------------------------+

double getPipValue(){
   if(Digits < 4){
      return 0.01;
   }
   return 0.0001;
}

bool isConditionSendOrder(){
   int total = OrdersTotal();
   for(int pos=0;pos<total;pos++){
      if(OrderSelect(pos,SELECT_BY_POS)){
         if(OrderMagicNumber() == magicNumber){
            return false;
         }
      }
   }
   return true;
}

bool isNewBar(){
   datetime curbar = Time[0];
   if(lastbar!=curbar)
   {
      lastbar=curbar;
      return true; 
   }

   else
   {
      return false;
   }
}