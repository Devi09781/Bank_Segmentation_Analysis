-- ============================================
-- CREATE DATABASE
-- ============================================

CREATE DATABASE bank_sys;

-- PostgreSQL:
-- Connect to bank_sys using pgAdmin or psql
-- Do NOT use: USE bank_sys;


-- ============================================
-- 1. TOTAL SPEND PER CUSTOMER
-- ============================================

SELECT 
    c.customer_id,
    c.name,
    SUM(t.amount) AS total_spent
FROM customers c
JOIN accounts a 
    ON c.customer_id = a.customer_id
JOIN transactions t 
    ON a.account_id = t.account_id
WHERE t.transaction_type = 'debit'
GROUP BY c.customer_id, c.name
ORDER BY total_spent DESC;


-- ============================================
-- 2. SALARY TREND ANALYSIS
-- ============================================

SELECT 
    TO_CHAR(
        DATE_TRUNC('month', t.transaction_date),
        'YYYY-MM'
    ) AS month,

    SUM(t.amount) AS total_salary_credited

FROM transactions t

WHERE t.transaction_type = 'credit'
  AND LOWER(t.description) LIKE '%salary credited%'
  AND t.transaction_date >= NOW() - INTERVAL '12 months'

GROUP BY DATE_TRUNC('month', t.transaction_date)
ORDER BY month;


-- ============================================
-- 3. MOST ACTIVE ACCOUNTS
-- ============================================

SELECT 
    t.account_id,
    c.name,
    COUNT(*) AS transaction_count

FROM transactions t

JOIN accounts a
    ON t.account_id = a.account_id

JOIN customers c
    ON a.customer_id = c.customer_id

GROUP BY t.account_id, c.name
ORDER BY transaction_count DESC
LIMIT 10;


-- ============================================
-- 4. MOST ACTIVE ACCOUNTS BY VOLUME
-- ============================================

SELECT 
    t.account_id,
    c.name,
    a.account_number,

    COUNT(*) AS transaction_count,

    SUM(t.amount) AS total_transaction,

    ROUND(AVG(t.amount), 2) AS avg_transaction_size,

    COUNT(
        CASE
            WHEN t.transaction_type = 'debit'
            THEN 1
        END
    ) AS debit_count,

    COUNT(
        CASE
            WHEN t.transaction_type = 'credit'
            THEN 1
        END
    ) AS credit_count,

    SUM(
        CASE
            WHEN t.transaction_type = 'debit'
            THEN t.amount
            ELSE 0
        END
    ) AS total_debit_volume,

    SUM(
        CASE
            WHEN t.transaction_type = 'credit'
            THEN t.amount
            ELSE 0
        END
    ) AS total_credit_volume

FROM transactions t

JOIN accounts a
    ON t.account_id = a.account_id

JOIN customers c
    ON a.customer_id = c.customer_id

GROUP BY
    t.account_id,
    c.name,
    a.account_number

ORDER BY transaction_count DESC
LIMIT 10;


-- ============================================
-- 5. MONTHLY TRANSACTION BREAKDOWN
-- ============================================

SELECT 
    TO_CHAR(
        DATE_TRUNC('month', t.transaction_date),
        'YYYY-MM'
    ) AS month,

    COUNT(*) AS total_transactions,

    SUM(
        CASE
            WHEN t.transaction_type = 'debit'
            THEN 1
            ELSE 0
        END
    ) AS debit_count,

    SUM(
        CASE
            WHEN t.transaction_type = 'credit'
            THEN 1
            ELSE 0
        END
    ) AS credit_count,

    SUM(
        CASE
            WHEN t.transaction_type = 'debit'
            THEN t.amount
            ELSE 0
        END
    ) AS total_debit_volume,

    SUM(
        CASE
            WHEN t.transaction_type = 'credit'
            THEN t.amount
            ELSE 0
        END
    ) AS total_credit_volume,

    SUM(t.amount) AS total_transaction_volume,

    ROUND(AVG(t.amount), 2) AS avg_transaction_size

FROM transactions t

GROUP BY DATE_TRUNC('month', t.transaction_date)

ORDER BY DATE_TRUNC('month', t.transaction_date);


-- ============================================
-- 6. YEARLY TRANSACTION BREAKDOWN
-- ============================================

SELECT 
    TO_CHAR(
        DATE_TRUNC('year', t.transaction_date),
        'YYYY'
    ) AS year,

    COUNT(*) AS total_transactions,

    SUM(
        CASE
            WHEN t.transaction_type = 'debit'
            THEN 1
            ELSE 0
        END
    ) AS debit_count,

    SUM(
        CASE
            WHEN t.transaction_type = 'credit'
            THEN 1
            ELSE 0
        END
    ) AS credit_count,

    SUM(
        CASE
            WHEN t.transaction_type = 'debit'
            THEN t.amount
            ELSE 0
        END
    ) AS total_debit_volume,

    SUM(
        CASE
            WHEN t.transaction_type = 'credit'
            THEN t.amount
            ELSE 0
        END
    ) AS total_credit_volume,

    SUM(t.amount) AS total_transaction_volume,

    ROUND(AVG(t.amount), 2) AS avg_transaction_size

