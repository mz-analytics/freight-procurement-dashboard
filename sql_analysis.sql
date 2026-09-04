DESCRIBE shipments;							# sprawdzenie jakości danych 
DESCRIBE carriers;

select * from shipments s
limit 20

select * from carriers c

SELECT *
FROM shipments 
WHERE weight_kg <= 0 
   OR distance_km <= 0 
   OR total_cost <= 0;


SELECT s.id, s.date, s.carrier_id 			## brak zleceń bez nadanego przewoźnika
FROM shipments s
LEFT JOIN carriers c ON s.carrier_id = c.id
WHERE c.id IS NULL;


SELECT * 									## Brak przeładowanych transportów 
FROM shipments
WHERE weight_kg > 25000;

SELECT 
    COUNT(*) AS total_rows,
    MIN(date) AS min_date,
    MAX(date) AS max_date,
    MIN(weight_kg) AS min_weight,
    MAX(weight_kg) AS max_weight,
    MIN(total_cost) AS min_cost,
    MAX(total_cost) AS max_cost
FROM shipments;
/* - 5000 wierszy
 * - zakres day 2026-03-06 - 2026-09-01
 * - waga ładunków 1501.0 - 23997.0 [kg]
 * - koszt kursu 57 - 783 [zł]
 * */ 

SELECT 
	s.id, 
	c.name AS carrier_name,
	s.distance_km,
	s.total_cost
FROM shipments s
JOIN carriers c ON s.carrier_id = c.id
limit 5;
	
select  
	c.name as carrier_name,
	COUNT(s.id) as total_shippments,
	ROUND(SUM(s.total_cost),2) as total_cost,
	ROUND(AVG(s.total_cost / distance_km),2) as avg_cost_per_trip,
	ROUND(AVG(s.total_cost),2) as avg_cost_per_km
	from shipments s 
	join carriers c on s.carrier_id = c.id 
	group by c.name
	order by 3;
/* - najtańszy przewoźnik vs najdroższy przewoźnik
 *   Local Transport PL		 Rhenus Logistics
 *   0.95/km		 		 1.35/km			## stawka
 *   965					 1015				## wolumen zleceń
 * 
 *   Wniosek: 42% różnicy w stawce jednostkowej
 *   Rekomendaja: przesunięcie wolumenu
 * */ 
select ### sprawdzenie poprawności wyświetlania trasy
	id,
	CONCAT(origin," ",destination) as route,
	distance_km,
	total_cost
from shipments 
limit 5;

select 
	CONCAT(origin," ",destination) as route,
	COUNT(id) as total_shipments,
	ROUND(SUM(total_cost), 2) as total_budget,
	ROUND(AVG(total_cost), 2) as avg_cost_per_shipment,
	ROUND(SUM(weight_kg), 2) as total_kg
from shipments
group by origin, destination; 


SELECT ##  Które trasy generują największy budżet?
    CONCAT(origin, " ", destination) AS route,
    COUNT(id) AS total_shipments,
    ROUND(SUM(weight_kg) / 1000, 1) AS total_tons,
    ROUND(AVG(total_cost), 2) AS avg_cost,
    ROUND(SUM(total_cost), 2) AS total_budget
FROM shipments
GROUP BY origin, destination
ORDER BY total_budget DESC;
/* - trasa najdroższa vs 		 najtańsza
 *   Warszawa -> Berlin          Mszczonów -> Warszawa
 *   408 349 PLN                 45 270 PLN          ## budżet trasy
 *   693.29 PLN                  71.97 PLN           ## śr. koszt kursu
 *   589                         629                 ## wolumen zleceń
 * 
 *   Wniosek: 3 najdłuższe trasy (Berlin, Gdańsk, Hamburg) pochłaniają ponad 54% budżetu huba
 *   Rekomendacja: negocjacje przetargowe zacząć wyłącznie od tras powyżej 400 km
 * */

SELECT ### Czy na tej samej trasie płacimy różne stawki? 
    origin,
    destination,
    MIN(total_cost) AS min_cena,
    MAX(total_cost) AS max_cena,
    MAX(total_cost) - MIN(total_cost) AS roznica
FROM shipments
GROUP BY origin, destination
ORDER BY roznica DESC;
/* - Max różnica kosztu vs Min różnica kosztu na 1 kursie
 *   Warszawa -> Berlin          Mszczonów -> Warszawa
 *   551 PLN                     57 PLN              ## min cena kursu
 *   783 PLN                     81 PLN              ## max cena kursu
 *   232 PLN                     24 PLN              ## rozstrzał (strata na 1 aucie)
 * 
 *   Wniosek: na każdym kursie do Berlina przepłacamy do 232 PLN zależnie od wybranego przewoźnika
 *   Rekomendacja: wprowadzenie sztywnego contractingu (dedykowany przewoźnik) na trasach międzynarodowych
 * */

SELECT 
    s.origin,
    s.destination,
    c.name,
    COUNT(*) AS liczba_kursow,
    AVG(s.total_cost) AS sredni_koszt
FROM shipments s
JOIN carriers c ON s.carrier_id = c.id
GROUP BY s.origin, s.destination, c.name
ORDER BY s.origin, s.destination, sredni_koszt;
/* - stawki na kluczowej relacji (Mszczonów -> Gdańsk, 420 km)
 *   Local Transport PL          Rhenus Logistics
 *   399.00 PLN                  567.00 PLN          ## średni koszt kursu
 *   102                         125                 ## zrealizowane kursy
 *   40 698 PLN                  70 875 PLN          ## łączny wydatek
 * 
 *   Wniosek: wolumen jest dzielony po równo mimo 168 PLN różnicy na każdym aucie (Rhenus +42%)
 *   Rekomendacja: natychmiastowe ucięcie wolumenu dla Rhenus/DB Schenker i alokacja do Local Transport PL / Kuehne+Nagel
 * */


