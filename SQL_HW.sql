-- 1a. Display the first and last names of all actors from the table actor.
SELECT a.first_name, a.last_name FROM actor a;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT CONCAT(a.first_name, " " , a.last_name) as 'Actor Name' FROM actor a;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT * FROM actor a
WHERE a.first_name LIKE 'JOE';

-- 2b. Find all actors whose last name contain the letters GEN:
SELECT * FROM actor a
WHERE a.last_name LIKE '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order
SELECT * FROM actor a
WHERE a.last_name LIKE '%LI%'
ORDER BY 3, 2 ASC;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT c.country_id, c.country FROM country c
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. Add a middle_name column to the table actor. Position it between first_name and last_name. Hint: you will need to specify the data type.
-- Where to add in a specific position
ALTER TABLE actor
ADD middle_name VARCHAR(35) AFTER first_name;

-- 3b. You realize that some of these actors have tremendously long last names. Change the data type of the middle_name column to blobs.
ALTER TABLE actor
modify COLUMN middle_name BLOB;

-- 3c. Now delete the middle_name column.
ALTER TABLE actor
DROP middle_name;

-- 4a.List the last names of actors, as well as how many actors have that last name.
SELECT a.last_name, COUNT(*) as count_of_lastname FROM actor a
GROUP BY 1;

-- 4b 
SELECT a.last_name, COUNT(*) as count_of_lastname FROM actor a
GROUP BY 1
HAVING count_of_lastname > 1;

-- 4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.
UPDATE actor 
SET first_name='HARPO'
WHERE actor_id = 172;

-- 4d. don't know what this means - STILL TO DO
UPDATE actor 
SET first_name='GROUCHO'
WHERE actor_id = 172;

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT s.first_name, s.last_name, a.address FROM staff s
JOIN address a ON a.address_id=s.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT s.first_name, s.last_name, SUM(p.amount) as total_payments_rung FROM staff s
JOIN payment p ON p.staff_id = s.staff_id
GROUP BY 1, 2
ORDER BY 3;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT f.title, COUNT(actor_id) as number_actors
FROM film_actor fa
INNER JOIN film f ON fa.film_id = f.film_id
GROUP BY 1;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT f.title, COUNT(inventory_id) FROM film f
JOIN inventory i ON f.film_id=i.film_id
GROUP BY 1
HAVING f.title='HUNCHBACK IMPOSSIBLE';

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT c.first_name, c.last_name, SUM(p.amount) AS total_paid FROM customer c
JOIN payment p on c.customer_id=p.customer_id
GROUP BY 1, 2
ORDER BY 2;

-- 7a -- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT f2.title 
	FROM film f2 
    WHERE f2.title LIKE 'k%' OR f2.title LIKE 'q%'
    AND f2.film_id IN (

	SELECT f.film_id
	FROM film f 
		JOIN language l ON l.language_id = f.language_id
	WHERE l.name = 'English'
);

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT t.first_name, t.last_name FROM
	(SELECT a.first_name, a.last_name, fa.film_id, f.title FROM actor a 
	JOIN film_actor fa ON a.actor_id = fa.actor_id
    JOIN film f ON fa.film_id=f.film_id
	) as t
WHERE t.title IN ("ALONE TRIP");

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT t.first_name, t.last_name, t.email FROM
	(SELECT c.first_name, c.last_name, c.email, co.country FROM customer c 
	JOIN address ad ON ad.address_id = c.customer_id
	JOIN city ci ON ci.city_id=ad.address_id
	JOIN country co ON co.country_id=ci.country_id
	GROUP BY 1, 2, 3 ) as t
WHERE t.country IN ("Canada");

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT t.title FROM
	(SELECT f.title, c.name FROM film_category fc
	JOIN category c ON c.category_id=fc.category_id
	JOIN film f on f.film_id=fc.film_id) as t
WHERE t.name IN ("Family"); 

-- 7e. Display the most frequently rented movies in descending order.
-- NEED FILM RENTAL INVENTORY
SELECT f.title, COUNT(r.rental_id) as times_rented FROM film f
JOIN inventory i ON i.film_id=f.film_id
JOIN rental r ON r.inventory_id=i.inventory_id
GROUP BY 1 
ORDER BY 2 DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT s.store_id, SUM(p.amount) as total_sales FROM store s
JOIN staff st ON st.store_id = s.store_id
JOIN payment p ON p.staff_id = st.staff_id
GROUP BY 1;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT s.store_id, ci.city, co.country FROM store s
JOIN address a ON a.address_id = s.address_id
JOIN city ci ON ci.city_id = a.city_id
JOIN country co ON co.country_id = ci.country_id;

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT c.name, SUM(p.amount) as total_revenue FROM category c
JOIN film_category fc ON fc.category_id = c.category_id
JOIN inventory i ON i.film_id = fc.film_id
JOIN rental r ON r.inventory_id = i.inventory_id
JOIN payment p ON p.rental_id = r.rental_id
GROUP BY 1
ORDER BY 2 DESC LIMIT 5;

-- 8a. Create View
CREATE VIEW `top_five_genres` AS 
	SELECT c.name, SUM(p.amount) as total_revenue FROM category c
	JOIN film_category fc ON fc.category_id = c.category_id
	JOIN inventory i ON i.film_id = fc.film_id
	JOIN rental r ON r.inventory_id = i.inventory_id
	JOIN payment p ON p.rental_id = r.rental_id
	GROUP BY 1
	ORDER BY 2 DESC LIMIT 5;

-- 8b. Display View
SELECT * FROM top_five_genres;

-- 8c. Display View
DROP VIEW top_five_genres