```markdown
# Freight Procurement & Carrier Benchmarking Dashboard

![Power BI](https://img.shields.io/badge/Power_BI-Desktop-F2C811?style=flat&logo=powerbi&logoColor=black)
![Python](https://img.shields.io/badge/Python-3.11+-3776AB?style=flat&logo=python&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-8.0-4479A1?style=flat&logo=mysql&logoColor=white)


![Dashboard Preview](https://github.com/mz-analytics/freight-procurement-dashboard/blob/main/dashboard_preview.png?raw=true)


> Core Business Question: How much could annual transport spend be reduced by benchmarking contractor freight rates and systematically reallocating volumes toward cost-efficient carriers?

---

## Project Overview

An end-to-end logistics analytics project focused on freight procurement, contractor rate benchmarking, and cost optimization.

The analysis evaluates 5,000 transport shipments originating from a central distribution hub in Mszczonów, covering 8 strategic domestic and international corridors serviced by 5 contract carriers[cite: 2].

The workflow couples relational data validation and SQL EDA directly with Python data pipelines and an executive Power BI reporting model to pinpoint procurement cost leakage[cite: 1, 2, 3].

---

## Key Findings & Metrics

| KPI | Value | Business Context |
| :--- | :--- | :--- |
| Total Shipments | 5,000 | Audited FTL/LTL freight orders[cite: 2] |
| Total Tonnage | 63.7K t | Volume moved across 8 corridors |
| Total Spend | 1.91M PLN | Baseline freight expenditure |
| Weighted Avg. Rate | 1.20 PLN/km | Portfolio-wide average contractor rate |
| Benchmark Rate | 0.95 PLN/km | Contract target rate (Local Transport PL)[cite: 2] |
| Max Carrier Rate | 1.35 PLN/km | Billed by Rhenus Logistics (+42% spread)[cite: 2] |
| Estimated Savings Opportunity | 400.61K PLN | Model savings potential (~21% total budget reduction) |

### Key Operational Takeaways
* Lane Concentration: The 3 longest routes (Warszawa -> Berlin, Mszczonów -> Gdańsk, Poznań -> Hamburg) consume over 54% of the entire transport budget[cite: 2].
* Corridor Leakage: On Warszawa -> Berlin, identical freight varies between 551 PLN and 783 PLN per trip depending on the carrier, representing a leakage of 232 PLN per truck[cite: 2].
* Inefficient Allocation: On Mszczonów -> Gdańsk (420 km), Rhenus Logistics handled 125 runs at 567 PLN/trip, while benchmark carrier Local Transport PL ran 102 trips at 399 PLN/trip (+168 PLN/trip premium for zero operational difference)[cite: 2].

---

## SQL Data Audit & Core Analytical Queries

All data quality checks and exploratory calculations are performed directly on the MySQL instance.

### 1. Data Integrity & Boundary Constraints
```sql
-- Verify positive metrics, lack of orphan records, and legal payload limits
SELECT * 
FROM shipments 
WHERE weight_kg <= 0 OR distance_km <= 0 OR total_cost <= 0;

SELECT s.id, s.date, s.carrier_id 
FROM shipments s
LEFT JOIN carriers c ON s.carrier_id = c.id
WHERE c.id IS NULL;

SELECT * 
FROM shipments 
WHERE weight_kg > 25000;

```

### 2. High-Impact Corridors (Budget Drivers)

```sql
SELECT 
    CONCAT(origin, " -> ", destination) AS route,
    COUNT(id) AS total_shipments,
    ROUND(SUM(weight_kg) / 1000, 1) AS total_tons,
    ROUND(AVG(total_cost), 2) AS avg_cost_per_shipment,
    ROUND(SUM(total_cost), 2) AS total_budget
FROM shipments
GROUP BY origin, destination
ORDER BY total_budget DESC;

```

### 3. Lane Rate Disparity (Cost Spread Per Full Truck)

```sql
SELECT 
    origin,
    destination,
    MIN(total_cost) AS min_trip_cost,
    MAX(total_cost) AS max_trip_cost,
    MAX(total_cost) - MIN(total_cost) AS cost_spread_per_trip
FROM shipments
GROUP BY origin, destination
ORDER BY cost_spread_per_trip DESC;

```

### 4. Carrier Allocation on Key Lanes (Mszczonów -> Gdańsk)

```sql
SELECT 
    s.origin,
    s.destination,
    c.name AS carrier_name,
    COUNT(*) AS total_trips,
    ROUND(AVG(s.total_cost), 2) AS avg_cost_per_trip,
    ROUND(SUM(s.total_cost), 2) AS total_spend
