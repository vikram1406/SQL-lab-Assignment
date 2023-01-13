use supply_db ;

/*  Question: Month-wise NIKE sales

	Description:
		Find the combined month-wise sales and quantities sold for all the Nike products. 
        The months should be formatted as ‘YYYY-MM’ (for example, ‘2019-01’ for January 2019). 
        Sort the output based on the month column (from the oldest to newest). The output should have following columns :
			-Month
			-Quantities_sold
			-Sales
		HINT:
			Use orders, ordered_items, and product_info tables from the Supply chain dataset.
*/
SELECT DATE_FORMAT(Order_Date,'%Y-%m') AS Month,
SUM(Quantity) AS Quantities_Sold,
SUM(Sales) AS Sales
FROM
orders AS ord
LEFT JOIN
ordered_items AS ord_itm
ON ord.Order_Id = ord_itm.Order_Id
LEFT JOIN
product_info AS prod_info
ON ord_itm.Item_Id=prod_info.Product_Id
WHERE LOWER(Product_Name) LIKE '%nike%'
GROUP BY 1
ORDER BY 1;		





-- **********************************************************************************************************************************
/*

Question : Costliest products

Description: What are the top five costliest products in the catalogue? Provide the following information/details:
-Product_Id
-Product_Name
-Category_Name
-Department_Name
-Product_Price

Sort the result in the descending order of the Product_Price.

HINT:
Use product_info, category, and department tables from the Supply chain dataset.


*/
SELECT prod_info.Product_Id,
prod_info.Product_Name,
cat.Name AS Category_Name,
dept.Name AS Department_Name,
prod_info.Product_Price
FROM
product_info AS prod_info
LEFT JOIN
category AS cat
ON prod_info.Category_Id =cat.Id
LEFT JOIN
department AS dept
ON prod_info.Department_Id=dept.Id
ORDER BY prod_info.Product_Price DESC
LIMIT 5;

-- **********************************************************************************************************************************

/*

Question : Cash customers

Description: Identify the top 10 most ordered items based on sales from all the ‘CASH’ type orders. 
Provide the Product Name, Sales, and Distinct Order count for these items. Sort the table in descending
 order of Order counts and for the cases where the order count is the same, sort based on sales (highest to
 lowest) within that group.
 
HINT: Use orders, ordered_items, and product_info tables from the Supply chain dataset.


*/
SELECT prod_info.product_name,sum(ord.sales) AS sales, 
count(DISTINCT orde.order_id) AS counts FROM orders AS orde LEFT JOIN 
ordered_items AS ord ON orde.Order_Id = ord.Order_Id  LEFT JOIN
product_info AS prod_info
ON ord.Item_Id=prod_info.Product_Id 
WHERE orde.type LIKE '%cash%' 
GROUP BY prod_info.product_name
ORDER BY counts DESC
LIMIT 10;

-- **********************************************************************************************************************************
/*
Question : Customers from texas

Obtain all the details from the Orders table (all columns) for customer orders in the state of Texas (TX),
whose street address contains the word ‘Plaza’ but not the word ‘Mountain’. The output should be sorted by the Order_Id.

HINT: Use orders and customer_info tables from the Supply chain dataset.

*/
SELECT o.* FROM orders o LEFT JOIN customer_info c 
ON o.Customer_Id = c.Id
WHERE c.State LIKE 'TX' 
AND c.Street LIKE '%Plaza%'
AND c.Street NOT LIKE '%Mountain%'
ORDER BY o.Order_Id;

-- **********************************************************************************************************************************
/*
 
Question: Home office

For all the orders of the customers belonging to “Home Office” Segment and have ordered items belonging to
“Apparel” or “Outdoors” departments. Compute the total count of such orders. The final output should contain the 
following columns:
-Order_Count

*/
SELECT count(DISTINCT ord.order_id) AS order_count FROM orders AS ord INNER JOIN customer_info AS cus 
ON ord.customer_id=cus.id INNER JOIN ordered_items AS ord_itm 
ON ord.order_id=ord_itm.order_id INNER JOIN product_info AS pro 
ON ord_itm.item_id=pro.product_id INNER JOIN department AS dep 
ON pro.department_id=dep.id 
WHERE cus.segment='Home Office' AND( dep.name = 'Apparel' OR dep.name = 'Outdoors') ;

-- **********************************************************************************************************************************
/*

Question : Within state ranking
 
For all the orders of the customers belonging to “Home Office” Segment and have ordered items belonging
to “Apparel” or “Outdoors” departments. Compute the count of orders for all combinations of Order_State and Order_City. 
Rank each Order_City within each Order State based on the descending order of their order count (use dense_rank). 
The states should be ordered alphabetically, and Order_Cities within each state should be ordered based on their rank. 
If there is a clash in the city ranking, in such cases, it must be ordered alphabetically based on the city name. 
The final output should contain the following columns:
-Order_State
-Order_City
-Order_Count
-City_rank

HINT: Use orders, ordered_items, product_info, customer_info, and department tables from the Supply chain dataset.

*/
SELECT Order_State,Order_City,count(o.order_id) AS Order_Count,
DENSE_RANK() OVER(PARTITION BY o.Order_State ORDER BY count(o.order_id) DESC) AS City_rank
FROM customer_info c INNER JOIN orders AS o ON c.id=o.customer_id
INNER JOIN ordered_items AS oid ON o.order_id=oid.order_id
INNER JOIN product_info AS p ON oid.item_id=p.product_id
INNER JOIN department AS d ON p.department_id=d.id
WHERE segment='Home Office' AND d.name = 'Apparel' OR d.name = 'Outdoors'
GROUP BY Order_State,Order_State
ORDER BY Order_State, Order_City DESC;

-- **********************************************************************************************************************************
/*
Question : Underestimated orders

Rank (using row_number so that irrespective of the duplicates, so you obtain a unique ranking) the 
shipping mode for each year, based on the number of orders when the shipping days were underestimated 
(i.e., Scheduled_Shipping_Days < Real_Shipping_Days). The shipping mode with the highest orders that meet 
the required criteria should appear first. Consider only ‘COMPLETE’ and ‘CLOSED’ orders and those belonging to 
the customer segment: ‘Consumer’. The final output should contain the following columns:
-Shipping_Mode,
-Shipping_Underestimated_Order_Count,
-Shipping_Mode_Rank

HINT: Use orders and customer_info tables from the Supply chain dataset.


*/
SELECT O.Shipping_Mode,COUNT(O.order_id) 
       AS
       Shipping_Underestimated_Order_Count,
ROW_NUMBER()OVER (PARTITION BY YEAR(O.Order_Date)
ORDER BY Count(O.order_id) DESC) AS Shipping_Mode_Rank
FROM   orders O INNER JOIN customer_info CI
               ON O.Customer_Id = CI.Id
WHERE  (O.Order_Status = 'Complete' or O.Order_Status = 'Closed')
       AND CI.Segment = 'Consumer'
       AND O.Scheduled_Shipping_Days <Real_Shipping_Days
GROUP BY O.Shipping_Mode, YEAR(O.Order_Date);

-- **********************************************************************************************************************************





