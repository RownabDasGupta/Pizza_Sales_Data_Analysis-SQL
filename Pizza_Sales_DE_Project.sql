CREATE DATABASE pizza_sales_de_project;

use pizza_sales_de_project;

CREATE TABLE ORDERS (
ORDER_ID INT NOT NULL,
ORDER_DATE DATE NOT NULL,
ORDER_TIME TIME NOT NULL,
PRIMARY KEY(ORDER_ID)
);

CREATE TABLE ORDER_DETAILS (
ORDER_DETAILS_ID INT NOT NULL,
ORDER_ID INT NOT NULL,
PIZZA_ID TEXT NOT NULL,
QUANTITY INT NOT NULL,
PRIMARY KEY(ORDER_DETAILS_ID)
);

-- Basic:
-- Q1. Retrieve the total number of orders placed.
SELECT COUNT(order_id) as total_orders from Orders;

-- Q2. Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(Order_Details.Quantity * Pizzas.Price),
            2) AS Total_Sales
FROM
    Order_Details
        JOIN
    Pizzas ON Order_Details.Pizza_id = Pizzas.Pizza_Id;
    
-- Q3. Identify the highest-priced pizza.
SELECT 
Pizza_Types.name, Pizzas.price
from Pizza_Types
JOIN Pizzas
ON Pizza_Types.Pizza_Type_Id = Pizzas.pizza_type_id
Order By Pizzas.Price DESC
LIMIT 1;

-- Q4. Identify the most common pizza size ordered.
select
Pizzas.size, count(Order_Details.Order_Details_Id) as Order_Count
From Pizzas 
JOIN Order_Details
ON Pizzas.pizza_id = Order_Details.Pizza_Id
GROUP BY 1
ORDER BY Order_Count DESC
LIMIT 1;

-- Q5. List the top 5 most ordered pizza types along with their quantities.
SELECT 
Pizza_Types.name,
SUM(Order_Details.Quantity) as Sum_Quantity
FROM Pizza_Types
JOIN Pizzas
ON Pizza_Types.Pizza_Type_Id = Pizzas.Pizza_Type_Id
JOIN Order_Details 
ON Order_Details.Pizza_Id = Pizzas.Pizza_Id
GROUP BY Pizza_Types.name
ORDER BY Sum_Quantity DESC
LIMIT 5; 


-- Intermediate:
-- Q6. Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
Pizza_Types.Category,
Sum(Order_Details.Quantity) as Total_Quantity
FROM Pizza_Types
JOIN Pizzas
ON Pizza_Types.Pizza_Type_Id = Pizzas.Pizza_Type_Id
JOIN Order_Details
ON Order_Details.Pizza_Id = Pizzas.Pizza_Id
GROUP BY 1
ORDER BY Total_Quantity DESC;

-- Q7. Determine the distribution of orders by hour of the day.
SELECT HOUR(Order_Time) as Hour, 
COUNT(Order_Id) as Order_Count
FROM Orders
Group BY 1;

-- Q8. Join relevant tables to find the category-wise distribution of pizzas.
SELECT Category, Count(Name) as Count
FROM Pizza_Types
GROUP BY Category;

-- Q9. Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
ROUND(AVG(Quantity_Sum), 0) as Order_Quantity_Per_Day
FROM
(
	SELECT
	Orders.Order_date, SUM(Order_Details.Quantity) as Quantity_Sum
	FROM Orders
	JOIN Order_Details
	ON Orders.Order_Id = Order_Details.Order_Id
	GROUP BY 1
) as Order_Quantity;

-- Q10. Determine the top 3 most ordered pizza types based on revenue.
SELECT 
Pizza_Types.name,
Sum(Order_Details.Quantity * Pizzas.price) as Revenue_Sum
FROM Pizza_Types 
JOIN Pizzas
ON Pizza_Types.pizza_type_id = Pizzas.Pizza_type_id
JOIN Order_Details 
ON Order_Details.Pizza_Id = Pizzas.Pizza_Id
GROUP BY 1
ORDER BY Revenue_Sum DESC
LIMIT 3;


-- Advanced:
-- Q11. Calculate the percentage contribution of each pizza type to total revenue.
SELECT
Pizza_Types.Category,
ROUND( ( SUM(Order_Details.Quantity * Pizzas.Price)  / (SELECT ROUND(SUM(Order_Details.Quantity * Pizzas.Price), 2) 
												FROM Order_Details 
                                                JOIN Pizzas 
                                                ON Order_Details.Pizza_Id = Pizzas.Pizza_Id
                                                ) 
) * 100, 2 ) as Percentage_Contribution_To_Revenue
FROM Pizza_Types 
JOIN Pizzas
ON Pizza_Types.Pizza_Type_Id = Pizzas.Pizza_Type_Id
JOIN Order_Details
ON Order_Details.Pizza_Id = Pizzas.Pizza_Id
GROUP BY 1
ORDER BY Percentage_Contribution_To_Revenue DESC;

-- The below part that I have used is indicating tatal_sales :
-- (
-- SELECT ROUND(SUM(Order_Details.Quantity * Pizzas.Price), 2) 
-- 	FROM Order_Details 
--  JOIN Pizzas 
--  ON Order_Details.Pizza_Id = Pizzas.Pizza_Id
-- ) as tatal_sales
-- and
-- the below paty is total_revenue
-- SUM(Order_Details.Quantity * Pizzas.Price) as total_revenue



-- Q12. Analyze the cumulative revenue generated over time. 
-- Explanation of cumulative revenue:
-- current_day_revenue -> cumulative_revenue
-- 200 -> 200
-- 300 -> 500
-- 450 -> 950
-- 250 -> 1200
SELECT Order_Date,
Sum(Revenue) OVER(Order By Order_Date) as cumulative_revenue
FROM
(
	SELECT 
	Orders.Order_date,
	SUM(Order_Details.Quantity * Pizzas.Price) as Revenue
	FROM Order_Details
	JOIN Pizzas
	ON Order_Details.Pizza_Id = Pizzas.Pizza_Id
	Join Orders
	ON Orders.Order_Id = Order_Details.Order_Id
	GROUP BY 1
) as Sales;


-- Q13. Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT Name, Revenue
FROM
(
	SELECT Category, Name, Revenue,
	rank() OVER(Partition By Category Order By Revenue DESC) as RN
	FROM
	(
		SELECT 
		Pizza_Types.Category, Pizza_Types.Name,
		SUM(Order_Details.Quantity * Pizzas.Price) as Revenue
		FROM Pizza_Types 
		JOIN Pizzas 
		ON Pizza_Types.Pizza_Type_Id = Pizzas.Pizza_Type_Id
		JOIN Order_Details
		ON Order_Details.Pizza_Id = Pizzas.Pizza_Id
		GROUP BY 1, 2
	) as table_a
) as table_b
WHERE rn <= 3;








