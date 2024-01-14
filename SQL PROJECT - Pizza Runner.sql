--Question 1- How many pizzas were ordered?
SELECT COUNT(pizza_id) AS no_of_pizzas_ordered
FROM pizza_runner.customer_orders;

--Question 2- How many unique customer orders were made
WITH unique_orders AS (SELECT order_id, customer_id, pizza_id, exclusions, extras, order_time, COUNT (*) AS no_of_pizzas_ordered
FROM pizza_runner.customer_orders
GROUP BY order_id, customer_id, pizza_id, exclusions, extras, order_time)

SELECT COUNT(*) AS no_of_unique_orders
FROM unique_orders;

--Question 3- How many successful orders were delivered by each runner?
WITH orders_table AS (SELECT runner_id, (CASE WHEN cancellation = 'null' OR cancellation = '' THEN NULL
        ELSE cancellation END) AS cancellation_update
FROM pizza_runner.customer_orders as co
LEFT JOIN pizza_runner.runner_orders as ro 
ON co.order_id = ro.order_id)

SELECT runner_id, COUNT(*)
FROM orders_table
WHERE cancellation_update IS NULL
GROUP BY runner_id;

--Question 4- How many of each type of pizza was delivered?
WITH pizza_delivery AS (SELECT pizza_name, (CASE WHEN cancellation = 'null' OR cancellation = '' THEN NULL
        ELSE cancellation END) AS cancellation_update
FROM pizza_runner.customer_orders as co
LEFT JOIN pizza_runner.runner_orders as ro 
ON co.order_id = ro.order_id
LEFT JOIN pizza_runner.pizza_names as pn
ON co.pizza_id = pn.pizza_id
ORDER BY co.order_id)

SELECT pizza_name, COUNT(*) AS pizza_delivered
FROM pizza_delivery
WHERE cancellation_update IS NULL
GROUP BY pizza_name;

--Question 5- How many Vegetarian and Meatlovers were ordered by each customer?
SELECT customer_id, pizza_name, COUNT(*)
FROM pizza_runner.customer_orders as co
LEFT JOIN pizza_runner.runner_orders as ro 
ON co.order_id = ro.order_id
LEFT JOIN pizza_runner.pizza_names as pn
ON co.pizza_id = pn.pizza_id
GROUP BY customer_id,pizza_name
ORDER BY customer_id;

--Question 6- What was the maximum number of pizzas delivered in a single order?
WITH pizza_delivery AS (SELECT co.order_id, co.pizza_id, (CASE WHEN cancellation = 'null' OR cancellation = '' THEN NULL
        ELSE cancellation END) AS cancellation_update
FROM pizza_runner.customer_orders as co
LEFT JOIN pizza_runner.runner_orders as ro 
ON co.order_id = ro.order_id
ORDER BY co.order_id)

SELECT MAX(no_of_pizzas) AS max_no_of_pizza_per_order
FROM (SELECT order_id, COUNT(pizza_id) AS no_of_pizzas
FROM pizza_delivery
WHERE cancellation_update IS NULL
GROUP BY order_id
ORDER BY order_id) AS pizza_count

--Question 7a- For each customer, how many delivered pizzas had no changes?
WITH customer_orders_cleaned AS (SELECT customer_id, pizza_id, (CASE WHEN cancellation = 'null' OR cancellation = '' THEN NULL
        ELSE cancellation END) AS cancellation_update, (CASE WHEN exclusions = 'null' OR exclusions = '' THEN NULL
ELSE exclusions END) AS exclusions_new, (CASE WHEN extras = 'null' OR extras = '' THEN NULL
ELSE extras END) AS extras_new
FROM pizza_runner.customer_orders as co
LEFT JOIN pizza_runner.runner_orders as ro 
ON co.order_id = ro.order_id
ORDER BY co.order_id)

SELECT customer_id, COUNT(pizza_id) AS pizza_with_no_change
FROM customer_orders_cleaned
WHERE (exclusions_new IS NULL AND extras_new IS NULL) AND cancellation_update IS NULL
GROUP BY customer_id

--Question 7b- For each customer, how many delivered pizzas had at least 1 change?
WITH customer_orders_cleaned AS (SELECT customer_id, pizza_id, (CASE WHEN cancellation = 'null' OR cancellation = '' THEN NULL
        ELSE cancellation END) AS cancellation_update, (CASE WHEN exclusions = 'null' OR exclusions = '' THEN NULL
ELSE exclusions END) AS exclusions_new, (CASE WHEN extras = 'null' OR extras = '' THEN NULL
ELSE extras END) AS extras_new
FROM pizza_runner.customer_orders as co
LEFT JOIN pizza_runner.runner_orders as ro 
ON co.order_id = ro.order_id
ORDER BY co.order_id)

SELECT customer_id, COUNT(pizza_id) AS pizza_with_at_least_1_change
FROM customer_orders_cleaned 
WHERE (exclusions_new IS NOT NULL AND extras_new IS NULL) OR 
(exclusions_new IS NULL AND extras_new IS NOT NULL) OR 
(exclusions_new IS NOT NULL AND extras_new IS NOT NULL) AND cancellation_update IS NULL
GROUP BY customer_id

--Question 8- How many pizzas were delivered that had both exclusions and extras?
WITH customer_orders_cleaned AS (SELECT pizza_id, (CASE WHEN cancellation = 'null' OR cancellation = '' THEN NULL
        ELSE cancellation END) AS cancellation_update, (CASE WHEN exclusions = 'null' OR exclusions = '' THEN NULL
ELSE exclusions END) AS exclusions_new, (CASE WHEN extras = 'null' OR extras = '' THEN NULL
ELSE extras END) AS extras_new
FROM pizza_runner.customer_orders as co
LEFT JOIN pizza_runner.runner_orders as ro 
ON co.order_id = ro.order_id
ORDER BY co.order_id)

SELECT COUNT(pizza_id) AS pizza_with_both_exclusion_and_extras
FROM customer_orders_cleaned 
WHERE (exclusions_new IS NOT NULL AND extras_new IS NOT NULL) AND cancellation_update IS NULL

--Question 9- What was the total volume of pizzas ordered for each hour of the day?
WITH customer_orders_cleaned_time AS (SELECT pizza_id, EXTRACT(HOUR FROM order_time) AS hour_of_the_day
FROM pizza_runner.customer_orders)

SELECT hour_of_the_day, COUNT(pizza_id) AS total_volume_of_pizzas
FROM customer_orders_cleaned_time
GROUP BY hour_of_the_day
ORDER BY hour_of_the_day

--Question 10- What was the volume of orders for each day of the week?
WITH customer_orders_cleaned_date AS (SELECT order_id, EXTRACT(DOW FROM order_time) AS day_of_the_week
FROM pizza_runner.customer_orders)

SELECT day_of_the_week, COUNT(order_id) AS total_volume_of_pizzas
FROM customer_orders_cleaned_date
GROUP BY day_of_the_week
ORDER BY day_of_the_week
