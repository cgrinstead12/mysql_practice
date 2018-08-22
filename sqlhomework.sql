#USE the sakila database
USE sakila;

#1a - Display the first and last names of all actors from the table actor.
SELECT first_name, last_name
FROM actor;

#1b - Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT CONCAT(first_name, " ", last_name) as 'Actor Name'
FROM ACTOR;

#2a - Select Where first name is Joe
SELECT actor_id, first_name, last_name
FROM actor
where first_name = "Joe";

#2b - Select Where last name has a GEN anywhere in the name
SELECT actor_id, first_name, last_name
FROM actor
WHERE last_name LIKE '%GEN%';

/*2c - Find all actors whose last names contain the letters LI. 
This time, order the rows by last name and first name, in that order:*/
SELECT first_name, last_name
FROM actor
WHERE last_name LIKE '%LI%'
ORDER BY last_name, first_name;

/*2d - Using IN, display the country_id and 
country columns of the following countries: Afghanistan, Bangladesh, and China:*/
SELECT country_id,country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

/*3a - You want to keep a description of each actor. You don't think you will be 
performing queries on a description, so create a column in the table actor named 
description and use the data type BLOB (Make sure to research the type BLOB, as 
the difference between it and VARCHAR are significant).*/
ALTER TABLE actor
ADD Description BLOB;

/*3b - Very quickly you realize that entering descriptions for each actor is too
 much effort. Delete the description column.*/
ALTER TABLE actor
DROP Description;

#4a - List the last names of actors, as well as how many actors have that last name.
SELECT first_name, last_name, COUNT(*) 
FROM actor
GROUP BY last_name;

/*4b - List last names of actors and the number of actors who have that last name, but 
only for names that are shared by at least two actors */
SELECT last_name, COUNT(*)
FROM actor
GROUP BY last_name
HAVING COUNT(*) <= 2;

/* 4c - The actor HARPO WILLIAMS was accidentally entered in the actor table 
as GROUCHO WILLIAMS. Write a query to fix the record.*/
UPDATE actor
SET first_name = "Harpo"
WHERE first_name = "Groucho" AND last_name = "Williams";

/*4d - Perhaps we were too hasty in changing GROUCHO to HARPO. 
It turns out that GROUCHO was the correct name after all! In a single query, 
if the first name of the actor is currently HARPO, change it to GROUCHO.*/
UPDATE actor
SET first_name = "Groucho"
WHERE first_name = "Harpo" AND last_name = "Williams";

/* 5a - You cannot locate the schema of the address table. 
Which query would you use to re-create it? */
DESCRIBE sakila.address;

/*6a - Use JOIN to display the first and last names, as well as the address, 
of each staff member. Use the tables staff and address:*/
SELECT staff.first_name, staff.last_name, address.address
FROM staff
LEFT JOIN address ON address.address_id = staff.address_id;

/* 6b - Use JOIN to display the total amount rung up by each staff member 
in August of 2005. Use tables staff and payment.*/
SELECT staff.first_name, staff.last_name, SUM(payment.amount) AS 'TOTAL'
FROM staff LEFT JOIN payment ON staff.staff_id = payment.staff_id
GROUP BY staff.first_name, staff.last_name;

/*6c - List each film and the number of actors who are listed for that film. 
Use tables film_actor and film. Use inner join. */
SELECT film.title AS 'Film Title', COUNT(film_actor.actor_id) AS 'Total Actors'
FROM film LEFT JOIN film_actor ON film.film_id = film_actor.film_id
GROUP BY film.title;

#6d - How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT title AS 'Movie Title', (SELECT COUNT(*) FROM inventory WHERE inventory.film_id = film.film_id) AS 'Number of Copies'
FROM film
WHERE title = "Hunchback Impossible";

/* - 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
List the customers alphabetically by last name: */
SELECT customer.first_name, customer.last_name, sum(payment.amount) as 'Total Paid'
from customer
INNER JOIN payment on payment.customer_id = customer.customer_id
GROUP By first_name, last_name
ORDER BY last_name;


/* - 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
Use subqueries to display the titles of movies starting with the letters K and Q whose language is English. */
SELECT title
FROM film
WHERE (title LIKE 'K%' OR title LIKE 'Q%') AND 
						language_id=(SELECT language_id 
                        FROM language 
                        where name='English');

#7b - Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name
FROM actor
WHERE actor_id IN 
	(SELECT actor_id 
	FROM film_actor 
	WHERE film_id IN 
		(SELECT film_id 
        from film 
        where title='ALONE TRIP'))
        
/* 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email 
 addresses of all Canadian customers. Use joins to retrieve this information. */
 SELECT customer.first_name, customer.last_name, customer.email, country.country
 FROM customer
 INNER JOIN address on address.address_id = customer.address_id
 INNER JOIN city on city.city_id = address.city_id
 INNER JOIN country on country.country_id = city.country_id
 WHERE country = "Canada";
 
 /*7d. Sales have been lagging among young families, and you wish to target all family movies for a 
promotion. Identify all movies categorized as family films. */
SELECT title AS "Family Films"
FROM film 
WHERE film_id IN
	(SELECT film_id
    FROM film_category
    WHERE category_id IN 
		(SELECT category_id 
        FROM category
        WHERE NAME = "Family")
	);
 
/*7e. Display the most frequently rented movies in descending order.
EER rental_id to inventory_id to film_id tables. */
SELECT title, COUNT(rental_id) AS "Rental Count"
FROM film
INNER JOIN inventory ON film.film_id = inventory.film_id
INNER JOIN rental ON inventory.inventory_id = rental.inventory_id
GROUP BY title
ORDER BY COUNT(rental_id) DESC;

#7f. Write a query to display how much business, in dollars, each store brought in.
SELECT store.store_id, SUM(payment.amount) AS '$ Brought In'
FROM store
INNER JOIN customer ON store.store_id = customer.store_id
INNER JOIN payment ON customer.store_id = payment.customer_id
GROUP BY store_id;

/* - 7g. Write a query to display for each store its store ID, city, and country.
store to address to city to country */
SELECT store.store_id, city.city, country.country
FROM store 
INNER JOIN address ON store.address_id = address.address_id
INNER JOIN city ON city.city_id = address.city_id
INNER JOIN country ON city.country_id = country.country_id;

/* - 7h List the top five genres in gross revenue in descending order. (Hint: you
may need to use the following tables: category, film_category, inventory, payment, and rental.) */
SELECT category.name AS 'Category Name', SUM(payment.amount) AS 'Gross Revenue'
FROM category
INNER JOIN film_category ON film_category.category_id = category.category_id
INNER JOIN inventory ON inventory.film_id = film_category.film_id
INNER JOIN rental ON rental.inventory_id = inventory.inventory_id
INNER JOIN payment ON payment.rental_id = rental.rental_id
GROUP BY category.name
ORDER BY SUM(payment.amount) DESC
LIMIT 5;

/* 8a - In your new role as an executive, you would like to have an easy way of viewing the Top five genres 
by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, 
you can substitute another query to create a view. */
create view TopGenres as (
select category.name as 'Category Name', sum(payment.amount) as 'Gross Revenue'
from category
INNER JOIN film_category ON film_category.category_id = category.category_id
INNER JOIN inventory ON inventory.film_id = film_category.film_id
INNER JOIN rental ON rental.inventory_id = inventory.inventory_id
INNER JOIN payment ON payment.rental_id = rental.rental_id
GROUP BY category.name
ORDER BY SUM(payment.amount) DESC
LIMIT 5);

#8b - How would you display the view that you created in 8a?
SELECT * FROM topgenres;

#8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW topgenres;
