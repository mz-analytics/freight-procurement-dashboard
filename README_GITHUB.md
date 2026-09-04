# 📦 Freight Procurement & Route Benchmarking Dashboard

![Power BI](https://img.shields.io/badge/Power_BI-Desktop-F2C811?style=flat&logo=powerbi&logoColor=black)
![Python](https://img.shields.io/badge/Python-3.11+-3776AB?style=flat&logo=python&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-SQLite-003B57?style=flat&logo=sqlite&logoColor=white)
![Status](https://img.shields.io/badge/Status-Production%20Ready-brightgreen?style=flat)

Data-driven freight cost optimization project analyzing 5,000+ shipments across 8 routes and 5 carriers to identify 400K PLN in annual savings opportunities.

---

## 🎯 Executive Summary

| Metric | Value | Context |
|--------|-------|---------|
| **Total Shipments** | 5,000 | Full period analysis |
| **Total Tonnage** | 63.69K t | Volume moved |
| **Total Spend** | 1.91M PLN | Baseline budget |
| **Avg Rate** | 1.20 PLN/km | Portfolio average |
| **Benchmark Rate** | 0.95 PLN/km | Lowest carrier (Local Transport PL) |
| **Potential Savings** | **400.61K PLN** | 21% cost reduction opportunity |

### Top 3 Cost Drivers
1. **Warszawa → Berlin:** 408K PLN spend, 83.8K PLN overspend identified
2. **Mszczonów → Gdańsk:** 317.5K PLN spend, 68.6K PLN savings potential
3. **Poznań → Hamburg:** 312.8K PLN spend, 65.7K PLN renegotiation target

---

## 📊 Dashboard Overview

**Key Visualizations:**
- **KPI Cards:** Total Spend, Potential Savings, Shipment Count, Tonnage, Avg Rate
- **Carrier Benchmark Chart:** Average cost per km by carrier (Red=expensive, Green=efficient)
- **Route Cost Distribution:** 8 routes ranked by spend, identifies top cost drivers
- **Route × Carrier Heatmap:** Full cross-tabulation showing optimal carrier per route
- **Savings Drill-down:** Interactive breakdown of savings opportunity by route and carrier switch

**Interactive Filters:**
- Carrier selection
- Route selection
- Date range (seasonal analysis)
- "Keep all filters" toggle for multi-dimensional analysis

---

## 🛠️ Technical Stack

```
SQLite Database (5,000 shipments)
        ↓
Python + Pandas (ETL & EDA)
        ↓
Power BI Desktop (Data Model & DAX)
        ↓
Interactive Dashboard
```

### Database Schema
**`shipments` table (5,000 rows):**
- id, date, origin, destination, distance_km, weight_kg, carrier_id, total_cost

**`carriers` table (5 rows):**
- id, name, cost_per_km, avg_delay_days

### Key DAX Measures
```dax
-- Benchmark rate (lowest carrier rate)
Optimal Benchmark Rate = MINX(ALL(carriers[name]), [Average Rate per KM])

-- Potential savings vs benchmark
Potential Savings = SUMX(shipments, shipments[total_cost] - (shipments[distance_km] * [Optimal Benchmark Rate]))

-- Savings as % of total spend
% Potential Savings = DIVIDE([Potential Savings], [Total Spend], 0)
```

---

## 📁 Project Structure

```
freight-optimizer/
├── README.md                    # This file
├── data/
│   └── freight_routes.db       # SQLite database
├── scripts/
│   ├── setup_db.py             # Create database & generate data
│   └── analysis.py             # ETL pipeline & exploratory analysis
├── dashboards/
│   ├── Freight_Dashboard.pbix  # Power BI report
│   └── dashboard_preview.png   # Screenshot
└── docs/
    ├── SQL_QUERIES.md          # Key analysis queries
    └── DATA_DICTIONARY.md      # Schema documentation
```

---

## 🚀 How to Use

### Quick Start (View Dashboard)
1. Download `Freight_Dashboard.pbix`
2. Open in Power BI Desktop
3. Use filters to drill into specific routes/carriers
4. View `dashboard_preview.png` for static overview

### Setup (Run Locally)

**Prerequisites:**
```bash
Python 3.11+
pip install pandas
```

**Steps:**
```bash
# 1. Create database
python scripts/setup_db.py
# Output: freight_routes.db created with 5,000 shipments

# 2. Run analysis
python scripts/analysis.py
# Output: Insights + freight_analysis.xlsx generated

# 3. Load into Power BI
# Power BI Desktop → Get Data → SQLite → freight_routes.db
```

---

## 🔍 Key SQL Queries

**Carrier benchmark by route:**
```sql
SELECT 
    s.origin || ' -> ' || s.destination as route,
    c.name as carrier,
    COUNT(*) as trips,
    ROUND(AVG(c.cost_per_km), 2) as avg_rate,
    ROUND(SUM(s.total_cost), 2) as total_spend
FROM shipments s
JOIN carriers c ON s.carrier_id = c.id
GROUP BY s.origin, s.destination, c.name
ORDER BY avg_rate ASC;
```

**Identify cost anomalies (>40% above average):**
```sql
SELECT 
    s.origin || ' -> ' || s.destination as route,
    c.name as carrier,
    s.total_cost,
    ROUND(AVG(s.total_cost) OVER (PARTITION BY s.origin, s.destination), 2) as route_avg,
    ROUND((s.total_cost / AVG(s.total_cost) OVER (PARTITION BY s.origin, s.destination) - 1) * 100, 1) as pct_above_avg
FROM shipments s
JOIN carriers c ON s.carrier_id = c.id
WHERE s.total_cost > (SELECT AVG(total_cost) * 1.4 FROM shipments)
ORDER BY s.total_cost DESC;
```

---

## 💡 Business Insights

### Carrier Performance Ranking
1. **Local Transport PL:** 0.95 PLN/km (benchmark, cost leader)
2. **Kühne+Nagel:** 1.15 PLN/km (+21% vs benchmark)
3. **DHL Supply Chain:** 1.25 PLN/km (+32% vs benchmark)
4. **DB Schenker:** 1.30 PLN/km (+37% vs benchmark)
5. **Rhenus Logistics:** 1.35 PLN/km (+42% vs benchmark)

### Route Cost Optimization
| Route | Current Spend | Best Carrier | Savings Potential |
|-------|---------------|--------------|-------------------|
| Warszawa → Berlin | 408.3K | Local Transport | 83.8K |
| Mszczonów → Gdańsk | 317.6K | Local Transport | 68.6K |
| Poznań → Hamburg | 312.8K | Local Transport | 65.7K |
| Warszawa → Poznań | 249.5K | Local Transport | 53.3K |
| Mszczonów → Kraków | 226.9K | Local Transport | 47.6K |

### Recommended Actions
- **Immediate:** Redirect Poznań & Kraków volumes from Rhenus/DHL to Local Transport
- **30 days:** Renegotiate Berlin corridor contract rates with DB Schenker
- **90 days:** Consolidate local Mszczonów routes, reduce carrier count from 5 to 3

---

## 📈 Skills Demonstrated

✅ SQL (joins, aggregations, window functions, subqueries)  
✅ Python (Pandas, data cleaning, EDA)  
✅ Power BI (data modeling, DAX measures, dashboard design)  
✅ Business Analysis (problem identification → actionable recommendations)  
✅ Cost optimization & supply chain analytics  

---

## 🔮 Future Enhancements (v2.0)

- [ ] Machine Learning: Carrier price prediction model
- [ ] Automation: Scheduled recommendations via email
- [ ] Real-time: Integration with TMS (Transportation Management System)
- [ ] Advanced: Vehicle Routing Problem (VRP) optimization
- [ ] Visualization: Tableau version with enhanced UI

---

## ❓ FAQ

**Q: How is "Potential Savings" calculated?**  
A: (Current cost per km × distance) - (Benchmark rate 0.95 × distance) for each shipment, summed.

**Q: Which carrier should we switch to?**  
A: Local Transport PL offers best rates (0.95 PLN/km). However, maintain strategic mix for capacity. Allocate: 60% Local Transport, 25% DB Schenker (Berlin specialty), 15% backup.

**Q: Can I export the dashboard?**  
A: Yes. Power BI → File → Export to PDF/PowerPoint for stakeholder sharing.

**Q: Is this data real?**  
A: Synthetic dataset modeled on real Polish logistics (accurate routes, distances, realistic carrier rates). Perfect for portfolio/training.

---

## 📞 Contact

**Author:** Mateusz Zambrzycki  
📧 Email: [your-email]  
🔗 LinkedIn: [your-profile]  
💻 GitHub: [your-github]  

---

## 📄 License

Portfolio project. View, study, and adapt for learning purposes. Do not redistribute as your own work.

---

*Last Updated: September 2026*  
*Status: v1.0 - Production Ready*
