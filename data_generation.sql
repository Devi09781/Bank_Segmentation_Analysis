-- ============================================
-- 1. INSERT 200 REALISTIC NIGERIAN CUSTOMERS
-- ============================================

INSERT INTO customers (name, gender, dob, signup_date, city)
SELECT
    first_names[1 + floor(random() * array_length(first_names, 1))::int]
    || ' ' ||
    last_names[1 + floor(random() * array_length(last_names, 1))::int] AS name,

    CASE
        WHEN random() < 0.5 THEN 'M'
        ELSE 'F'
    END AS gender,

    -- Date of birth between 1970 and 1997
    DATE '1970-01-01'
        + floor(random() * 10227)::int AS dob,

    -- Signup date within the last 3 years
    CURRENT_DATE
        - floor(random() * 1095)::int AS signup_date,

    cities[1 + floor(random() * array_length(cities, 1))::int] AS city

FROM generate_series(1, 200)

CROSS JOIN LATERAL (
    SELECT
        ARRAY[
            'Chinedu', 'Aisha', 'Tunde', 'Ngozi', 'Bola',
            'Obinna', 'Fatima', 'Yakubu', 'Emeka', 'Zainab',
            'Ifeanyi', 'Uche', 'Abubakar', 'Lilian', 'Segun',
            'Halima', 'Adesuwa', 'Kehinde', 'Mercy', 'Emmanuel'
        ] AS first_names,

        ARRAY[
            'Okonkwo', 'Balogun', 'Adegoke', 'Nwachukwu', 'Danjuma',
            'Adelaja', 'Ibrahim', 'Umeh', 'Ogunleye', 'Abiola',
            'Mohammed', 'Eze', 'Lawal', 'Obi', 'Ahmed',
            'Onyeka', 'Nwabueze', 'Ajibade', 'Suleman', 'Johnson'
        ] AS last_names,

        ARRAY[
            'Lagos', 'Abuja', 'Port Harcourt', 'Enugu',
            'Kano', 'Ibadan', 'Jos', 'Abeokuta',
            'Calabar', 'Owerri', 'Benin City', 'Kaduna'
        ] AS cities
) AS name_data;


-- ============================================
-- 2. INSERT ACCOUNTS
-- 1 OR 2 ACCOUNTS PER CUSTOMER
-- ============================================

INSERT INTO accounts (
    customer_id,
    account_number,
    account_type,
    open_date,
    balance
)
SELECT
    c.customer_id,

    -- Random 10-digit account number
    LPAD(
        floor(random() * 10000000000)::bigint::text,
        10,
        '0'
    ) AS account_number,

    (
        ARRAY['savings', 'current', 'loan']
    )[1 + floor(random() * 3)::int] AS account_type,

    c.signup_date
        + floor(random() * 90)::int AS open_date,

    ROUND(
        (1000 + random() * 499000)::numeric,
        2
    ) AS balance

FROM customers c

CROSS JOIN generate_series(1, 2) AS dup(n)

WHERE random() < 0.75

ORDER BY c.customer_id

LIMIT 1000;


-- ============================================
-- 3. INSERT 1000 TRANSACTIONS
-- ============================================

INSERT INTO transactions (
    account_id,
    transaction_type,
    amount,
    transaction_date,
    description
)
SELECT
    a.account_id,

    CASE
        WHEN random() < 0.5 THEN 'debit'
        ELSE 'credit'
    END AS transaction_type,

    ROUND(
        (500 + random() * 249500)::numeric,
        2
    ) AS amount,

    NOW()
        - floor(random() * 730)::int * INTERVAL '1 day'
        AS transaction_date,

    CASE
        WHEN random() < 0.5 THEN
            (
                ARRAY[
                    'Salary credited',
                    'Bank transfer from GTBank',
                    'Credit alert from Zenith',
                    'Reversal of failed transaction',
                    'Loan disbursement',
                    'Wallet top-up',
                    'Refund from vendor',
                    'POS reversal',
                    'Received from customer',
                    'Online payment received',
                    'Cash deposit'
                ]
            )[1 + floor(random() * 11)::int]

        ELSE
            (
                ARRAY[
                    'POS payment at Shoprite',
                    'MTN Airtime recharge',
                    'Fuel purchase at Mobil',
                    'Electricity bill payment',
                    'Loan EMI debit',
                    'House rent payment',
                    'Online purchase at Jumia',
                    'Cash withdrawal from ATM',
                    'Subscription payment',
                    'Insurance premium debit',
                    'Bank transfer to Fidelity Bank'
                ]
            )[1 + floor(random() * 11)::int]
    END AS description

FROM accounts a

CROSS JOIN generate_series(1, 10) AS gs

ORDER BY random()

LIMIT 1000;


-- ============================================
-- 4. VERIFY TRANSACTION TYPES
-- ============================================

SELECT
    transaction_type,
    COUNT(*) AS total_transactions
FROM transactions
GROUP BY transaction_type;


-- ============================================
-- 5. CHECK DESCRIPTION VARIETY
-- ============================================

SELECT
    description,
    COUNT(*) AS total_transactions
FROM transactions
GROUP BY description
ORDER BY total_transactions DESC;


-- ============================================
-- 6. COUNT TOTAL TRANSACTIONS
-- ============================================

SELECT
    COUNT(*) AS total_transactions
FROM transactions;


-- ============================================
-- 7. VIEW INSERTED DATA
-- ============================================

SELECT *
FROM customers;

SELECT *
FROM accounts;

SELECT *
FROM transactions;