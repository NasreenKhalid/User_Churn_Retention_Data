## Subscriber Analytics Dashboard – Optimization Journal
# Project Summary
* Dataset: ~94,000 subscriptions
* Tool: Power BI
* Goal: Analyze subscriptions, churn, retention, revenue and optimize report performance.
* Model Review

### Fact Table

subscriptions_balanced_94k

Contains:

* start_date
* end_date
* plan_type
* user_id
* plan_type

### Reason:

This is the transactional table where each row represents one subscription.

## DateTable

### Purpose:

Provides a dedicated calendar table so all time-based calculations (monthly growth, churn, trends) use a consistent date dimension.

Why not use start_date directly?

* Better time intelligence
* Cleaner DAX
* Easier slicing/filtering
* Best practice in Power BI

Status:

✅ Good

Relationships

(We'll fill this after reviewing your model.)

Measure Review

Now each measure gets its own page or section.

### ActiveSubscriptions
Business Question

* How many subscriptions were active during the selected period?

### Original Measure

ActiveSubscriptions = 
CALCULATE(
    COUNTROWS(Subscriptions),
    FILTER(
        Subscriptions,
        Subscriptions[start_date] <= MAX(DateTable[Date]) &&
        Subscriptions[end_date] >= MIN(DateTable[Date])
    )
)

How it Works
Counts rows in Subscriptions.
Keeps only rows where:
start_date is before or on the selected end date.
end_date is after or on the selected start date.
Those subscriptions overlap the selected period and are considered active.
### Performance Review

### Original:

Uses FILTER(...)

### Observation:

FILTER() iterates over the table row by row.

### Optimization:

CALCULATE(
    COUNTROWS(Subscriptions),
    Subscriptions[start_date] <= MAX(DateTable[Date]),
    Subscriptions[end_date] >= MIN(DateTable[Date])
)

### Reason:

Simple filter arguments allow the storage engine to optimize the query more efficiently.

#### Status:

✅ Optimized

#### AvgSubscriptionDuration

* Business Question

* What is the average subscription duration?

### Original

AVERAGEX(...)

### Observation

DATEDIFF() is computed for every row every time the measure is evaluated.

### Optimization Idea

* Create a calculated column:

SubscriptionDuration =
DATEDIFF(start_date,end_date,DAY)

### New measure:

Average Duration =
AVERAGE(Subscriptions[SubscriptionDuration])

### Reason

The duration is calculated once during data refresh instead of every query.

### Status

✅ Optimized


### RevenueImpact Measure
## Original

Revenue was calculated using:

* SWITCH()
* ADDCOLUMNS()
* SUMX()
* Basic → 9.99
* Premium → 19.99
* Pro → 29.99
Each time the report refreshed, Power BI checked for every subscription out of all plan types.

#### Optimization:
* Created a PlanTypes dimension table with a Price column.

* Created a relationship:
* PlanTypes[PlanName]
      ↓
Subscriptions[plan_type]

* Added a Plan_Price column in subscriptions_balanced_94k table which is related to plan_types[Price] column
and then created the Plan_Price measure as:
Price =
RELATED(PlanTypes[PlanPrice])

* New measure
RevenueImpact =
SUM(Subscriptions[Price])

* Why is this better?

* ✅ Cleaner DAX

* ✅ Centralized business logic

* ✅ Easier maintenance

* If the Premium plan price changes, only one value in PlanTypes needs to be updated.

* No measures need to change.

### Status

✅ Optimized

## UserLTV Measure Optimization
Earlier there were complex calculations as:
UserLTV = 
VAR UserSubs = 
    ADDCOLUMNS(
        SUMMARIZE(
            Subscriptions,
            Subscriptions[user_id],
            "TotalSubs", COUNTROWS(Subscriptions),
            "AvgDuration", AVERAGEX(Subscriptions, DATEDIFF(Subscriptions[start_date], Subscriptions[end_date], DAY))
        ),
        "LTV",
        [TotalSubs] * [AvgDuration] * 0.5
    )
RETURN
AVERAGEX(UserSubs, [LTV])

Updated them to stop creating many virtual tables, instead calculate UserLTV directly as:
UserLTV =
AVERAGEX(
    VALUES(Subscriptions[user_id]),
    CALCULATE(COUNTROWS(Subscriptions))
        *
    CALCULATE(AVERAGE(Subscriptions[SubscriptionDuration]))
        *
    0.5
)

### Why is this better?
 

* Instead of Build a temporary table, add columns, then average...



* Iterate over each unique user and calculate the LTV directly.

It's:

* ✅ shorter
* ✅ easier to read
* ✅ avoids SUMMARIZE and ADDCOLUMNS
* ✅ uses the precomputed SubscriptionDuration


### Lessons Learned

### Every optimization teaches something.

### Lesson 1

Prefer direct filter arguments inside CALCULATE() over wrapping everything in FILTER() when the logic is simple.

### Lesson 2

Static calculations are often better as calculated columns than repeated measure computations.

### Lesson 3

Business attributes like plan prices belong in dimension tables instead of hard-coded SWITCH() statements.
