from datetime import datetime, timedelta
import random
import mysql.connector

# 1. Polaczenie z baza
conn = mysql.connector.connect(
    host="localhost",
    user="root",
    password="" 
)
cursor = conn.cursor()

cursor.execute("CREATE DATABASE IF NOT EXISTS freight_db")
cursor.execute("USE freight_db")

# 2. Reset i tworzenie tabel
cursor.execute("DROP TABLE IF EXISTS shipments")
cursor.execute("DROP TABLE IF EXISTS carriers")

cursor.execute("""
CREATE TABLE carriers (
    id INT PRIMARY KEY,
    name VARCHAR(50),
    cost_per_km FLOAT
)
""")

cursor.execute("""
CREATE TABLE shipments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    date DATE,
    origin VARCHAR(50),
    destination VARCHAR(50),
    distance_km FLOAT,
    weight_kg FLOAT,
    carrier_id INT,
    total_cost FLOAT
)
""")

# 3. Lista przewoznikow -- id, nazwa, stawka
carriers = [
    (1, "DHL Supply Chain", 1.25),
    (2, "Kuehne+Nagel", 1.15),
    (3, "Local Transport PL", 0.95),
    (4, "Rhenus Logistics", 1.35),
    (5, "DB Schenker", 1.30),
]

for c in carriers:
  cursor.execute(f"INSERT INTO carriers VALUES ({c[0]}, '{c[1]}', {c[2]})")

# 4. Trasy z hubu Mszczonow
routes = [
    ["Mszczonów", "Warszawa", 60],
    ["Mszczonów", "Poznań", 250],
    ["Mszczonów", "Kraków", 280],
    ["Mszczonów", "Wrocław", 220],
    ["Mszczonów", "Gdańsk", 420],
    ["Warszawa", "Poznań", 310],
    ["Warszawa", "Berlin", 580],
    ["Poznań", "Hamburg", 450],
]

# 5. Generowanie 5000 zlecen
records = []
today = datetime.now()

for i in range(5000):
  days = random.randint(1, 180)
  order_date = (today - timedelta(days=days)).strftime("%Y-%m-%d")

  r = random.choice(routes)
  origin = r[0]
  destination = r[1]
  dist = r[2]

  c = random.choice(carriers)
  carrier_id = c[0]
  rate = c[2]

  weight = random.randint(1500, 24000)
  cost = round(dist * rate, 2)

  records.append(
      (order_date, origin, destination, dist, weight, carrier_id, cost)
  )

# 
cursor.executemany(
    """
    INSERT INTO shipments (date, origin, destination, distance_km, weight_kg, carrier_id, total_cost)
    VALUES (%s, %s, %s, %s, %s, %s, %s)
""",
    records,
)

conn.commit()
conn.close()

print("Gotowe. 5000 zlecen wgranych do bazy freight_db.")