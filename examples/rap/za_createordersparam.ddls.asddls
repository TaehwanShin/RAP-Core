@EndUserText.label: 'Order action parameters'
define abstract entity ZA_CreateOrdersParam
{
  CustomerId : abap.char(10);
  OrderType : abap.char(4);
  Amount : abap.dec(15,2);
  Currency : abap.cuky;
  RequestedDate : abap.dats;
}
