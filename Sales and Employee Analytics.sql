/*
 * Question 1: List of Customers and Their Orders
Task: Write an SQL query to list all customers and their corresponding order IDs. Include customers who have not placed any orders.

 
select 
	customers.customer_id, 
	orders.order_id
from customers 
left join orders 
	on customers.customer_id = orders.customer_id 

 * Question 2: Total Sales for Each Product
Task: Write an SQL query to find the total sales amount for each product, including the product name.



select 
	products.product_name,
	sum((order_details.unit_price * order_details.quantity) - 
	          ((order_details.unit_price * order_details.quantity * order_details.discount)/100)) as total_sales
from products 
left join order_details 
	on products.product_id = order_details.product_id 
group by 
	products.product_name 


  *  Question 3: Employees and the Number of Orders They Handled
Task: Write an SQL query to count the number of orders handled by each employee. Include the employee's first and last name.



select 
	employees.first_name,
	employees.last_name,
	count(orders.order_id) as number_of_orders
from orders 
left join employees 
	on orders.employee_id = employees.employee_id 
group by 
	employees.employee_id 


  * Question 4: Customers Who Have Not Ordered in 1998
Task: Identify all customers who did not place an order in 1998.



select 
	customer_id,
	order_date 
from orders 
where (order_date < '1998-01-01') or (order_date >'1998-12-31')


  * Question 5: Highest Selling Product Categories
Task: Find the highest selling product categories based on total sales volume.



select 
	categories.category_name,
	sum( order_details.quantity)  as total_sales_volume
from order_details 
left join products
	on order_details.product_id = products.product_id 
left join categories 
	on products.category_id = categories.category_id 
group by 
	categories.category_name
order by 
	total_sales_volume desc
 


  * Question 6: List Suppliers and Their Products Count
Task: Write an SQL query to list all suppliers along with the number of products they supply. 
Include suppliers who do not supply any products.



select
	suppliers.contact_name,
	count(products.product_id) as number_of_products
from suppliers 
left join products
	on suppliers.supplier_id  = products.supplier_id 
group by 
	suppliers.contact_name
order by 
	number_of_products


  * Question 7: Customers with Orders Over $500
Task: Identify customers whose total order amount exceeds $500. Show customer ID and total amount.



select 
	orders.customer_id,
	cast(sum(order_details.unit_price * order_details.quantity) as decimal (10,2)) as total_order_amount
from orders 
left join order_details 
	on orders.order_id = order_details.order_id 
group by 
	orders.customer_id
having 
	sum(order_details.unit_price * order_details.quantity)>500
order by 
	total_order_amount desc
	
	
	* Question 8: Employees with More Than 50 Orders
Task: Write an SQL query to find employees who have processed more than 50 orders. 
Include employee ID, last name, and the number of orders processed.


select 
	orders.employee_id,
	count(orders.order_id) as number_of_orders,
	employees.last_name 
from orders 
left join employees 
	on orders.employee_id = employees.employee_id 
group by
	orders.employee_id,
	employees.last_name
having 
	count(orders.order_id)>50
order by 
	number_of_orders desc
	

 * Question 9: Detailed Order Information
Task: Provide detailed information for each order, 
including order ID, customer company name, employee last name, and total order amount.

employees - order_details - customer

select 
	od.order_id,
	c.company_name, 
	e.last_name,
	round(sum(od.unit_price * od.quantity)::numeric,
	3) as total_amount
from
	order_details od
left join orders o
	on
	od.order_id = o.order_id
left join customers c
	on
	o.customer_id = c.customer_id
left join employees e
	on
	o.employee_id = e.employee_id
group by
	od.order_id,
	c.company_name,
	e.last_name
order by
	od.order_id;

with order_sum as(
select od.order_id,round(sum(od.unit_price * od.quantity)::numeric,
	3) as total_amount from order_details od group by od.order_id
)
select o.order_id,os.total_amount from orders o left join order_sum os on os.order_id=o.order_id ;




  * Question 10: Average Product Price by Category
Task: Calculate the average price of products in each category.



select 
	p.product_name,
	cast(avg(p.unit_price) as decimal(10,2)) as average_price,
	c.category_name 
from 
	products p 
left join categories c 
	on
	p.category_id = c.category_id 
group by 
	c.category_name,
	p.product_name

 * Question 11: Top 3 Most Frequently Ordered Products Per Category
Task: Write an SQL query to find the top three most frequently ordered products in each category based on the quantity ordered.


with most_frequently_ordered_products as 
(
select
	p.product_name,
	sum(od.quantity) as number_of_orders,
	c.category_name,
	row_number() over (partition by c.category_name
order by
	sum(od.quantity) desc) as rank
from
	products p
left join categories c 
	on 
	p.category_id = c.category_id
left join order_details od 
	on 
	p.product_id = od.product_id
group by 
	c.category_name,
	p.product_name
)

select 
	category_name,
	product_name,
	number_of_orders
from
	most_frequently_ordered_products
where
	rank <= 3
order by 
	category_name,
	rank
	
	
	* Question 12: Sales Trends by Quarter
Task: Calculate the total sales for each quarter of each year and 
identify quarters that showed a growth in sales over the previous quarter.

SELECT 
  year_quarter,
  total_sales,
  LAG(total_sales) OVER (ORDER BY year_quarter) AS previous_quarter_sales,
  CASE 
    WHEN total_sales > LAG(total_sales) OVER (ORDER BY year_quarter) THEN 'Growth'
    WHEN total_sales < LAG(total_sales) OVER (ORDER BY year_quarter) THEN 'Decline'
    ELSE 'No Change'
  END AS trend
FROM (
  -- Subquery to calculate total sales per quarter
  SELECT 
    TO_CHAR(orders.order_date, 'YYYY-"Q"Q') AS year_quarter,
    SUM(order_details.unit_price * order_details.quantity) AS total_sales
  FROM orders
  LEFT JOIN order_details 
  ON orders.order_id = order_details.order_id 
  GROUP BY TO_CHAR(orders.order_date, 'YYYY-"Q"Q')
  ORDER BY year_quarter
) AS quarterly_sales
ORDER BY year_quarter;
 
 
 
 	* Question 13: Customer Retention Rate
Task: Write an SQL query to calculate the retention rate of customers from year to year.
	
*/

