@EndUserText.label: 'Order parameter validation demo'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity ZI_RC_Order_Demo
  as select from zrc_order_demo
{
  key order_id as OrderId,
      customer_id as CustomerId,
      order_type as OrderType,
      amount as Amount,
      currency as Currency,
      requested_date as RequestedDate
}
