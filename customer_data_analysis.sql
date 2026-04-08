select * from customer limit 20

--Q1. what is the total revenue genrated by the female vs male cutomers?
SELECT gender,
	   SUM(purchase_amount) AS revenue
FROM customer
GROUP BY gender;

--Q2. Which customers used a discount but still spent more than the avarage purchase amount?
SELECT customer_id,
	   purchase_amount
FROM customer
WHERE discount_applied = 'Yes'
	  AND purchase_amount > (SELECT AVG(purchase_amount)
	                         FROM customer)
								
--Q3. Which are the top 5 products with the highest average review rating?
SELECT item_purchased,
	    ROUND(AVG(review_rating::numeric),2) AS average_product_rating
FROM customer
GROUP BY item_purchased
ORDER BY average_product_rating DESC
LIMIT 5;

--Q4. Compare the average purchase amounts between Standard and Express shipping?
SELECT shipping_type,
	   ROUND(AVG(purchase_amount),2) AS total_amount
FROM customer
WHERE shipping_type in ('Standard','Express')
GROUP BY shipping_type;

--Q5. Do subscribed customers spend more? Compare average spend and total revenue btn subscribers & non-subscribers?
SELECT subscription_status, 
	   COUNT(customer_id) AS total_customers,
	   Round(AVG(purchase_amount),2) AS avg_spend,
	   SUM(purchase_amount) AS total_revenue
FROM customer
GROUP BY subscription_status;

--Q6. Which 5 products have the highest percentage of purchases with discounts applied?
SELECT item_purchased,
	   ROUND((100* COUNT(*)FILTER(WHERE discount_applied = 'Yes'))/ COUNT(*) ,2) AS discount_percentage
FROM customer
GROUP BY item_purchased
ORDER BY discount_percentage DESC
LIMIT 5;

--Q7. Segment customers into New, Returning, Loyal based on their total no of previous purchases.
WITH customer_type AS(
SELECT customer_id,previous_purchases,
CASE
	WHEN previous_purchases = 1 THEN 'New'
	WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Returning'
	ELSE 'Loyal'
	END AS customer_segment
FROM customer
)
SELECT customer_segment,
	   COUNT(customer_id)
FROM customer_type
GROUP BY customer_segment;

-- Q8. What are the top 3 most purchased products within each category?
SELECT category,
	   item_purchased,
	   purchase_count
FROM(
	 SELECT category,
	 		item_purchased,
	 		COUNT(*) AS purchase_count,
	 ROW_NUMBER() OVER(
	 	PARTITION BY category
		ORDER BY count(*) DESC
	 )AS rn
	 FROM customer
	 GROUP BY category,item_purchased
	 )
WHERE rn<=3;

--Q9. Are customers who are repeat buyers(more than 5 previous purchases) are also likely to subscribe?
SELECT subscription_status,
	   COUNT(customer_id) AS repeated_buyers
FROM customer
WHERE previous_purchases>5
GROUP BY subscription_status;

--Q10. What is the revenue contribution of each age group?
SELECT age_group,
	   SUM(purchase_amount) AS total_revenue
FROM customer
GROUP BY age_group
ORDER BY total_revenue DESC;