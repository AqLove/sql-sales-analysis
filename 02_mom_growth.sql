-- Вопрос: на сколько процентов растёт выручка каждый месяц и были ли месяцы падения?
-- MoM growth (month-over-month) = (выручка месяца - выручка прошлого) / выручка прошлого * 100.
-- Приём: CTE monthly (GROUP BY) -> вторая CTE с LAG (считаем один раз и даём имя) -> рост по алиасу.
with monthly as (
    select DATE_TRUNC('month', created_at)::date as month,
           ROUND(SUM(case when status = 'paid' then amount else 0 end), 2) as paid_revenue
    from orders
    group by month
),
prev_revenue as (
    select month,
           paid_revenue,
           lag(paid_revenue) over (order by month) as prev_revenue
    from monthly
)
select month,
       paid_revenue,
       prev_revenue,
       ROUND((paid_revenue - prev_revenue) / prev_revenue * 100, 1) as growth_pct
from prev_revenue
order by month;

-- Вывод: из 21 месяца с прошлым значением выручка росла в 14, падала в 7.
-- В 2026 году средний рост ~21% в месяц; последние три месяца подряд рост: +39.6%, +19.2%, +24.2%.
-- Первые месяцы 2025 дают +195% / +187% — эффект маленькой базы, для выводов их не берём.
