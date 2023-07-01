/*

Music Store Database Analysis usign SQL

*/

-- Q: Find the oldest employee based on job title
SELECT first_name, last_name, title, levels
FROM employee
ORDER BY levels DESC
LIMIT 1

-- Q: Find the countries with most Invoices
SELECT billing_country, COUNT(*) AS invoices_count
FROM invoice
GROUP BY billing_country
ORDER BY invoices_count DESC

-- Q: Top 3 total invoice values
SELECT total
FROM invoice
ORDER BY total DESC
LIMIT 3

-- Q: Find the city with the highest sum of total invoice
SELECT billing_city, SUM(total) AS invoice_city_total
FROM invoice
GROUP BY billing_city
ORDER BY invoice_city_total DESC
LIMIT 1

-- Q: Find the customer that has spent the most money
SELECT c.customer_id, c.first_name, c.last_name, SUM(i.total) AS customer_total
FROM customer c
JOIN invoice i
ON c.customer_id = i.customer_id
GROUP BY c.customer_id
ORDER BY customer_total DESC
LIMIT 1

-- Q: Find the email, first name, last name and genre of all rock music listeners
-- first method query
SELECT DISTINCT c.email, c.first_name, c.last_name
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
WHERE track_id IN(
	SELECT track_id FROM track
	JOIN genre ON track.genre_id = genre.genre_id
	WHERE genre.name LIKE 'Rock'
)
ORDER BY c.email;

-- second method query
SELECT DISTINCT c.email, c.first_name, c.last_name, g.name AS genre
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN genre g ON t.genre_id = g.genre_id
WHERE g.name LIKE 'Rock'
ORDER BY c.email;

-- Q: Find the artist name and count of total tracks of the top 10 bands
SELECT a.artist_id, a.name, COUNT(a.artist_id) AS tracks_count
FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist a ON a.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY a.artist_id
ORDER BY tracks_count DESC
LIMIT 10;

/* Q: Find the name and track length of each track where the track length is longer than the average length. 
Order by the length of the track in descecnding order. */
SELECT name, milliseconds
FROM track
WHERE milliseconds > (
	SELECT AVG(milliseconds) FROM track
)
ORDER BY milliseconds DESC

/* Q: Find how much each customer spent on artists. Return the customer name, artist name, and total money spent. */
WITH highest_selling_artist AS (
	SELECT ar.artist_id, ar.name AS artist_name, SUM(il.unit_price*il.quantity) AS total_sales
	FROM invoice_line il
	JOIN track t ON t.track_id = il.track_id
	JOIN album al ON al.album_id = t.album_id
	JOIN artist ar ON ar.artist_id = al.artist_id
	GROUP BY ar.artist_id
	ORDER BY total_sales DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, hsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_customer_spent
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN highest_selling_artist hsa ON hsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC

/* Q: Find the most popular genre for each country. The genre with the most purchases is the most popular. */
WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre 
WHERE RowNo <= 1

/* Q: Find the customer that has spent the most on music for each country.
Return the country along with the top customer and how much they spent.*/
WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1
