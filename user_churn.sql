select * from subscriptions_dataset

select user_id, plan_type,
DATE_FORMAT(min(start_date) over(partition by user_id),'%m') as cohort_month,
FIRST_VALUE(plan_type) OVER(PARTITION BY user_id order by start_date asc) as first_tier,
start_date
from subscriptions_dataset

select user_id,count(*) from subscriptions_dataset
group by user_id
having count(*) > 1

select user_id,
count(*) as subscription_count,
MIN(start_date) as first_subs,
MAX(start_date) as last_subs
from subscriptions_dataset
group by user_id
having count(*) > 1

select * from subscriptions_balanced
where user_id = 'user_12400'

select user_id,COUNT(*),
GROUP_CONCAT(plan_type) from subscriptions_balanced
group by user_id
HAVING COUNT(*) > 1

select user_id, plan_type
from subscriptions_balanced
where user_id IN (
select user_id
from subscriptions_balanced
group by user_id
HAVING COUNT(*) > 1
)
ORDER BY user_id, plan_type;




select user_id,
count(*) as subscription_count,

MIN(start_date) as first_subs,
MAX(start_date) as last_subs
from subscriptions_balanced
group by user_id
having count(*) > 1


WITH multi_users AS (
    SELECT user_id
    FROM subscriptions_balanced
    GROUP BY user_id
    HAVING COUNT(*) > 1
   --  LIMIT 10000  -- Test with 100 users first
)
SELECT s.user_id, s.plan_type
FROM subscriptions_balanced s
JOIN multi_users m ON s.user_id = m.user_id
ORDER BY s.user_id, s.plan_type;

-- INDEXING user_id amd start_date so sql doesnot always have to query every single row
CREATE INDEX idx_user_id ON subscriptions_balanced(user_id(20)) 
CREATE INDEX idx_start_date ON subscriptions_balanced(start_date(10))

EXPLAIN SELECT * from subscriptions_balanced WHERE user_id = 'user_100'

With multi_user as (
select user_id, plan_type from subscriptions_balanced
group by user_id, plan_type
having count(*) > 1
order by user_id asc
)

select user_id, plan_type
from multi_user
order by user_id asc

-- churn: those users that subscribed but stopped using the product/cancel subs
-- retention: those users who are active/subscribed

select * from subscriptions_dataset

select * from subscriptions_raw_data

-- FINDING THE MONTH WHEN SUBS STARTED:
select user_id, 
DATE_FORMAT(min(start_date) over(partition by user_id), '%Y-%m-01') as cohort_date,
first_value(plan_type) over(partition by user_id order by start_date) as first_plan,
DATE_FORMAT(start_date, '%Y-%m-01') as active_month,
plan_type
from subscriptions_balanced
UNION ALL
select user_id,
start_date, end_date, plan_type
from subscriptions_balanced
WHERE user_id = 'user_100'
ORDER BY start_date;

-- RIGHT ONES DOWN
-- TO FIND USERS SUBS start date and plan
WITH cohort as (
SELECT user_id,
min(start_date) as first_sub
from subscriptions_balanced
GROUP BY user_id
)

select s.user_id,
s.start_date, s.end_date,
s.plan_type,
c.first_sub
from subscriptions_balanced s 
JOIN cohort c 
ON s.user_id = c.user_id
order by s.user_id, s.start_date

-- ACTIVE MONTHS OF USERS

-- find user start month

WITH RECURSIVE month_expansion AS (
    SELECT 
        user_id,
        start_date,
        end_date,
        DATE_FORMAT(start_date, '%Y-%m-01') AS active_month
    FROM subscriptions_balanced

    UNION ALL

    SELECT 
        user_id,
        start_date,
        end_date,
        DATE_ADD(active_month, INTERVAL 1 MONTH)
    FROM month_expansion
    WHERE DATE_ADD(active_month, INTERVAL 1 MONTH) 
          <= DATE_FORMAT(COALESCE(end_date, CURDATE()), '%Y-%m-01')
),

user_cohort AS (
    SELECT 
        user_id,
        DATE_FORMAT(MIN(start_date), '%Y-%m-01') AS cohort_month
    FROM subscriptions_balanced
    GROUP BY user_id
),

final AS (
    SELECT 
        e.user_id,
        c.cohort_month,
        e.active_month,
        TIMESTAMPDIFF(MONTH, c.cohort_month, e.active_month) AS user_month
    FROM month_expansion e
    JOIN user_cohort c
        ON e.user_id = c.user_id
),

cohort_size AS (
    SELECT 
        cohort_month,
        COUNT(DISTINCT user_id) AS cohort_size
    FROM user_cohort
    GROUP BY 1
)

SELECT 
    f.cohort_month,
    f.user_month,
    COUNT(DISTINCT f.user_id) AS active_users,
    cs.cohort_size,
    (COUNT(DISTINCT f.user_id) / cs.cohort_size)*100.0 AS retention_rate
FROM final f
JOIN cohort_size cs
    ON f.cohort_month = cs.cohort_month
GROUP BY 1,2,4
ORDER BY 1,2;



