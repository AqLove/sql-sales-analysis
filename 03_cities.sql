-- Вопрос: какие города приносят деньги и где теряем больше всего на отменах?
-- По городам: заказы, оплаченная выручка, доля отмен в %, доля города в общей выручке.
-- Приём: CTE с условной агрегацией по городу -> снаружи доля от общего итога через окно SUM(...) OVER ().
with city_status as (
select u.city,     
count(o.order_id) as orders_cnt,
ROUND(SUM(case when o.status = 'paid' then o.amount else 0 end), 2) as paid_revenue,
round(100.0 * SUM(case when o.status = 'cancelled' then 1 else 0 end) / count(o.order_id), 1) as cancel_pct
from users u
join orders o using(user_id)
group by u.city
)
select city, orders_cnt, paid_revenue, cancel_pct,
ROUND(paid_revenue / sum(paid_revenue) over() * 100, 1) as revenue_share
from city_status
order by paid_revenue desc;

-- Вывод: Алматы — главный рынок: 38.9% выручки и самый низкий уровень отмен (13.8%).
-- Астана — второй рынок (20.5% выручки), но отмен 17.9% — второе место с конца после Караганды (18.1%).
-- По штукам больше всего отмен в Алматы (86), но это эффект размера: сравнивать группы разного размера нужно в %.
-- Рекомендация: перенести практики Алматы в Астану; снижение отмен в Астане до 13.8% ≈ −16 отмен ≈ +22 тыс. выручки.