FROM transactions t

GROUP BY DATE_TRUNC('year', t.transaction_date)

ORDER BY DATE_TRUNC('year', t.transaction_date);


-- ============================================
-- 7. TOP 20 HIGH-VALUE CUSTOMERS
-- ============================================

SELECT 
    c.customer_id,
    c.name,
    c.gender,
    c.city,

    COUNT(t.transaction_id) AS credit_transaction_count,

    SUM(t.amount) AS total_credits

FROM transactions t

JOIN accounts a
    ON t.account_id = a.account_id

JOIN customers c
    ON a.customer_id = c.customer_id

WHERE t.transaction_type = 'credit'

GROUP BY
    c.customer_id,
    c.name,
    c.gender,
    c.city

ORDER BY total_credits DESC
LIMIT 20;


-- ============================================
-- 8. DORMANT CUSTOMERS
-- ============================================

SELECT
    c.customer_id,
    c.name,
    c.gender,
    c.city,

    MAX(t.transaction_date) AS last_transaction_date

FROM customers c

JOIN accounts a
    ON c.customer_id = a.customer_id

LEFT JOIN transactions t
    ON a.account_id = t.account_id

GROUP BY
    c.customer_id,
    c.name,
    c.gender,
    c.city

HAVING
    MAX(t.transaction_date)
    < CURRENT_DATE - INTERVAL '12 months'

ORDER BY last_transaction_date;


-- ============================================
-- 9. SINGLE PRODUCT CUSTOMERS
-- CUSTOMERS WITH ONLY ONE ACCOUNT
-- ============================================

SELECT 
    c.customer_id,
    c.name,

    COUNT(a.account_id) AS total_accounts

FROM customers c

JOIN accounts a
    ON c.customer_id = a.customer_id

GROUP BY
    c.customer_id,
    c.name

HAVING COUNT(a.account_id) = 1;


-- ============================================
-- 10. MOST USED TRANSACTION SERVICES
-- ============================================

SELECT 
    description,

    COUNT(*) AS transaction_count,

    SUM(amount) AS total_amount

FROM transactions

GROUP BY description

ORDER BY transaction_count DESC;


-- ============================================
-- 11. CITY-WISE PERFORMANCE
-- ============================================

SELECT 
    c.city,

    COUNT(DISTINCT c.customer_id) AS total_customers,

    COUNT(t.transaction_id) AS total_transactions,

    COALESCE(SUM(t.amount), 0) AS total_transaction_amount,

    ROUND(AVG(t.amount), 2) AS avg_transaction_amount

FROM customers c

LEFT JOIN accounts a
    ON c.customer_id = a.customer_id

LEFT JOIN transactions t
    ON a.account_id = t.account_id

GROUP BY c.city

ORDER BY total_transactions DESC;


-- ============================================
-- 12. ENGAGEMENT BY REGION
-- ============================================

SELECT 
    c.city,

    COUNT(DISTINCT c.customer_id) AS total_customers,

    COUNT(DISTINCT a.account_id) AS total_accounts,

    COUNT(
        DISTINCT CASE
            WHEN t.transaction_date >= CURRENT_DATE - INTERVAL '12 months'
            THEN a.account_id
        END
    ) AS active_accounts,

    COUNT(
        DISTINCT CASE
            WHEN t.transaction_date < CURRENT_DATE - INTERVAL '12 months'
            THEN a.account_id
        END
    ) AS dormant_accounts

FROM customers c

LEFT JOIN accounts a
    ON c.customer_id = a.customer_id

LEFT JOIN transactions t
    ON a.account_id = t.account_id

GROUP BY c.city

ORDER BY total_customers DESC;


-- ============================================
-- 13. HIGHEST SPENDER BY CITY
-- ============================================

WITH customer_spending AS (

    SELECT 
        c.customer_id,
        c.name,
        c.city,

        SUM(t.amount) AS total_spent

    FROM customers c

    JOIN accounts a
        ON c.customer_id = a.customer_id

    JOIN transactions t
        ON a.account_id = t.account_id

    WHERE t.transaction_type = 'debit'

    GROUP BY
        c.customer_id,
        c.name,
        c.city
)

SELECT DISTINCT ON (city)

    city,
    name,
    total_spent

FROM customer_spending

ORDER BY
    city,
    total_spent DESC;