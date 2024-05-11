## Creation of database
Create database Pizzahut;

CREATE TABLE orders (
    order_id INT NOT NULL,
    order_date DATE NOT NULL,
    order_time TIME NOT NULL,
    PRIMARY KEY (order_id)
);

CREATE TABLE order_details (
    order_details_id INT NOT NULL,
    order_id INT NOT NULL,
    pizza_id TEXT NOT NULL,
    quantity INT,
    PRIMARY KEY (order_details_id)
);

-- 1. Retrieve the total number of orders placed.
SELECT 
    COUNT(order_id) AS Total_Orders
FROM
    orders;

-- 2. Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(quantity * price), 2) AS Total_Sales
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id;
    
-- 3. Identify the highest-priced pizza.  
SELECT 
    name, price
FROM
    pizzas
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
ORDER BY price DESC
LIMIT 1;

-- 4. Identify the most common pizza size ordered.
SELECT 
    size, COUNT(quantity) AS Quantity
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY size
ORDER BY Quantity DESC;

-- 5.List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pizza_types.name,
    SUM(order_details.quantity) AS Total_Quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name
ORDER BY Total_Quantity DESC
LIMIT 5;

-- 1.Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS Total_Quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category
ORDER BY Total_Quantity DESC
LIMIT 5;

-- 2. Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time) AS hours, COUNT(order_id) AS orders
FROM
    orders
GROUP BY hours;

-- 3. Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    category, COUNT(name) AS types
FROM
    pizza_types
GROUP BY category
ORDER BY types DESC;

-- 4. Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(Orders), 0) AS Average_order_per_day
FROM
    (SELECT 
        order_date, SUM(quantity) AS Orders
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY order_date) AS order_quantity;

-- 5. Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    name, SUM(quantity * price) AS Total_Revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY name
ORDER BY Total_Revenue DESC
LIMIT 3;

-- 1.Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    category,
    CONCAT(ROUND((SUM(quantity * price) / (SELECT 
                            SUM(quantity * price)
                        FROM
                            order_details
                                JOIN
                            pizzas ON order_details.pizza_id = pizzas.pizza_id) * 100),
                    2),
            '%') AS Percentage_Contribution
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY category
ORDER BY Percentage_Contribution DESC;

-- 2.Analyze the cumulative revenue generated over time.
select order_date,sum(Revenue) over(order by order_date) as Cum_Revenue from
(SELECT 
    order_date, ROUND(SUM(quantity * price), 2) AS Revenue
FROM
    order_details
        JOIN
    orders ON order_details.order_id = orders.order_id
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id
GROUP BY order_date) as Sales;

-- 3. Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select category,name, Revenue from
(select category,name, Revenue,rank() over(partition by category order by Revenue desc) as ranks from
(SELECT 
    category,name, ROUND(SUM(quantity * price), 2) AS Revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY category,name) as a) as b
where ranks <=3;