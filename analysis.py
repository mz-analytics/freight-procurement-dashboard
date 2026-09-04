import mysql.connector
import pandas as pd

# 1. Pobranie danych z bazy MySQL
conn = mysql.connector.connect(
    host="localhost",
    user="root",
    password="",  
    database="freight_db",
)

query = """
SELECT 
    s.id,
    s.date,
    s.origin,
    s.destination,
    s.distance_km,
    s.weight_kg,
    s.total_cost,
    c.name AS carrier_name,
    c.cost_per_km
FROM shipments s
JOIN carriers c ON s.carrier_id = c.id
"""

df = pd.read_sql_query(query, conn)
conn.close()

# 2. Obliczenia i nowe kolumny
df["route"] = df["origin"] + " -> " + df["destination"]
df["cost_per_kg"] = round(df["total_cost"] / df["weight_kg"], 4)

print("--- 1. PODSUMOWANIE TRAS ---")
routes_summary = (
    df.groupby("route")
    .agg(
        total_cost=("total_cost", "sum"),
        avg_cost=("total_cost", "mean"),
        shipments_count=("id", "count"),
        avg_distance=("distance_km", "mean"),
    )
    .round(2)
)
print(routes_summary.sort_values(by="total_cost", ascending=False))

print("\n--- 2. POROWNANIE PRZEWOZNIKOW ---")
carriers_summary = (
    df.groupby("carrier_name")
    .agg(
        total_spent=("total_cost", "sum"),
        avg_cost=("total_cost", "mean"),
        shipments=("id", "count"),
        avg_cost_per_kg=("cost_per_kg", "mean"),
    )
    .round(2)
)
print(carriers_summary.sort_values(by="avg_cost"))

print("\n--- 3. NAJDROZSZE PRZESYLKI (POWYZEJ SREDNIEJ) ---")
avg_cost = df["total_cost"].mean()
expensive_shipments = df[df["total_cost"] > avg_cost * 1.5]
expensive_shipments = expensive_shipments[
    ["date", "route", "carrier_name", "total_cost"]
]
print(f"Sredni koszt przesylki: {round(avg_cost, 2)} PLN")
print(expensive_shipments.sort_values(by="total_cost", ascending=False).head(5))

# 4. Zapis do Excela
with pd.ExcelWriter("freight_analysis.xlsx", engine="openpyxl") as writer:
  df.to_excel(writer, sheet_name="Dane_Surowe", index=False)
  routes_summary.to_excel(writer, sheet_name="Podsumowanie_Tras")
  carriers_summary.to_excel(writer, sheet_name="Przewoznicy")
  expensive_shipments.to_excel(writer, sheet_name="Drogie_Przesylki", index=False)

print("\nPlik freight_analysis.xlsx zostal wygenerowany pomyslnie.")