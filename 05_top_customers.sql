-- Вопрос (отдел продаж, VIP-программа): кто наши лучшие клиенты и насколько выручка зависит от них?
-- Топ-10 клиентов по оплаченной выручке: доля каждого и накопительная доля (cumulative share).
-- Приём: CTE выручка на клиента -> окна: SUM() OVER () = итог, SUM() OVER (ORDER BY ... DESC) = накопительная сумма.
-- LIMIT срабатывает после окон, поэтому доли считаются от выручки всех 238 клиентов, а не только топ-10.
WITH user_revenue AS 
(SELECT o.user_id, 
ROUND(SUM(CASE WHEN o.status = 'paid' THEN o.amount ELSE 0 END), 2) AS revenue
FROM orders o
GROUP BY o.user_id)
SELECT user_id, revenue,
ROUND(revenue / SUM(revenue) OVER() * 100, 1) AS share_pct,
ROUND(SUM(revenue) OVER(ORDER BY revenue DESC) / SUM(revenue) OVER() * 100, 1) AS cum_share_pct
FROM user_revenue
ORDER BY revenue DESC
LIMIT 10;

-- Вывод: топ-10 клиентов (4% покупателей) приносят 8.2% выручки, каждый — меньше 1%.
-- Топ-20% клиентов (48 человек) дают 32.6% выручки — далеко от «правила 80/20».
-- Значит, бизнес не зависит от горстки крупных клиентов: уход любого из них почти не заметен.
-- Рекомендация: VIP-программа на 10 человек мало что даст выручке; выгоднее программа лояльности
-- для широкой базы и работа с конверсией и отменами (задачи 3–4).
