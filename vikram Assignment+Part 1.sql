use supply_db ;

/*
Question : Golf related products

List all products in categories related to golf. Display the Product_Id, Product_Name in the output. Sort the output in the order of product id.
Hint: You can identify a Golf category by the name of the category that contains golf.

*/
SELECT p.Product_Name, p.Product_Id 
FROM product_info p 
INNER JOIN category c
ON p.Category_Id = c.Id
WHERE c.Name LIKE '%Golf%'
ORDER BY 2;

-- **********************************************************************************************************************************

/*
Question : Most sold golf products

Find the top 10 most sold products (based on sales) in categories related to golf. Display the Product_Name and Sales column in the output. Sort the output in the descending order of sales.
Hint: You can identify a Golf category by the name of the category that contains golf.

HINT:
Use orders, ordered_items, product_info, and category tables from the Supply chain dataset.


*/
 WITH golf_summary AS 
 (
 SELECT p.Product_Name, p.Product_Id,p.Category_Id,c.name FROM product_info p 
 INNER JOIN category c
 ON p.Category_Id = c.Id
 
 )
 SELECT Product_Name, sum(sales) AS sales FROM golf_summary g INNER JOIN ordered_items o
 ON g.product_Id = o.item_id
 WHERE g.Name LIKE '%Golf%'
 GROUP BY Product_Name
 ORDER BY sales DESC
 LIMIT 10;

-- **********************************************************************************************************************************

/*
Question: Segment wise orders

Find the number of orders by each customer segment for orders. Sort the result from the highest to the lowest 
number of orders.The output table should have the following information:
-Customer_segment
-Orders


*/
 SELECT c.segment AS customer_segment , count(o.Order_Id) AS Orders

 FROM customer_info c 
 LEFT JOIN orders o 
 ON c.Id= o.customer_Id
 GROUP BY customer_segment
 ORDER BY Orders DESC;
 

-- **********************************************************************************************************************************
/*
Question : Percentage of order split

Description: Find the percentage of split of orders by each customer segment for orders that took six days 
to ship (based on Real_Shipping_Days). Sort the result from the highest to the lowest percentage of split orders,
rounding off to one decimal place. The output table should have the following information:
-Customer_segment
-Percentage_order_split

HINT:
Use the orders and customer_info tables from the Supply chain dataset.


*/
 WITH seg_orders AS 
 (SELECT cust.segment AS customer_segment,
 count(ord.order_id) AS orders 
 FROM orders AS ord LEFT JOIN customer_info AS cust 
 ON  ord.customer_id = cust.id 
 WHERE real_shipping_days = 6 
 GROUP BY 1 
 )
 SELECT a.customer_segment, round(a.orders/sum(b.orders)*100,1) AS percentage_order_split
 FROM seg_orders AS a JOIN seg_orders AS b 
 GROUP BY 1
 ORDER BY 2 DESC;

-- **********************************************************************************************************************************
