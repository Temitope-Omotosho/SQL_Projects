-- 1. What is the total amount each customer spent at the restaurant?
SELECT customer_id, SUM(price) as total_amount
FROM dannys_diner.sales as s
LEFT JOIN dannys_diner.menu as m
ON s.product_id = m.product_id
GROUP BY customer_id
ORDER BY customer_id;

-- 2. How many days has each customer visited the restaurant?
SELECT customer_id, COUNT(DISTINCT order_date)
FROM dannys_diner.sales as s
LEFT JOIN dannys_diner.menu as m
ON s.product_id = m.product_id
GROUP BY customer_id
ORDER BY customer_id;

-- 3. What was the first item from the menu purchased by each customer?
SELECT order_date, customer_id, product_name
FROM dannys_diner.sales as s
LEFT JOIN dannys_diner.menu as m
ON s.product_id = m.product_id
WHERE order_date = (SELECT MIN(order_date) FROM dannys_diner.sales)
ORDER BY order_date, customer_id;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers
SELECT product_name, COUNT(*) as product_count
FROM dannys_diner.sales as s
LEFT JOIN dannys_diner.menu as m
ON s.product_id = m.product_id
GROUP BY product_name
ORDER BY product_count DESC
LIMIT 1;

-- 5. Which item was the most popular for each customer?
SELECT customer_id, product_name
FROM (SELECT customer_id, 
      product_name, 
      ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY COUNT(product_name) DESC) AS rank
FROM dannys_diner.sales as s
LEFT JOIN dannys_diner.menu as m
ON s.product_id = m.product_id
GROUP BY customer_id, product_name) AS ranking
WHERE rank = 1
ORDER BY customer_id;

-- 6. Which item was purchased first by the customer after they became a member?
SELECT order_date, customer_id, product_name
FROM (SELECT order_date, s.customer_id, product_name, RANK() OVER(PARTITION BY s.customer_id ORDER BY order_date) AS first_item
      FROM dannys_diner.sales as s
      LEFT JOIN dannys_diner.menu as m
      ON s.product_id = m.product_id
      LEFT JOIN dannys_diner.members as mem
      ON s.customer_id = mem.customer_id
      WHERE order_date > join_date
      ORDER BY order_date) AS first_purchase_after
WHERE first_item = 1
ORDER BY customer_id;

-- 7. Which item was purchased just before the customer became a member?
SELECT order_date, customer_id, product_name
FROM (SELECT order_date, s.customer_id, product_name, RANK() OVER(PARTITION BY s.customer_id ORDER BY order_date) AS first_item
      FROM dannys_diner.sales as s
      LEFT JOIN dannys_diner.menu as m
      ON s.product_id = m.product_id
      LEFT JOIN dannys_diner.members as mem
      ON s.customer_id = mem.customer_id
      WHERE order_date < join_date
      ORDER BY order_date) AS first_purchase_before
WHERE first_item = 1
ORDER BY customer_id;

-- 8. What is the total items and amount spent for each member before they became a member?
SELECT s.customer_id, COUNT(*) as total_items, SUM(price) as total_amount
FROM dannys_diner.sales as s
LEFT JOIN dannys_diner.menu as m
ON s.product_id = m.product_id
LEFT JOIN dannys_diner.members as mem
ON s.customer_id = mem.customer_id
WHERE order_date < join_date
GROUP BY s.customer_id
ORDER BY s.customer_id;

-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
SELECT customer_id, SUM(points) as total_points
FROM(SELECT s.customer_id, 
       price, (CASE WHEN product_name = 'sushi' THEN 20
                       ELSE 10 END) AS multiplier_effect, 
       (price*(CASE WHEN product_name = 'sushi' THEN 20 ELSE 10 END)) AS points
                       
FROM dannys_diner.sales as s
LEFT JOIN dannys_diner.menu as m
ON s.product_id = m.product_id
ORDER BY s.customer_id) AS new_table
GROUP BY customer_id
ORDER BY customer_id;

/* 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, 
not just sushi - how many points do customer A and B have at the end of January? */
SELECT customer_id, SUM(points) as total_points
FROM(SELECT s.customer_id, 
       price, (CASE WHEN product_name IS NOT NULL THEN 20
                    END) AS multiplier_effect, 
       (price*(CASE WHEN product_name IS NOT NULL THEN 20 END)) AS points
                       
FROM dannys_diner.sales as s
LEFT JOIN dannys_diner.menu as m
ON s.product_id = m.product_id
LEFT JOIN dannys_diner.members as mem
ON s.customer_id = mem.customer_id
WHERE order_date >= join_date AND order_date <= '2021-01-31'
ORDER BY s.customer_id) AS new_table
GROUP BY customer_id
ORDER BY customer_id;