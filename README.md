# Freight Procurement & Route Benchmarking Dashboard

![Power BI](https://img.shields.io/badge/Power_BI-Desktop-F2C811?style=flat&logo=powerbi&logoColor=black)
![Python](https://img.shields.io/badge/Python-3.11+-3776AB?style=flat&logo=python&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-8.0-4479A1?style=flat&logo=mysql&logoColor=white)
![DAX](https://img.shields.io/badge/DAX-Analytics-orange?style=flat)
![Status](https://img.shields.io/badge/Status-Executive_Ready_v1.0-27AE60?style=flat)

An end-to-end logistics business intelligence pipeline analyzing **5,000 shipments** across 8 core transport corridors to benchmark 5 European freight carriers, uncover procurement cost leakages, and simulate rate contract renegotiations.

![Dashboard Preview](dashboard_preview.png)

---

## 🎯 Executive Summary & Core KPIs

* **Total Logistics Spend:** 1.91M PLN across 5,000 executed orders (63.69K total tonnage).
* **Identified Potential Savings:** **400.61K PLN (20.99% cost reduction)**.
* **Weighted Average Rate:** 1.20 PLN/km.
* **Benchmark Contractor Rate:** **0.95 PLN/km** (*Local Transport PL*).
* **Outlier Maximum Rate:** **1.35 PLN/km** (*Rhenus Logistics* — +42% deviation from benchmark).
* **Core Leakage Driver:** Heavy budget misallocation on high-spend lanes (`Warszawa -> Berlin` and `Mszczonów -> Gdańsk`) without enforced target rate limits.

---

## 📐 Key Procurement DAX Measures

### 1. Potential Savings per Route & Shipment
Calculates the exact monetary leakage against the operational benchmark rate ($0.95\text{ PLN/km}$):
```dax
Potential Savings = 
SUMX(
    'freight_db shipments',
    'freight_db shipments'[total_cost] - ('freight_db shipments'[distance_km] * [Optimal Benchmark Rate])
)
