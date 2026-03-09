select * from customer limit 20

-- 1 Qual é a receita total gerada por clientes do sexo masculino em comparacao com clientes do sexo feminino?
select gender, SUM(purchase_amount) as revenue
from customer
group by gender 

-- 2 Quais clientes utilizaram um desconto, mas ainda assim gastaram mais do que o valor médio de compra?
select customer_id, purchase_amount
from customer
where discount_applied = 'Yes' and purchase_amount >= (select AVG(purchase_amount) from customer)

-- 3 Quais são os 5 produtos com a maior classificação média de avaliação?
select item_purchased, ROUND(AVG(review_rating::numeric),2) as "Average Product Rating"
from customer 
group by item_purchased
order by avg(review_rating) desc
limit 5;

-- 4 Compare os valores médios de compra entre o frete padrão e o frete expresso.
select shipping_type,
ROUND (AVG(purchase_amount),2)
from customer
where shipping_type in ('Standard', 'Express')
group by shipping_type

-- 5 Os clientes assinantes gastam mais? Compare o gasto médio e a receita total entre assinantes e não assinantes.
select subscription_status,
COUNT (customer_id) as total_customers,
ROUND(AVG(purchase_amount),2) as avg_spend,
ROUND(SUM(purchase_amount),2) as total_revenue
from customer
group by subscription_status
order by total_revenue, avg_spend desc;

-- 6 Quais são os 5 produtos com a maior porcentagem de compras com descontos aplicados?
select item_purchased,
ROUND(100 * SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END)/ COUNT (*),2) as discount_rate
from customer
group by item_purchased
order by discount_rate desc
limit 5;

-- 7 Segmente os clientes em Novos, Recorrentes e Fiéis com base no número total de compras anteriores e mostre a contagem de cada segmento.
with customer_type as (
select customer_id, previous_purchases,
CASE
	WHEN previous_purchases = 1 THEN 'New'
	WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Returning'
	ELSE 'Loyal'
	END AS customer_segment
from customer
)
select customer_segment, count(*) as "Number of Customers"
from customer_type
group by customer_segment

-- 8 Quais são os 3 produtos mais comprados em cada categoria?
WITH item_counts AS (
    SELECT category,
           item_purchased,
           COUNT(customer_id) AS total_orders,
           ROW_NUMBER() OVER (PARTITION BY category ORDER BY COUNT(customer_id) DESC) AS item_rank
    FROM customer
    GROUP BY category, item_purchased
)
SELECT item_rank,category, item_purchased, total_orders
FROM item_counts
WHERE item_rank <=3;
-- 9 Os clientes que compram com mais frequência (mais de 5 compras anteriores) também têm maior probabilidade de assinar?
SELECT subscription_status,
       COUNT(customer_id) AS repeat_buyers
FROM customer
WHERE previous_purchases > 5
GROUP BY subscription_status;

-- 10 Qual é a contribuição de cada faixa etária para a receita?
SELECT age_group,
SUM(purchase_amount) AS total_revenue
FROM customer
GROUP BY age_group
ORDER BY total_revenue desc;
