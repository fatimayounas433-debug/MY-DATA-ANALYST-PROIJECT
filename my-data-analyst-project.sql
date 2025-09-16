-- CUSTOMERS TABLE
CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(50),
    city VARCHAR(50),
    age INT
);

-- PRODUCTS TABLE
CREATE TABLE Products (
    product_id INT PRIMARY KEY,
    name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2)
);

-- ORDERS TABLE
CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    product_id INT,
    order_date DATE,
    quantity INT,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

INSERT INTO Customers (customer_id, name, city, age) VALUES
(1, 'Ali Khan', 'Lahore', 28),
(2, 'Sara Malik', 'Karachi', 34),
(3, 'Bilal Ahmed', 'Islamabad', 22),
(4, 'Fatima Noor', 'Lahore', 30),
(5, 'Usman Tariq', 'Faisalabad', 27);

-- PRODUCTS
INSERT INTO Products (product_id, name, category, price) VALUES
(101, 'Laptop', 'Electronics', 85000.00),
(102, 'Smartphone', 'Electronics', 55000.00),
(103, 'Book - SQL Basics', 'Books', 1200.00),
(104, 'Headphones', 'Accessories', 3500.00),
(105, 'Washing Machine', 'Home Appliances', 45000.00);

-- ORDERS
INSERT INTO Orders (order_id, customer_id, product_id, order_date, quantity) VALUES
(1001, 1, 101, '2025-08-01', 1),
(1002, 2, 103, '2025-08-03', 2),
(1003, 3, 102, '2025-08-05', 1),
(1004, 1, 104, '2025-08-07', 3),
(1005, 4, 105, '2025-08-09', 1),
(1006, 5, 103, '2025-08-10', 1);


select*
from customers as C;

select*
from products as P;

select* 
from orders as O;


-----  show all customers from lahore 

select * from customers  where city = 'Lahore'; 

----- list all products with a price above 10,000


         select*  from products where price > 10000;
         
   ----- find all orders placed in agust 2025 
    SELECT *
FROM Orders
WHERE MONTH(order_date) = 8
  AND YEAR(order_date) = 2025;
  
  
   ----- display order with cust name, product name,quantity and orders_date
	select    C.name,
  P.name,
   O.quantity,
    O.order_date
    from orders  O
    join customers   C
                ON C.customer_id = O.customer_id
	join products P
              on P.product_id = O.product_id
	order by O.order_date ;
    
    select distinct C . name 
    from customers C 
    join orders O
        on C.customer_id = O.customer_id
        join products P
             on P. product_id = O.product_id
               where P.category = 'Electronics';
      ----- aggregation calculate total revenue (quanity * price)
      
     
SELECT 
    SUM(O.quantity * P.price) AS total_revenue
FROM orders O
JOIN products P 
    ON O.product_id = P.product_id;


      ----- total revenue par city 
      
    
      
  SELECT 
    c.city,
    SUM(o.quantity * p.price) AS total_revenue
FROM orders o
JOIN customers c 
    ON o.customer_id = c.customer_id
JOIN products p
    ON o.product_id = p.product_id
GROUP BY c.city
ORDER BY total_revenue DESC;
-- find most sold products 
select max(O.quantity )AS MAX_QUANTITY, P.name 
from orders O
join products P
            on 
            P.product_id = O.product_id
            GROUP BY P.name
            order by max(O.quantity ) desc ;
            
            -- find total revene per cutomer per city
            
            select  sum(O.quantity* P.price) as total_revenue , C.name, city 
            from customers C 
            join orders O  
                 on C.customer_id = O.customer_id
            join products P 
                  On P.product_id = O.product_id
                  group by C.name, city ;
                  
	
	-- Top 3 products by revenue in each category 
            
