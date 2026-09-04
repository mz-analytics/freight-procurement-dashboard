# Freight Procurement & Carrier Benchmarking Dashboard

![Power BI](https://img.shields.io/badge/Power_BI-Desktop-F2C811?style=flat&logo=powerbi&logoColor=black)
![Python](https://img.shields.io/badge/Python-3.11+-3776AB?style=flat&logo=python&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-8.0-4479A1?style=flat&logo=mysql&logoColor=white)

Projekt analityczny oparty na danych z 5 000 zleceń transportowych realizowanych z hubu w Mszczonowie na 8 głównych kierunkach krajowych i międzynarodowych. Celem było zestawienie stawek 5 stałych przewoźników, wyłapanie anomalii kosztowych i policzenie realnego potencjału oszczędności przy renegocjacji umów[cite: 2].

![Podgląd dashboardu](dashboard_preview.png)

---

## Główne wnioski i liczby

* **Łączny koszt transportu:** 1,91M PLN (5 000 zleceń, 63,7 tys. ton ładunku)[cite: 2].
* **Potencjał oszczędności:** **400,61 tys. PLN** (ok. 21% całego budżetu).
* **Średnia stawka:** 1,20 PLN/km.
* **Rozstrzał stawek:** od **0,95 PLN/km** (*Local Transport PL* – stawka benchmarkowa) do **1,35 PLN/km** (*Rhenus Logistics*)[cite: 2].
* **Największy problem:** Trasa `Warszawa -> Berlin` generuje aż 83,8 tys. PLN przepłaconych kosztów przez zbyt duży udział najdroższych przewoźników (*Rhenus* i *DB Schenker*)[cite: 2].

---

## Architektura i etapy projektu

1. **Baza danych (MySQL):** Dwie powiązane tabele (`shipments` i `carriers`) z 5 000 zleceń logistycznych generowanych z realistycznymi dystansami i wagami[cite: 2].
2. **Skrypty pomocnicze (Python):** 
   * `setup_db.py` – utworzenie bazy, schematu i seed danych[cite: 2].
   * `analysis.py` – wstępna agregacja w Pandas, wyliczenie kosztu za kg i eksport podsumowań do Excela.
3. **Model i raport (Power BI):** Model gwiazdy, miary w DAX (kalkulacja benchmarku, dynamiczne alerty kolorystyczne) oraz *Decomposition Tree* do badania źródeł wycieku marży.

---

## Kluczowe miary DAX

**1. Wyliczenie oszczędności względem benchmarku (0.95 PLN/km):**
```dax
Potential Savings = 
SUMX(
    'freight_db shipments',
    'freight_db shipments'[total_cost] - ('freight_db shipments'[distance_km] * [Optimal Benchmark Rate])
)
