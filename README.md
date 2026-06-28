# Subscription Cohort Retention & Churn Analysis

## Project Overview

This project analyzes customer subscription behavior using **cohort analysis** to measure **retention** and **churn** over time.

Instead of simply counting new subscriptions, the analysis tracks how many users from each signup cohort remain subscribed in subsequent months. This provides a clearer understanding of customer lifetime behavior and identifies when users are most likely to churn.

---

## Objectives

- Identify monthly subscription cohorts.
- Measure customer retention over time.
- Calculate monthly churn rates.
- Visualize retention patterns using cohort analysis.
- Generate business insights and recommendations to improve customer retention.

---

## Dataset

The dataset contains subscription records with the following fields:

| Column | Description |
|---------|-------------|
| user_id | Unique user identifier |
| start_date | Subscription start date |
| end_date | Subscription end date |
| plan_type | Subscription plan |

Each row represents a subscription period rather than monthly activity.

---

## Methodology

### Step 1 — Identify User Cohorts

Each user is assigned to a cohort based on the month of their **first subscription**.

Example:

| user_id | first subscription | cohort |
|---------|--------------------|---------|
| User A | 2023-01-15 | Jan-2023 |
| User B | 2023-02-04 | Feb-2023 |

---

### Step 2 — Expand Subscription Periods

Because each row represents a subscription interval, each subscription was expanded into every month during which it was active.

Example:

Original record:

| start_date | end_date |
|------------|-----------|
| 2023-01-15 | 2023-04-10 |

Expanded to:

| active_month |
|--------------|
| Jan-2023 |
| Feb-2023 |
| Mar-2023 |
| Apr-2023 |

This creates one record per active month, allowing accurate retention calculations.

---

### Step 3 — Calculate User Month

For each active month:

```
user_month = months since first subscription
```

Example:

| Cohort | Active Month | User Month |
|---------|--------------|------------|
| Jan-2023 | Jan-2023 | 0 |
| Jan-2023 | Feb-2023 | 1 |
| Jan-2023 | Mar-2023 | 2 |

---

### Step 4 — Calculate Active Users

For every cohort and user month:

- Count distinct active users.
- Calculate cohort size.
- Compute retention rate.

Formula:

```
Retention Rate = Active Users / Cohort Size
```

Churn Rate:

```
Churn Rate = 1 − Retention Rate
```

---

## Technologies Used

- **MySQL**
  - Recursive CTEs
  - Window Functions
  - Date Manipulation
  - Cohort Construction

- **Python**
  - Pandas
  - Matplotlib
  - Seaborn

---

## Key Visualizations

- Cohort Retention Heatmap
- Retention Curves
- Churn Curves
- Cohort Comparison

---

# Example Cohort Interpretation

### January 2023 Cohort

| User Month | Retention |
|------------|-----------|
| Month 0 | 100.00% |
| Month 1 | 99.74% |
| Month 2 | 88.43% |
| Month 3 | 77.12% |
| Month 4 | 62.47% |

### Interpretation

- **Month 0:** All users are active immediately after subscribing.
- **Month 1:** Almost no customers churn during the first month, indicating strong initial retention.
- **Month 2:** A noticeable decline begins, suggesting some users discontinue after the first renewal cycle.
- **Months 3–4:** Retention continues to decline, indicating that churn accelerates after the initial months.

---

# Key Findings

### 1. Strong Initial Retention

Most users remain subscribed during their first month.

This suggests that onboarding and the initial customer experience are effective.

---

### 2. Churn Begins Early

The largest retention decline occurs after the second month.

This indicates users may not be experiencing enough ongoing value after their initial subscription period.

---

### 3. Retention Continues to Decline

After Month 2, retention decreases steadily across later months.

This pattern is common in subscription-based businesses and highlights the importance of sustained customer engagement.

---

### 4. Cohort Analysis Provides Longitudinal Insights

Rather than analyzing all customers together, cohort analysis tracks users based on when they joined.

This allows comparisons between different acquisition periods and helps evaluate whether retention improves over time.

---

# Business Recommendations

### Improve Early Customer Engagement

The first two months represent the highest-risk period for future churn.

Possible actions:

- Interactive onboarding
- Personalized welcome emails
- Feature tutorials
- In-app guidance

---

### Focus on the First Renewal

Retention begins to decline after the initial subscription period.

Potential strategies:

- Renewal reminders
- Loyalty incentives
- Limited-time upgrade offers
- Personalized recommendations

---

### Increase Long-Term Engagement

Encourage customers to build long-term habits.

Examples:

- Usage milestones
- Achievement badges
- Monthly summaries
- Product tips
- Exclusive premium features

---

### Monitor Cohorts Continuously

Repeat cohort analysis monthly to answer questions such as:

- Are newer cohorts retaining better?
- Did a pricing change affect retention?
- Did onboarding improvements reduce churn?

---

# Skills Demonstrated

- SQL Data Transformation
- Recursive Common Table Expressions (CTEs)
- Window Functions
- Cohort Analysis
- Customer Retention Analysis
- Churn Analysis
- Data Cleaning
- Data Visualization
- Business Insight Generation

---

# Future Improvements

- Analyze retention by subscription plan.
- Compare retention across customer segments.
- Estimate Customer Lifetime Value (LTV).
- Analyze revenue retention in addition to user retention.
- Build an interactive dashboard using Tableau or Power BI.

---

# Conclusion

This project demonstrates how cohort analysis can reveal customer retention behavior that is not visible through aggregate metrics alone.

By expanding subscription periods into monthly activity, it becomes possible to accurately measure retention over time and identify when customers are most likely to churn.

The analysis highlights that while users exhibit strong retention immediately after subscribing, engagement begins to decline after the second month, emphasizing the importance of early customer success initiatives and long-term engagement strategies.

These insights can help businesses prioritize retention efforts, improve customer lifetime value, and make data-driven product decisions.