-- Switch to the target database
USE adashi_staging;

-- Step 1: Get the last transaction date for both savings and investment accounts
WITH last_tx AS (
    -- Get latest transaction date for each savings account
    SELECT 
        id AS plan_id,
        owner_id,
        'Savings' AS type,
        MAX(transaction_date) AS last_transaction_date
    FROM savings_savingsaccount
    GROUP BY id, owner_id

    UNION

    -- Get latest charge date for each investment account
    SELECT 
        id AS plan_id,
        owner_id,
        'Investment' AS type,
        MAX(last_charge_date) AS last_transaction_date
    FROM plans_plan
    GROUP BY id, owner_id
)

-- Step 2: Filter accounts with no transaction in the last 365 days
SELECT 
    plan_id,
    owner_id,
    type,
    DATE(last_transaction_date) AS last_transaction_date,  -- Extract only the date portion
    DATEDIFF(CURDATE(), DATE(last_transaction_date)) AS inactivity_days  -- Days since last activity
FROM last_tx
WHERE last_transaction_date <= CURDATE() - INTERVAL 365 DAY;  -- Inactive for more than a year
