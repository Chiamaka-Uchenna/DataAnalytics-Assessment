# DATA ANALYTICS ASSESSMENT

This repository contains my solutions to the SQL Proficiency Assessment using **MySQL**. Each file answers a specific question related to customer behavior, transaction patterns, and account activity.


## QUESTION EXPLANATIONS

### Q1: HIGH-VALUE CUSTOMERS WITH MULTIPLE PRODUCTS
I identified customers who have both funded savings and investment accounts. Grouped by customer and filtered for those with both types, I calculated total deposits using the `confirmed_amount` field.
**Challenges:**
- Initially, the `name` field returned `NULL` for many users. 
- The second time, Many `name` values were blank or `NULL`.  
- Needed to handle blank strings as well as nulls. 
- **Solution:**
To ensure every user had an identifiable name, I examined the user  by applying `DESCRIBE users_customuser` and found alternative fields such as `username` and `email`. I used `COALESCE` combined with `NULLIF` to return the first non-blank value among `name`, `username`, `email`, or defaulted to `'Unknown'`.
--`COALESCE(NULLIF(name, ''), NULLIF(username, ''), email, 'Unknown')`.

### Q2: TRANSACTION FREQUENCY ANALYSIS
Using monthly aggregates, I calculated the average number of transactions per month for each customer and categorized them accordingly.
**Challenges:**  
- Aggregating transactions by month while handling varied customer lifespans.  
- **Solution:** 
Used a CTE to aggregate transactions per customer per month, truncating transaction dates to the first day of each month with `DATE_FORMAT(transaction_date, '%Y-%m-01')` to standardize grouping.


### Q3: ACCOUNT INACTIVITY ALERT
I extracted the latest transaction dates for savings and investment accounts, then filtered those with no inflows in the past 365 days.
**Challenges:**  
- Unsure if a proper transaction date existed for savings/investment accounts.
- Default datetime output included time, cluttering results.   
- **Solution:**
 Used `DESCRIBE savings_savingsaccount;` and `DESCRIBE plans_plan;` to explore columns and confirm `created_at` was the reliable field for identifying latest transactions.
 Applied `DATE(datetime_column)` to show only the date.


### Q4: CUSTOMER LIFETIME VALUE (CLV)
I calculated tenure in months since sign-up, counted total transactions, estimated profit per transaction (0.1% of value), and applied the simplified CLV formula.
To compute average profit per transaction and estimated Customer Lifetime Value (CLV), I:  
- Used `NULLIF` in denominators to avoid division by zero errors.  
- Adjusted `GROUP BY` clause to include all columns involved in the `COALESCE` expression (`name`, `username`, `email`), alongside primary keys, to satisfy MySQL’s strict grouping rules.
**Challenges:**  
- Division by zero caused errors.  
- Grouping by derived fields (`COALESCE` results) led to aggregation errors.  
- **Solution:** 
Used safe division (`NULLIF`) and grouped by base columns individually.


## ADDITIONAL CHECKS
- **Currency Handling**: All monetary fields were stored in Kobo (smallest unit); divided by 100 to convert to Naira.
- **NULL and Zero Handling**: Needed to guard against division by zero or nulls.Applied `NULLIF` to protect against runtime errors in mathematical operations.


## FINAL NOTES
- All queries were tested for performance and accuracy.
- Inline comments were added in complex SQL blocks to ensure clarity.
- Schema exploration `DESCRIBE TABLE` was used to understand data structure before query design.

