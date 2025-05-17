-- Switch to the target database
USE adashi_staging;

-- Step 1: Summarize each user's transaction data and compute tenure
WITH user_tx_summary AS (
    SELECT 
        u.id AS customer_id,
        
        -- Prioritize displaying name, then username, then email as a fallback
        COALESCE(
            NULLIF(u.name, ''),          -- Use name if not empty
            NULLIF(u.username, ''),      -- Else use username if not empty
            u.email,                     -- Else fallback to email
            'Unknown'                    -- Final fallback if all are null/empty
        ) AS name,

        -- Calculate how many months the customer has been on the platform
        TIMESTAMPDIFF(MONTH, u.date_joined, CURRENT_DATE) AS tenure_months,

        -- Count how many savings transactions the customer has
        COUNT(s.id) AS total_transactions,

        -- Sum confirmed deposits and convert from Kobo to Naira
        SUM(s.confirmed_amount) / 100.0 AS total_amount_naira

    FROM users_customuser u
    LEFT JOIN savings_savingsaccount s ON u.id = s.owner_id
    GROUP BY u.id, u.name, u.username, u.email, u.date_joined
),

-- Step 2: Calculate average profit per transaction and estimated CLV
clv_calc AS (
    SELECT *,
        -- Assume profit per transaction is 0.1% (i.e., 0.001 multiplier)
        -- Guard against division by zero using NULLIF
        (total_amount_naira * 0.001) / NULLIF(total_transactions, 0) AS avg_profit_per_tx,

        -- CLV = Monthly transaction rate * 12 * average profit per transaction
        ((total_transactions / NULLIF(tenure_months, 0)) * 12 * 
         ((total_amount_naira * 0.001) / NULLIF(total_transactions, 0))) AS estimated_clv
    FROM user_tx_summary
)

-- Step 3: Final output
SELECT 
    customer_id,
    name,
    tenure_months,
    total_transactions,
    ROUND(estimated_clv, 2) AS estimated_clv  -- Round CLV to 2 decimal places
FROM clv_calc
ORDER BY estimated_clv DESC;
