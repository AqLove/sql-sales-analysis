-- Вопрос: растёт ли магазин и какая доля заказов отменяется?
-- Помесячно: все заказы, оплаченная выручка, доля отмен в %.
-- Приём: условная агрегация SUM(CASE ...), деление через 100.0 (иначе целочисленное).
SELECT DATE_TRUNC('month', created_at) AS month,
       COUNT(order_id) AS orders_cnt,
       ROUND(SUM(CASE WHEN status = 'paid' THEN amount ELSE 0 END), 2) AS paid_revenue,
       ROUND(100.0 * SUM(CASE WHEN status = 'cancelled' THEN 1 ELSE 0 END) / COUNT(order_id), 1) AS cancel_pct
FROM orders
GROUP BY month
ORDER BY month;

-- Вывод: заказы выросли с 1 (янв 2025) до 320 (окт 2026), выручка за окт 2026 ~286 тыс.
-- Доля отмен скачет 11-20% без тренда; в среднем 16.1% — каждый 6-й заказ.
-- Отменено заказов на ~405 тыс. (для сравнения: оплачено ~1.78 млн).
