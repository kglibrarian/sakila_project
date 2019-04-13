-- Sakila SQL Script

-- Make it so all of the following code will affect sakila_db --
USE sakila;

-- 1a. Display the first and last names of all actors from the table `actor`.
SELECT first_name, last_name FROM sakila.actor;

--  1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
SELECT concat(first_name, ' ', last_name) AS Actor_Name FROM sakila.actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
-- What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name 
FROM sakila.actor
WHERE first_name = "Joe";

-- 2b. Find all actors whose last name contain the letters `GEN`:
SELECT * FROM sakila.actor WHERE last_name LIKE '%GEN%';

-- 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, 
-- in that order:
SELECT * FROM sakila.actor WHERE last_name LIKE '%LI%' ORDER BY 3, 2;

-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan,  
-- Bangladesh, and China:
SELECT country_id, country FROM sakila.country WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, 
-- so create a column in the table `actor` named `description` and use the data type `BLOB` (Make sure to research 
-- the type `BLOB`, as the difference between it and `VARCHAR` are significant).
ALTER TABLE sakila.actor
ADD description BLOB;
SELECT * from sakila.actor;


-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.

ALTER TABLE sakila.actor
DROP COLUMN description; 
SELECT * from sakila.actor;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(last_name) FROM sakila.actor GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that 
-- are shared by at least two actors
SELECT last_name, COUNT(last_name) FROM sakila.actor GROUP BY last_name HAVING COUNT(last_name) >= 2;

-- 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. 
-- Write a query to fix the record.
UPDATE sakila.actor
SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO' and last_name = 'WILLIAMS';
SELECT * FROM sakila.actor WHERE last_name = 'WILLIAMS';

-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct 
-- name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
UPDATE sakila.actor
SET first_name = 'GROUCHO'
WHERE first_name = 'HARPO' and last_name = 'WILLIAMS';
SELECT * FROM sakila.actor WHERE last_name = 'WILLIAMS';

-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
 -- Hint: [https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html]
 -- (https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html)
 SHOW CREATE TABLE sakila.address;

-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. 
-- Use the tables `staff` and `address`:
SELECT a.first_name, a.last_name, b.address 
FROM sakila.staff a LEFT JOIN sakila.address b 
ON a.address_id = b.address_id;

-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
SELECT a.first_name, a.last_name, b.total_amount 
FROM sakila.staff a LEFT JOIN 
	(SELECT staff_id, SUM(amount) AS total_amount FROM sakila.payment GROUP BY 1) b 
ON a.staff_id = b.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` 
-- and `film`. Use inner join.
SELECT a.title, b.total_actors
FROM sakila.film a INNER JOIN (SELECT film_id, COUNT(actor_id) AS total_actors FROM sakila.film_actor GROUP BY 1) b
ON a.film_id = b.film_id;

-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT COUNT(film_id) FROM sakila.inventory WHERE film_id IN (
SELECT film_id FROM sakila.film
WHERE title LIKE '%Hunchback Impossible%');

-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. 
-- List the customers alphabetically by last name:
  -- ![Total amount paid](Images/total_payment.png)
SELECT a.first_name, a.last_name, b.total_amount FROM sakila.customer a LEFT JOIN 
	(SELECT customer_id, SUM(amount) AS total_amount FROM sakila.payment GROUP BY customer_id) b
ON a.customer_id = b.customer_id
ORDER BY a.last_name;
    
--  7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, 
-- films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles 
-- of movies starting with the letters `K` and `Q` whose language is English.
-- SELECT title, language_id FROM sakila.film WHERE title LIKE 
SELECT title, language_id FROM sakila.film WHERE ((SUBSTRING(title, 1, 1) = "K" OR SUBSTRING(title, 1, 1) = "Q") 
AND language_id IN (SELECT language_id FROM sakila.language WHERE name = "English"));

-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT first_name, last_name FROM sakila.actor WHERE actor_id IN (
SELECT actor_id FROM sakila.film_actor WHERE film_id IN (
SELECT film_id FROM sakila.film WHERE title = 'Alone Trip'));


-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email 
-- addresses of all Canadian customers. Use joins to retrieve this information.

-- CREATE TABLE canadacustomers
SELECT a.first_name, a.last_name, a.email, d.country
FROM sakila.customer a
INNER JOIN address b
    ON b.address_id = a.address_id
INNER JOIN city c
    ON c.city_id = b.city_id
INNER JOIN country d
    ON d.country_id = c.country_id
WHERE d.country = "Canada";

 -- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as _family_ films.

SELECT a.title, c.name
FROM sakila.film a
INNER JOIN film_category b
    ON b.film_id = a.film_id
INNER JOIN category c
    ON c.category_id = b.category_id
WHERE c.name = "Family";

-- 7e. Display the most frequently rented movies in descending order.

SELECT title, COUNT(inventory_id) number_rentals FROM
(SELECT a.title, c.inventory_id
FROM sakila.film a
INNER JOIN sakila.inventory b
    ON b.film_id = a.film_id
INNER JOIN rental c
    ON c.inventory_id = b.inventory_id) d
GROUP BY title
ORDER BY number_rentals DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT store_id, SUM(amount) AS total_amount FROM(
SELECT a.staff_id, a.amount, a.rental_id, b.store_id
FROM sakila.payment a
LEFT JOIN sakila.staff b
    ON a.staff_id = b.staff_id) c
GROUP BY 1 
ORDER BY 1;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT a.store_id, c.city, d.country
FROM sakila.store a
INNER JOIN sakila.address b
    ON b.address_id = a.address_id
INNER JOIN sakila.city c
    ON c.city_id = b.city_id
INNER JOIN sakila.country d
    ON d.country_id = c.country_id; 

 -- 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the 
 -- following tables: category, film_category, inventory, payment, and rental.)
SELECT name, SUM(amount) gross_revenue FROM(
SELECT a.name, e.amount
FROM sakila.category a
INNER JOIN sakila.film_category b
    ON b.category_id = a.category_id
INNER JOIN sakila.inventory d
    ON d.film_id = b.film_id
INNER JOIN sakila.rental c
    ON c.inventory_id = d.inventory_id
INNER JOIN sakila.payment e
    ON e.rental_id = c.rental_id) f
 GROUP BY 1
 ORDER BY 2 DESC
 LIMIT 5;


-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres 
-- by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you 
-- can substitute another query to create a view.
CREATE VIEW top_five_genres AS
SELECT name, SUM(amount) gross_revenue FROM(
SELECT a.name, e.amount
FROM sakila.category a
INNER JOIN sakila.film_category b
    ON b.category_id = a.category_id
INNER JOIN sakila.inventory d
    ON d.film_id = b.film_id
INNER JOIN sakila.rental c
    ON c.inventory_id = d.inventory_id
INNER JOIN sakila.payment e
    ON e.rental_id = c.rental_id) f
 GROUP BY 1
 ORDER BY 2 DESC
 LIMIT 5;

-- 8b. How would you display the view that you created in 8a?
SELECT * FROM sakila.top_five_genres;

-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW sakila.top_five_genres; 

-- Tables in Sakila Database 
-- actor 
-- actor_info 
-- address 
-- category 
-- city
-- country
-- customer
-- customer_list
-- film 
-- film_actor 
-- film_category 
-- film_list 
-- film_text 
-- inventory 
-- language 
-- nicer_but_slower_film_list
-- payment
-- rental
-- sales_by_film_category
-- sales_by_store
-- staff
-- staff_list
-- store