WITH CustomersPerYear AS (
    SELECT 
        customers.customer_id, 
        EXTRACT(YEAR FROM orders.order_date) AS order_year
    FROM 
        customers
    JOIN 
        orders ON customers.customer_id = orders.customer_id
    GROUP BY 
        customers.customer_id, EXTRACT(YEAR FROM orders.order_date)
),
CustomerRetention AS (
    SELECT 
        c1.order_year AS year, 
        COUNT(DISTINCT c1.customer_id) AS total_customers,
        COUNT(DISTINCT c2.customer_id) AS retained_customers
    FROM 
        CustomersPerYear c1
    LEFT JOIN 
        CustomersPerYear c2 ON c1.customer_id = c2.customer_id 
        AND c1.order_year = c2.order_year - 1
    GROUP BY 
        c1.order_year
)
SELECT 
    year,
    total_customers,
    retained_customers,
    (retained_customers::FLOAT / total_customers) * 100 AS retention_rate
FROM 
    CustomerRetention
WHERE 
    retained_customers IS NOT NULL
ORDER BY 
    year;

/*
 * Question 14: Total Sales Weighted by Order Freight Cost
#### Task: Determine total sales weighted by the freight cost of each order.
*/

SELECT 
    SUM(order_details.unit_price * order_details.quantity * (1 - order_details.discount) * orders.freight) AS total_weighted_sales
FROM 
    order_details
JOIN 
    orders ON order_details.order_id = orders.order_id;
 



























		
