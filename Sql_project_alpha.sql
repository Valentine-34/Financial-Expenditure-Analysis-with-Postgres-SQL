/*
Working on data exploration using data from my personal bank statement. Data was cleaned and transformed in excel(there was some
data cleaning done in postgres after the data was imported and was being worked on)
before being imported into postgres. The whole data set was broken down into four tables hence the four tables 
in the database. The postgres database was created first,then four tables were added to the database. 
After the tables were created i proceeded to import the data into the tables assigning primary keys 
and foreign keys while referencing the columns where the foreign keys were taken from. 
*/

--skimming throught the database to see what we are working with
SELECT *
FROM accounts;

SELECT *
FROM amount;

SELECT *
FROM occurred_at;

SELECT *
FROM transactions;

-- quick query
SELECT transaction_type, transaction_date
FROM transactions as t
JOIN occurred_at as o
ON t.occurred_at_id = o.id;

-- some more cleaning...null values and negatives in the money columns causing problems


--taking care of the negatives
UPDATE amount
SET money_out = ABS(money_out),
	money_in = ABS(money_in)
WHERE  money_out < 0 OR
		money_in < 0;
		
-- checking out the new money columns
SELECT money_out, money_in
FROM amount;

-- taking care of the null columns now
UPDATE accounts
SET recipient = COALESCE(recipient, 'empty'),
	category = COALESCE(category, 'empty');
	
UPDATE amount
SET money_out = COALESCE(money_out, 0),
	money_in = COALESCE(money_in, 0);
	
--checking out the cleaned columns
SELECT money_out, money_in
FROM amount;

-- number of transactions by type
SELECT t.transaction_type, COUNT(t.transaction_type)
FROM transactions as t
GROUP BY t.transaction_type;

-- who are the top 5 recipients for money_out
SELECT acc.recipient, SUM(am.money_out) as total_money_out
FROM accounts as acc
JOIN amount as am
ON acc.amount_id = am.id
GROUP BY acc.recipient
ORDER BY 2 DESC
LIMIT 5;

--total money_out for February
SELECT SUM(money_out) as total_money_out
FROM amount as am
JOIN accounts as acc
ON acc.amount_id = am.id
JOIN occurred_at as oa
ON oa.account_id = acc.id
WHERE transaction_date BETWEEN '2022-02-01' AND '2022-02-28'
AND money_in = 0 ;

-- money_out from 1st Feb to 28th Feb
SELECT SUM(money_out), transaction_date
FROM amount as am
JOIN accounts as acc
ON acc.amount_id = am.id
JOIN occurred_at as oa
ON oa.account_id = acc.id
GROUP BY 2, am.money_in
HAVING transaction_date BETWEEN '2022-02-01' AND '2022-02-28'
AND money_in = 0

--what is the largest money_out transaction
SELECT money_out
FROM amount
ORDER BY 1 DESC
LIMIT 1


-- transaction types with the largest money_out (top 5)
SELECT transaction_type, SUM(money_out)
FROM transactions as tr
JOIN occurred_at as oa
ON tr.occurred_at_id = oa.id
JOIN accounts as acc
ON oa.account_id = acc.id
JOIN amount as am
ON acc.amount_id = am.id
GROUP BY 1, am.money_in
HAVING money_in = 0
ORDER BY 2 DESC
LIMIT 5


-- all recipients
SELECT DISTINCT recipient
FROM accounts
ORDER BY 1


-- transaction types with the largest money_in 
SELECT transaction_type, SUM(money_in)
FROM transactions as tr
JOIN occurred_at as oa
ON tr.occurred_at_id = oa.id
JOIN accounts as acc
ON oa.account_id = acc.id
JOIN amount as am
ON acc.amount_id = am.id
GROUP BY 1, am.money_out
HAVING money_out = 0
ORDER BY 2 DESC
















