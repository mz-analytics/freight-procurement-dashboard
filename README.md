**Nie do końca** — zgubiłeś domknięcia bloków kodu (trzy grawisy `````) oraz nagłówki sekcji, przez co cały tekst od połowy zleje się na GitHubie w jeden nieczytelny blok.

Oto w 100% poprawny, kompletny plik `README.md` z zachowaną pełną składnią Markdown:

```markdown
# Freight Procurement & Route Benchmarking Dashboard

![Power BI](https://img.shields.io/badge/Power_BI-Desktop-F2C811?style=flat&logo=powerbi&logoColor=black)
![Python](https://img.shields.io/badge/Python-3.11+-3776AB?style=flat&logo=python&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-8.0-4479A1?style=flat&logo=mysql&logoColor=white)
![DAX](https://img.shields.io/badge/DAX-Analytics-orange?style=flat)
![Status](https://img.shields.io/badge/Status-Executive_Ready_v1.0-27AE60?style=flat)

An end-to-end logistics business intelligence pipeline analyzing **5,000 shipments** across 8 core transport corridors to benchmark 5 European freight carriers, uncover procurement cost leakages, and simulate rate contract renegotiations[cite: 2].

![Dashboard Preview](dashboard_preview.png)

---

## 🎯 Executive Summary & Core KPIs

* **Total Logistics Spend:** 1.91M PLN across 5,000 executed orders (63.69K total tonnage)[cite: 2].
* **Identified Potential Savings:** **400.61K PLN (20.99% cost reduction)**.
* **Weighted Average Rate:** 1.20 PLN/km.
* **Benchmark Contractor Rate:** **0.95 PLN/km** (*Local Transport PL*)[cite: 2].
* **Outlier Maximum Rate:** **1.35 PLN/km** (*Rhenus Logistics* — +42% deviation from benchmark)[cite: 2].
* **Core Leakage Driver:** Heavy budget misallocation on high-spend lanes (`Warszawa -> Berlin` and `Mszczonów -> Gdańsk`) without enforced target rate limits[cite: 2].

---

## 📐 Key Procurement DAX Measures

### 1. Potential Savings per Route & Shipment
Calculates the exact monetary leakage against the operational benchmark rate (0.95 PLN/km):
```dax
Potential Savings = 
SUMX(
    'freight_db shipments',
    'freight_db shipments'[total_cost] - ('freight_db shipments'[distance_km] * [Optimal Benchmark Rate])
)

```

### 2. Relative Savings Share (%)

```dax
% Potential Savings = 
DIVIDE([Potential Savings], [Total Spend], 0)

```

### 3. Dynamic Bar Color Coding (Executive Alert)

```dax
Kolor Słupka = 
SWITCH(
    SELECTEDVALUE('freight_db carriers'[name]),
    "Rhenus Logistics", "#E74C3C",    -- Critical Cost Driver
    "Local Transport PL", "#27AE60",  -- Contract Benchmark
    "#95A5A6"                         -- Standard Market
)

```

---

## 🔍 Root-Cause Analysis (Decomposition Tree)

The interactive decomposition model isolates where budget deviations concentrate:

* **Level 1 (Total Savings Opportunity):** 400.61K PLN
* **Level 2 (Top Leakage Lanes):**
* `Warszawa -> Berlin`: **83.81K PLN** (21% of total savings)
* `Mszczonów -> Gdańsk`: **68.61K PLN** (17% of total savings)
* `Poznań -> Hamburg`: **65.75K PLN** (16% of total savings)


* **Level 3 (Top Rate Offenders on Berlin Lane):**
* *Rhenus Logistics:* **26.68K PLN**
* *DB Schenker:* **21.92K PLN**



---

## 🏗️ Data Architecture & Pipeline

```
[ MySQL Database ]         --> [ Python ETL (Pandas) ]      --> [ Power BI Desktop ]
  - shipments (5,000 rows)       - Rate outlier filtering         - Star schema modeling
  - carriers (5 vendors)         - Lane cost aggregations         - Interactive decomposition
                                 - Automated Excel export         - Visual storytelling

```

---

## 🚀 How to Run Locally

### 1. Database Initialization

Seed the MySQL instance with the synthetic operational dataset:

```bash
python setup_db.py

```

### 2. Run Data Pipeline

Extract metrics and produce validation aggregates:

```bash
python analysis.py

```

### 3. Open BI Report

Open `freight_procurement_dashboard.pbix` in **Power BI Desktop** and click **Refresh**.