WITH ranked_products2 AS (
    SELECT 
        P.category,
        SUM(O.quantity * P.price) AS total_revenue,
        ROW_NUMBER() OVER (PARTITION BY P.category ORDER BY  SUM(O.quantity * P.price) DESC) AS row_num
    FROM products P  
    JOIN orders O 
        ON P.product_id = O.product_id
    GROUP BY P.category
)
SELECT *
FROM ranked_products2
WHERE row_num <= 3;

  ----- MONTHLY REVENUE GROWTH PAR CITY 
  
   WITH MONTH_REVENUE AS ( 
   SELECT 
   C.city, 
   date_format(O.order_date, '%Y-%M') AS  order_month,
   SUM(O.quantity * P.price) AS total_revenue
   from orders O
   join Products P 
           on P.product_id = O.product_id 
	join customers C
                on   C.customer_id = O.customer_id 
                  group by    C.city, order_month
                  ) ,
                  revenue_growth as
                  (
                  select 
                 city,
                   order_month,
					total_revenue,
                 LAG(total_revenue) OVER (PARTITION BY city ORDER BY order_month)  AS previous_month,
				 (total_revenue - LAG(total_revenue) OVER (PARTITION BY city ORDER BY order_month)) AS revenue_growth
                    from MONTH_REVENUE
                    )
                    select* 
                    from  revenue_growth
                    order by city,order_month;
			
----- CUSTOMERS WHO PLACES MORE THAN 5 ORDER BUT APENT LESS THAN AVERGAE VALUE 

SELECT 
C.CUSTOMER_ID,
C. name,
count(O.order_id) as  total_orders,
sum(O.quantity*P.price) as  total_revenue 
from customers C   
JOIN orders O
             on C.customer_id = O.Customer_id 
join products P 
           on P.product_id = O.product_id 
	group by C.CUSTOMER_ID,
C. name
	having count(order_id) > 5 
    and  sum(O.quantity*P.price) < (
    select   avg(total_revenue)
    FROM ( SELECT 
sum(O2.quantity*P2.price) as  total_revenue 
from customers C2 
JOIN orders O2
             on C2.customer_id = O2.Customer_id 
join products P2
           on P2.product_id = O2.product_id 
 GROUP BY C2.customer_id, C2.name
 ) AS CUSTOMER_totals
 );
    
                
SELECT  
    C.customer_id,
    C.name,
    COUNT(O.order_id) AS total_orders,
    SUM(O.quantity * P.price) AS total_revenue
FROM orders O
JOIN products P 
    ON P.product_id = O.product_id 
JOIN customers C
    ON C.customer_id = O.customer_id
GROUP BY C.customer_id, C.name
HAVING COUNT(O.order_id) > 5
   AND SUM(O.quantity * P.price) < (
        SELECT AVG(total_revenue)
        FROM (
            SELECT SUM(O2.quantity * P2.price) AS total_revenue
            FROM orders O2
            JOIN products P2 
                ON P2.product_id = O2.product_id 
            JOIN customers C2
                ON C2.customer_id = O2.customer_id
            GROUP BY C2.customer_id, C2.name
        ) AS customer_totals
   );
	
    
    ----- find customers who bought from all categories 
               SELECT C.name
FROM customers C
JOIN orders O 
    ON C.customer_id = O.customer_id
JOIN products P 
    ON O.product_id = P.product_id
GROUP BY C.name
HAVING COUNT(DISTINCT P.category) = (
    SELECT COUNT(DISTINCT category) FROM products
);  
 highest revenue product per city 
           WITH ranked AS (
    SELECT 
        C.city,
        P.name AS product_name,
        SUM(O.quantity * P.price) AS total_revenue,
        RANK() OVER (
            PARTITION BY C.city
            ORDER BY SUM(O.quantity * P.price) DESC
        ) AS revenue_rank
    FROM products P
    JOIN orders O 
        ON P.product_id = O.product_id
    JOIN customers C
        ON C.customer_id = O.customer_id
    GROUP BY C.city, P.name
)
SELECT *
FROM ranked
WHERE revenue_rank = 1;
