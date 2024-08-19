CREATE DATABASE pizzhut;
USE pizzhut;

-- Retrieve total number of orders placed.
SELECT COUNT(order_id) FROM orders;

-- Total revenue generated from pizza sales
SELECT ROUND(SUM(pizzas.price * order_details.quantity),2) AS Total_sales
FROM pizzas 
LEFT JOIN order_details
ON pizzas.pizza_id = order_details.pizza_id;

-- Identify the highest price pizza
SELECT pizza_types.name, pizzas.price
FROM pizza_types
INNER JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC LIMIT 1;

-- Identify the most common pizza size ordered

SELECT COUNT(order_details.order_details_id), pizzas.size
FROM pizzas
LEFT JOIN order_details
ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size 
ORDER BY COUNT(order_details.order_details_id) DESC LIMIT 1 ;

-- List the top 5 most ordered pizza types along with their quantities

SELECT SUM(order_details.quantity) , pizza_types.name
FROM (( pizzas
INNER JOIN pizza_types
ON pizzas.pizza_type_id = pizza_types.pizza_type_id)
INNER JOIN order_details
ON pizzas.pizza_id = order_details.pizza_id)
GROUP BY pizza_types.name
ORDER BY COUNT(order_details.quantity) DESC LIMIT 5 ;

-- MEDIUM LEVEL QUESTIONS!!
-- Join the necesasry tables to find the total quantity of each pizza category ordered.

SELECT SUM(order_details.quantity) , pizza_types.category
FROM (( pizzas
INNER JOIN pizza_types
ON pizzas.pizza_type_id = pizza_types.pizza_type_id)
INNER JOIN order_details
ON pizzas.pizza_id = order_details.pizza_id)
GROUP BY pizza_types.category
ORDER BY SUM(order_details.quantity) DESC ;

-- Determine the distribution of orders by hour of the day

SELECT hour(time), COUNT(order_id)
FROM orders
GROUP BY hour(time) ;

-- Join relevant tables to find the category wise distribution of pizza

SELECT category ,COUNT(name)
FROM pizza_types
GROUP BY category;

-- Group the orders by date and calculate the average number of pizzas ordered per day

SELECT ROUND(AVG(quantity),0) FROM(
SELECT orders.date , SUM(order_details.quantity) AS quantity
FROM orders
LEFT JOIN order_details
ON orders.order_id = order_details.order_id
GROUP BY orders.date) AS order_quantity;

-- Determine the top 3 most ordered pizza type based on revenue

SELECT pizza_types.name , SUM(pizzas.price*order_details.quantity) AS Total_Revenue
FROM ((pizza_types
LEFT JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id)
LEFT JOIN order_details
ON pizzas.pizza_id = order_details.pizza_id)
GROUP BY pizza_types.name
ORDER BY Total_Revenue DESC LIMIT 3;

-- HARD LEVEL
-- Calculate the percentage contribution to each pizza type to total revenue

SELECT pizza_types.category , 
ROUND(SUM(pizzas.price*order_details.quantity) / ( SELECT (SUM(pizzas.price*order_details.quantity) )
FROM pizzas
LEFT JOIN order_details
ON pizzas.pizza_id = order_details.pizza_id)*100,2) AS Revenue
FROM ((pizza_types
LEFT JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id)
LEFT JOIN order_details
ON pizzas.pizza_id = order_details.pizza_id)
GROUP BY pizza_types.category
ORDER BY Revenue DESC;

-- Analyze the cumulative revenue gennerated over time


SELECT date ,SUM(Revenue) OVER(ORDER BY date) AS Cum_Revenue
FROM
(SELECT orders.date , SUM(pizzas.price*order_details.quantity) AS Revenue
FROM ((order_details 
LEFT JOIN pizzas
ON order_details.pizza_id = pizzas.pizza_id )
LEFT JOIN orders
ON order_details.order_id = orders.order_id)
GROUP BY orders.date ) AS Sales ;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

SELECT name,Revenue,Rnk
FROM(
SELECT category , name, Revenue ,RANK() OVER (PARTITION BY category ORDER BY Revenue DESC) AS Rnk
FROM
(SELECT pizza_types.category , pizza_types.name,
SUM(pizzas.price*order_details.quantity) AS Revenue
FROM ((pizza_types
LEFT JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id)
LEFT JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id)
GROUP BY pizza_types.category,pizza_types.name) AS aa)AS bb
WHERE Rnk<=3;


 