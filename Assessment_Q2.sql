-- Switch to the target database
USE adashi_staging;

-- Step 1: Calculate number of transactions per customer per month
WITH monthly_tx AS (
    SELECT 
        owner_id,
        -- Truncate transaction_date to the first day of the month for grouping
        DATE_FORMAT(transaction_date, '%Y-%m-01') AS tx_month,
        COUNT(*) AS monthly_tx_count
    FROM savings_savingsaccount
    GROUP BY owner_id, DATE_FORMAT(transaction_date, '%Y-%m-01')
),

-- Step 2: Calculate the average number of transactions per month for each customer
avg_tx AS (
    SELECT 
        owner_id,
        AVG(monthly_tx_count) AS avg_tx_per_month
    FROM monthly_tx
    GROUP BY owner_id
),

-- Step 3: Categorize customers based on average monthly transactions
categorized AS (
    SELECT 
        CASE 
            WHEN avg_tx_per_month >= 10 THEN 'High Frequency'
            WHEN avg_tx_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category,
        avg_tx_per_month
    FROM avg_tx
)

-- Step 4: Summary output showing how many customers fall into each category
SELECT 
    frequency_category,
    COUNT(*) AS customer_count,
    ROUND(AVG(avg_tx_per_month), 1) AS avg_transactions_per_month
FROM categorized
GROUP BY frequency_category;
