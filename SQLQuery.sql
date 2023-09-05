--Q1 who is the senior most employee based on job title ?

Select top 1 * from dbo.employee
order by levels desc 


--Q2 which countries have the most invoice

select COUNT(*) as countries_invoice, billing_country
from dbo.invoice
group by billing_country
order by countries_invoice desc

--Q3 what are top 3 values of total invoice 
select top 3  total,billing_country from dbo.invoice
order by total  desc

--Q4 which city has the best customers? we could like to throw a promotional music festival in the city we made the most money .writw a query
--that return one city that has the heighest sum of the invoice totals . return both the city name & sum of all invoice totals
select top 1  sum(total) sum_total,billing_city 
from dbo.invoice
group by billing_city
order by sum_total desc

--Q5 who is the best customer? the customer who has spent the most money will
--be declared the best customer. write a query tht returns the person who has spent the most money
select top 1  customer.customer_id,customer.first_name,customer.last_name,sum(invoice.total) as total 
from customer
 join invoice
on customer.customer_id=invoice.customer_id
group by customer.customer_id,customer.first_name,customer.last_name
order by total desc 


--Q write  query to return the email,firstname,last name & genre
--of all rock music listeners . return your list ordered alphabitically
--by email starting with A 

select customer.email,customer.first_name,customer.last_name
from customer
join  invoice on customer.customer_id=invoice.customer_id
join invoice_line on invoice.invoice_id=invoice_line.invoice_id
where track_id IN(
SELECT track_id FROM track
JOIN genre ON track.track_id=genre.genre_id
where genre.name LIKE 'ROCK')
ORDER BY email 


--Q lets invite the artist who have written the most rock music
--in our data set.write a query that retuen the artist name and total track count of the top 10 rock bands

--Note- take first connecting table first

select top 10 artist.artist_id,artist.name,COUNT(artist.artist_id) as number
from track 
join album ON album.album_id=track.album_id
join artist on artist.artist_id=album.artist_id
join genre on genre.genre_id=track.genre_id
where genre.name like 'ROCK'
GROUP BY artist.artist_id,artist.name
order by number desc


--Q Return all the track names that have a song length longerr than avg song length.
--return the name and milliseconds for each track .order by the song length with longest songs listed first
select  name,milliseconds 
from track
where milliseconds>(
select AVG(milliseconds) as avg from track
)
order by milliseconds desc


--Q1 find how much amount spent by each customer on artists?write a query
--query to return customer name,artist name and total spend


with best_selling_artist as(
SELECT TOP 1 artist.artist_id as artist_id, artist.name as artist_name,
sum(invoice_line.unit_price*invoice_line.quantity) as total_sales
from invoice_line
JOIN track on track.track_id=invoice_line.track_id
JOIN album on album.album_id=track.album_id
JOIN artist on artist.artist_id=album.artist_id
GROUP BY artist.artist_id,artist.name
ORDER BY 3 DESC

) 
select c.customer_id,c.first_name,c.last_name,bsa.artist_name ,
sum(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id=i.customer_id
JOIN  invoice_line il ON il.invoice_id=i.invoice_id
JOIN track t ON t.track_id=il.track_id
JOIN album alb ON alb.album_id=t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id=alb.artist_id
GROUP BY c.customer_id,c.first_name,c.last_name,bsa.artist_name 
ORDER BY 5 DESC

--Q22. We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the highest amount of purchases. Write a query that
--returns each country along with the top Genre. For countries where the maximum number of purchases is shared return all Genres.
---error unsolved 
with popular_genre as(
SELECT COUNT(il.quantity) AS purchases,c.country,g.name as genre_name,g.genre_id,
ROW_NUMBER() OVER (PARTITION BY c.country ORDER BY COUNT(il.quantity) DESC) as RowNo
from invoice_line il
JOIN invoice i ON il.invoice_id=i.invoice_id
JOIN customer c ON i.customer_id=c.customer_id
JOIN track t ON il.track_id=t.track_id
JOIN genre g ON t.genre_id=g.genre_id
Group By c.country,g.name,g.genre_id

)
select * from popular_genre where RowNo<=1

--second method
WITH popular_genre AS (
    SELECT  
        COUNT(il.quantity) AS purchases,
        c.country,
        g.name AS genre_name,
        g.genre_id,
        ROW_NUMBER() OVER (PARTITION BY c.country ORDER BY   COUNT(il.quantity) DESC ) AS RowNo
    FROM
        invoice_line il
        JOIN invoice i ON il.invoice_id = i.invoice_id
        JOIN customer c ON i.customer_id = c.customer_id
        JOIN track t ON il.track_id = t.track_id
        JOIN genre g ON t.genre_id = g.genre_id
    GROUP BY
        c.country,
        g.name,
        g.genre_id
   
)
select * from popular_genre where RowNo<=1




---Q3write a query that determine the customer that are spent the most on music for each country.
--write a query that return the country along with top customer and how much they have spent .
--for countrries where top customers and how much they have spent. for countries where the top amount spent is shared, provided all customer
-- who has spent this amount
WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY customer.customer_id,first_name,last_name,billing_country
		)
SELECT * FROM Customter_with_country WHERE RowNo <= 1


//////2nd method using recussive --unsolved
With RECURSIVE
customer_with_country as(
select customer.customer_id,customer.first_name,customer.last_name,billing_country,
sum(total) as total_spending
from invoice
Join customer ON customer.customer_id=invoice.customer_id
Group By customer.customer_id,customer.first_name,customer.last_name,invoice.billing_country 
ORDER by customer.customer_id,total_spending DESC ),


country_max_spending as(
select billing_country,MAX(total_spending)  as max_spending
from customer_with_country
group by billing_country)

select cc.billing_country,cc.total_spending,cc.first_name,cc.last_name,cc.customer_id
from customer_with_country cc
JOIN country_max_spending ms
on cc.customer_with_country=ms.country _max_spending
where cc.total_spending=ms.max_spending
order by cc.customer_id
---------------------