FROM shipments s
JOIN carriers c ON s.carrier_id = c.id
WHERE s.origin = 'Mszczonów' AND s.destination = 'Gdańsk'
GROUP BY s.origin, s.destination, c.name
ORDER BY avg_cost_per_trip;

```

---

## Architecture & Pipeline

```text
                 ┌─────────────────────────┐
                 │       MySQL DB          │
                 │ 5,000 shipments records │
                 │    + carrier tariffs    │
                 └────────────┬────────────┘
                              │
                              ▼
                 ┌─────────────────────────┐
                 │     Python Pipeline     │
                 │   Pandas ETL / Audit    │
                 │ Cost-per-kg derivations │
                 └────────────┬────────────┘
                              │
                              ▼
                 ┌─────────────────────────┐
                 │    Power BI Desktop     │
                 │  Star Schema Data Model │
                 │      DAX Analytics      │
                 │  Executive Visual UI    │
                 └────────────┬────────────┘
                              │
                              ▼
                 ┌─────────────────────────┐
                 │  Procurement Strategy   │
                 │ Volume reallocation &   │
                 │  Lane contract targets  │
                 └─────────────────────────┘

```

---

## Relational Schema & Modeling

The project employs a normalized Star Schema designed for reporting efficiency:

* Fact Table (`shipments`): Individual transport orders including `shipment_id`, `date`, `origin`, `destination`, `distance_km`, `weight_kg`, `carrier_id`, and `total_cost`.


* Dimension Table (`carriers`): Vendor master data including `carrier_id`, `name`, and base contracted `cost_per_km`.



---

## Key DAX Measures

### 1. Optimal Benchmark Rate

Determines the baseline rate dynamically based on the lowest observed contractor tariff:

```dax
Optimal Benchmark Rate = 
MINX(
    ALL('freight_db carriers'[name]),
    [Average Rate per KM]
)

```

### 2. Estimated Savings Opportunity

Calculates the aggregate financial leakage against the 0.95 PLN/km benchmark target:

```dax
Potential Savings = 
SUMX(
    'freight_db shipments',
    'freight_db shipments'[total_cost] 
        - ('freight_db shipments'[distance_km] * [Optimal Benchmark Rate])
)

```

### 3. Savings Share (%)

```dax
% Potential Savings = 
DIVIDE([Potential Savings], [Total Spend], 0)

```

### 4. Dynamic Bar Deviation Color

```dax
Kolor Słupka = 
SWITCH(
    SELECTEDVALUE('freight_db carriers'[name]),
    "Rhenus Logistics", "#E74C3C",    -- Critical Cost Driver (Alert Red)
    "Local Transport PL", "#27AE60",  -- Contract Benchmark (Target Green)
    "#95A5A6"                         -- Standard Market Spread (Neutral Gray)
)

```

---

## Practical Procurement Takeaways

1. Prioritize Corridors >400 km: Focus contract negotiations on Warszawa -> Berlin, Mszczonów -> Gdańsk, and Poznań -> Hamburg, where over half the annual budget is committed.


2. Eliminate Operational Habit Allocation: Shift volume on international lanes away from expensive providers (Rhenus, DB Schenker) toward cost-efficient partners up to capacity caps.


3. Establish Contract Rate Ceilings: Implement fixed contracted rate bands to prevent per-trip rate variations exceeding 1.10 PLN/km on key corridors.



---

## Domain Context & Disclaimer

* Model Scope: Savings reflect a mathematical upper bound assuming complete volume migration to the benchmark rate (0.95 PLN/km) without service degradation, seasonal rate surcharges, or vendor fleet capacity limits. Realized gains would be staged via allocation minimums and carrier SLA tiers.


* Data Origin: Synthetic operational logs modeled to reflect real-world Polish road transport distributions, vehicle capacities (FTL up to 24t), and European freight carrier tariffs.



---

## How to Run Locally

1. Seed Relational Database:

```bash
python setup_db.py

```

2. Execute SQL Data Quality Suite:
Run the SQL queries directly against `freight_db` in MySQL Workbench or DBeaver.


3. Run Python Data Processing & Export:

```bash
python analysis.py

```

4. Open BI Report:
Launch `freight_procurement_dashboard.pbix` in Power BI Desktop and click Refresh.



```

```
