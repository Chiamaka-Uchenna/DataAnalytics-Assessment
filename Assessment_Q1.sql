-- Switch to the target database
USE adashi_staging;

-- Retrieve customers who have both funded savings accounts and investment accounts (is_a_fund = 1)
SELECT 
    u.id AS owner_id,

    -- displaying the user's name if available; otherwise fallback to username or show "[No Name]"
    COALESCE(u.name, u.username, '[No Name]') AS name,

    COUNT(DISTINCT s.id) AS savings_count,
    COUNT(DISTINCT p.id) AS investment_count,

    -- Sum the confirmed amounts (in Kobo) and convert to Naira
    SUM(s.confirmed_amount) / 100.0 AS total_deposits

FROM users_customuser u

-- Join to savings accounts owned by the user
JOIN savings_savingsaccount s ON u.id = s.owner_id

-- Join to investment plans owned by the user
JOIN plans_plan p ON u.id = p.owner_id

-- Ensure funded savings accounts are only considered
WHERE s.confirmed_amount > 0 

-- Ensure that actual investment funds (is_a_fund = 1) are only being considered
  AND p.is_a_fund = 1

-- Group by user ID and resolved name
GROUP BY u.id, name

-- Filter for customers who have both savings and investment accounts
HAVING COUNT(DISTINCT s.id) > 0 AND COUNT(DISTINCT p.id) > 0

ORDER BY total_deposits DESC;
