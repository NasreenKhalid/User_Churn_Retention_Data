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

How many subscriptions were active during the selected period?

Original Measure

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
Performance Review

Original:

FILTER(...)

Observation:

FILTER() iterates over the table row by row.

Optimization:

CALCULATE(
COUNTROWS(...),
Subscriptions[start_date] <= MAX(...),
Subscriptions[end_date] >= MIN(...)
)

Reason:

Simple filter arguments allow the storage engine to optimize the query more efficiently.

Status:

✅ Optimized

AvgSubscriptionDuration

Business Question

What is the average subscription duration?

Original

AVERAGEX(...)

Observation

DATEDIFF() is computed for every row every time the measure is evaluated.

Optimization Idea

Create a calculated column:

SubscriptionDuration =
DATEDIFF(start_date,end_date,DAY)

New measure:

Average Duration =
AVERAGE(Subscriptions[SubscriptionDuration])

Reason

The duration is calculated once during data refresh instead of every query.

Status

✅ Optimized

Do this for every measure.

Performance Log

This is the fun part.

Measure	Before	After	Reason
ActiveSubscriptions	FILTER	Direct filter arguments	Better storage engine optimization
AvgSubscriptionDuration	AVERAGEX	AVERAGE(Column)	Precomputed values
RevenueImpact	SWITCH	Dimension Table	Better model design
Lessons Learned

Every optimization teaches something.

Example

Lesson 1

Prefer direct filter arguments inside CALCULATE() over wrapping everything in FILTER() when the logic is simple.

Lesson 2

Static calculations are often better as calculated columns than repeated measure computations.

Lesson 3

Business attributes like plan prices belong in dimension tables instead of hard-coded SWITCH() statements.
