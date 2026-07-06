select * from subs_data

select customer_id, created_date, COUNT(*)
from subs_data
GROUP BY customer_id, created_date
HAVING COUNT(*) >1

select * from subs_data
where customer_id ='154901722'



ALTER TABLE subs_data
ADD COLUMN sub_plan VARCHAR(20)

update subs_data
SET subscription_cost = CASE
WHEN sub_plan = 'basic' THEN 9.99
WHEN sub_plan = 'premium' THEN 19.99
ELSE 29.99
END
WHERE sub_plan IS NOT NULL


-- Q1: Active subscribers this month (Jan 23--no data for this year)
select COUNT(DISTINCT(customer_id))
from subs_data
where created_date BETWEEN '2023-01-01' AND '2023-01-31' 

-- Q2:New subscribers (I CALCULATED FOR JUNE)
select DISTINCT(customer_id), created_date, canceled_date
from subs_data
where created_date BETWEEN '2023-06-01' AND '2023-06-30' 
AND canceled_date = ''

-- Q3: Churned subscribers
SELECT DISTINCT customer_id, canceled_date
FROM subs_data
WHERE canceled_date IS NOT NULL
AND canceled_date != '';


-- Q4: Monthly recurring revenue

select EXTRACT(MONTH FROM created_date) as sub_month,
ROUND(SUM(CASE WHEN sub_plan = 'basic' THEN subscription_cost ELSE 0 END),2) AS basic_rev,
ROUND(SUM(CASE WHEN sub_plan ='premium' THEN subscription_cost ELSE 0 END),2) AS prem_rev,
ROUND(SUM(CASE WHEN sub_plan = 'pro' THEN subscription_cost ELSE 0 END),2) AS pro_rev,
ROUND(SUM(subscription_cost),2) AS total_revenue
from subs_data
WHERE created_date IS NOT NULL
GROUP BY EXTRACT(MONTH FROM created_date)


-- Q5:Average subscription length
SELECT customer_id, DATEDIFF(canceled_date, created_date) AS days_difference
from subs_data
WHERE canceled_date IS NOT NULL
AND canceled_date != '';

-- AVERAGE SUBSCRIPTION
select ROUND(AVG(DATEDIFF(canceled_date, created_date)),2) AS Avg_Subs_Length
from subs_data
WHERE canceled_date IS NOT NULL
AND canceled_date != '';

-- Q6: Active paid subscribers
select COUNT(customer_id)
from subs_data
where was_subscription_paid = 'Yes'
AND canceled_date = ''


-- Q7: Canceled subscribers
select COUNT(customer_id)
from subs_data
where canceled_date >= created_date

AND canceled_date IS NOT NULL

select * from subs_data
where customer_id ='149713408'


-- subscription dashboard
-- Calendar CTE
WITH RECURSIVE calendar AS (
    SELECT MIN(STR_TO_DATE(NULLIF(created_date, ''), '%Y-%m-%d')) AS cal_date
    FROM subs_data
    
    UNION ALL
    
    SELECT DATE_ADD(cal_date, INTERVAL 1 DAY)
    FROM calendar
    WHERE cal_date < (
        SELECT MAX(STR_TO_DATE(NULLIF(COALESCE(canceled_date, created_date), ''), '%Y-%m-%d')) 
        FROM subs_data
    )
)
SELECT 
    c.cal_date,
    
    -- Active Subscribers
    COUNT(DISTINCT 
        CASE 
            WHEN STR_TO_DATE(s.created_date, '%Y-%m-%d') <= c.cal_date
            AND (s.canceled_date IS NULL OR STR_TO_DATE(s.canceled_date, '%Y-%m-%d') > c.cal_date)
            THEN s.customer_id 
        END
    ) AS active_users,
    
    -- New users: created exactly on this date
    COUNT(DISTINCT 
        CASE 
            WHEN STR_TO_DATE(s.created_date, '%Y-%m-%d') = c.cal_date
            THEN s.customer_id 
        END
    ) AS new_users,
    
    -- Churned Users
    COUNT(DISTINCT 
        CASE
            WHEN STR_TO_DATE(s.canceled_date, '%Y-%m-%d') = c.cal_date
            THEN s.customer_id
        END
    ) AS churned_users,  -- Added comma here
    
    -- Daily Revenue (cash collected THIS day: new + reactivated signups, paid only)
    COALESCE(SUM(CASE 
        WHEN STR_TO_DATE(s.created_date, '%Y-%m-%d') = c.cal_date 
        AND s.was_subscription_paid = 'yes'
        THEN s.subscription_cost 
    END), 0) AS daily_revenue,  -- Added comma here
    
    -- MRR (snapshot of active + paid subs' monthly value)
    COALESCE(SUM(CASE 
        WHEN STR_TO_DATE(s.created_date, '%Y-%m-%d') <= c.cal_date
        AND (s.canceled_date IS NULL OR STR_TO_DATE(s.canceled_date, '%Y-%m-%d') > c.cal_date)
        AND s.was_subscription_paid = 'yes'
        THEN s.subscription_cost 
    END), 0) AS mrr

FROM calendar c
LEFT JOIN subs_data s
    ON STR_TO_DATE(s.created_date, '%Y-%m-%d') <= c.cal_date
    AND (s.canceled_date IS NULL OR STR_TO_DATE(s.canceled_date, '%Y-%m-%d') >= c.cal_date)

GROUP BY c.cal_date
ORDER BY c.cal_date;









