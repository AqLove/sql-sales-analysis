-- Учебная база для практики SQL: users + orders.
-- Запуск: psql -U postgres -f create_db.sql
-- Данные генерируются одинаково при каждом запуске (setseed), можно пересоздать в любой момент.

DROP DATABASE IF EXISTS analytics;
CREATE DATABASE analytics;
\connect analytics

CREATE TABLE users (
    user_id       INT PRIMARY KEY,
    city          TEXT NOT NULL,
    registered_at TIMESTAMP NOT NULL
);

CREATE TABLE orders (
    order_id   INT PRIMARY KEY,
    user_id    INT NOT NULL REFERENCES users (user_id),
    amount     NUMERIC(10, 2) NOT NULL,
    created_at TIMESTAMP NOT NULL,
    status     TEXT NOT NULL CHECK (status IN ('paid', 'cancelled', 'pending'))
);

SELECT setseed(0.42);

-- 300 пользователей, регистрация с января 2025 по сентябрь 2026
INSERT INTO users (user_id, city, registered_at)
SELECT
    g,
    (ARRAY['Алматы', 'Алматы', 'Алматы', 'Астана', 'Астана', 'Шымкент',
           'Караганда', 'Тараз', 'Актобе', 'Павлодар'])[1 + floor(random() * 10)::INT],
    TIMESTAMP '2025-01-01' + random() * (TIMESTAMP '2026-09-30' - TIMESTAMP '2025-01-01')
FROM generate_series(1, 300) AS g;

-- Заказы: у ~15% пользователей заказов нет, у остальных от 1 до 12.
-- Средний чек зависит от города, чтобы в задачах были разные результаты.
INSERT INTO orders (order_id, user_id, amount, created_at, status)
SELECT
    row_number() OVER (ORDER BY o.created_at),
    o.user_id,
    o.amount,
    o.created_at,
    o.status
FROM (
    SELECT
        u.user_id,
        round(((300 + random() * 1500) * CASE u.city
            WHEN 'Алматы' THEN 1.4
            WHEN 'Астана' THEN 1.3
            WHEN 'Шымкент' THEN 0.9
            WHEN 'Караганда' THEN 1.0
            WHEN 'Тараз' THEN 0.75
            WHEN 'Актобе' THEN 0.95
            ELSE 0.8
        END)::NUMERIC, 2) AS amount,
        u.registered_at + random() * (TIMESTAMP '2026-10-31' - u.registered_at) AS created_at,
        CASE
            WHEN random() < 0.75 THEN 'paid'
            WHEN random() < 0.6 THEN 'cancelled'
            ELSE 'pending'
        END AS status
    FROM users u
    CROSS JOIN LATERAL generate_series(1, 1 + floor(random() * 12)::INT) AS n
    WHERE u.user_id % 7 <> 0 AND u.user_id % 13 <> 0
) AS o;

SELECT
    (SELECT count(*) FROM users) AS users,
    (SELECT count(*) FROM orders) AS orders;
