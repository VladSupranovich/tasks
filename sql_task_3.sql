--1. Вывести количество фильмов в каждой категории, отсортировать по убыванию.

SELECT c."name", 
		count(fc.film_id ) AS number_of_films
	FROM category c 
	JOIN film_category fc 
	ON c.category_id = fc.category_id 
		GROUP BY c."name"
		ORDER BY number_of_films DESC;
	
	

--2. Вывести 10 актеров, чьи фильмы большего всего арендовали, отсортировать по убыванию.

SELECT a.first_name ||' '|| a.last_name AS full_name, 
		count(r.rental_id) AS number_of_films
	FROM actor a
	JOIN film_actor fa 
	ON a.actor_id = fa.actor_id 
	JOIN inventory i 
	ON fa.film_id = i.film_id 
	JOIN rental r 
	ON i.inventory_id = r.inventory_id 
		GROUP BY a.first_name, a.last_name
		ORDER BY number_of_films DESC;
		
	

--3. Вывести категорию фильмов, на которую потратили больше всего денег.

SELECT c."name" , 
		sum(p.amount) AS amount
	FROM category c 
	JOIN film_category fc 
	ON c.category_id = fc.category_id 
	JOIN film f 
	ON fc.film_id = f.film_id 
	JOIN inventory i 
	ON f.film_id = i.film_id 
	JOIN rental r 
	ON i.inventory_id = r.inventory_id 
	JOIN payment p 
	ON r.rental_id = p.rental_id 
	GROUP BY c."name"
	ORDER BY amount DESC
	LIMIT 1;



--4. Вывести названия фильмов, которых нет в inventory. Написать запрос без использования оператора IN.

WITH ids AS (
	SELECT f.film_id 
	FROM film f
	EXCEPT 
	SELECT i.film_id
	FROM inventory i )
		SELECT f.title 
			FROM film f
			JOIN ids 
			ON f.film_id = ids.film_id;
		
		

--5. Вывести топ 3 актеров, которые больше всего появлялись в фильмах в категории “Children”. 
-- Если у нескольких актеров одинаковое кол-во фильмов, вывести всех.

SELECT full_name FROM (
SELECT a.first_name ||' '|| a.last_name AS full_name, 
		count(f.film_id) AS num_of_films,
		RANK () OVER (ORDER BY count(f.film_id) desc) AS rating 
	FROM actor a 
	JOIN film_actor fa 
	ON a.actor_id = fa.actor_id 
	JOIN film f 
	ON fa.film_id = f.film_id 
	JOIN film_category fc 
	ON f.film_id = fc.film_id 
	JOIN category c 
	ON fc.category_id = c.category_id 
		WHERE c."name"  = 'Children'
		GROUP BY a.first_name, a.last_name) tab
WHERE rating <= 3;



--6. Вывести города с количеством активных и неактивных клиентов (активный — customer.active = 1). 
-- Отсортировать по количеству неактивных клиентов по убыванию.

SELECT DISTINCT c.city,
	count(cs.customer_id) FILTER(WHERE cs.active = 1) OVER(PARTITION BY c.city) AS active,
	count(cs.customer_id) FILTER(WHERE cs.active = 0) OVER(PARTITION BY c.city) AS inactive
	FROM city c 
	JOIN address a 
	ON c.city_id  = a.city_id 
	JOIN store s 
	ON a.address_id = s.address_id 
	JOIN customer cs 
	ON s.store_id  = cs.store_id 
		ORDER BY inactive DESC;
-- тут есть делать join напрямую customer.address_id = address.address_id будет другой результат, что немного странно) 
--я посчитал что правильнее сделть join через store, так как кастомеры арендуют все же через стор 
--и поэтому ведут активность в городе где находится этот стор.
	
	
	
--7. Вывести категорию фильмов, у которой самое большое кол-во часов суммарной аренды в городах (customer.address_id в этом city), 
--и которые начинаются на букву “a”. То же самое сделать для городов в которых есть символ “-”. Написать все в одном запросе.
	
WITH tab AS (
SELECT DISTINCT c."name" , 
	sum(EXTRACT(EPOCH FROM r.return_date - r.rental_date)) FILTER (WHERE lower(ct.city) LIKE 'a%') OVER (PARTITION BY c."name")/3600 AS hours_rent_1,
	sum(EXTRACT(EPOCH FROM r.return_date - r.rental_date)) FILTER (WHERE lower(ct.city) LIKE '%-%') OVER (PARTITION BY c."name")/3600 AS hours_rent_2
		FROM category c 
		JOIN film_category fc 
		ON c.category_id = fc.category_id 
		JOIN film f 
		ON fc.film_id = f.film_id 
		JOIN inventory i 
		ON f.film_id = i.inventory_id 
		JOIN rental r 
		ON i.inventory_id = r.inventory_id 
		JOIN customer cs 
		ON r.customer_id = cs.customer_id 
		JOIN address a 
		ON cs.address_id = a.address_id
		JOIN city ct 
		ON a.city_id = ct.city_id) 
			SELECT "name" FROM tab
				WHERE hours_rent_1 = (SELECT max(hours_rent_1) FROM tab)
				OR hours_rent_2 = (SELECT max(hours_rent_2) FROM tab);
