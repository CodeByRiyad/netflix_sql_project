--1. Count the number of Movies vs TV Shows

SELECT
	type,
	COUNT(type) AS total_content
FROM netflix
GROUP BY type;

--2. Find the most common rating for movies and TV shows


SELECT
	type,
	rating
FROM
(
	SELECT
		type,
		rating,
		COUNT(*) AS total_rating,
		DENSE_RANK() OVER(PARTITION BY type ORDER BY COUNT(rating) DESC) AS rank_of_rating
		FROM netflix
	GROUP BY type, rating
)t
WHERE rank_of_rating = 1;


--3. List all movies released in a specific year (e.g., 2020)

SELECT *
FROM netflix
WHERE type = 'Movie' AND release_year = 2020;


--4. Find the top 5 countries with the most content on Netflix

SELECT TOP 5
	unique_country AS country,
	COUNT(unique_country) AS content_per_country
FROM
(
	SELECT 
		type,
		value AS unique_country
	FROM netflix
	cross apply string_split(country, ',')
)t
GROUP BY unique_country
ORDER BY content_per_country DESC;


--5. Identify the longest movie

SELECT TOP 1
	title,
	duration
FROM
	(SELECT 
		type,
		title,
		duration,
		CAST(SUBSTRING(duration, 1, len(duration) - 4) AS INT) AS duration1
		--REPLACE(duration, ' min', '') AS duration2
	FROM netflix
	WHERE type = 'Movie')t
ORDER BY duration1 DESC;

--6. Find content added in the last 5 years

SELECT
	*
FROM
(
	SELECT *,
	CAST(date_added AS DATE) AS string_to_date,
	CAST(GETDATE() AS DATE) AS today_date
	FROM netflix)t
WHERE DATEDIFF(year, string_to_date, today_date) <= 5;


--7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT
	type,
	title,
	director
FROM
	(SELECT *,
		VALUE AS one_director_by_movie
	FROM netflix
	CROSS APPLY STRING_SPLIT(director, ',')
	WHERE director IS NOT NULL)t
WHERE one_director_by_movie = 'Rajiv Chilaka';


--8. List all TV shows with more than 5 seasons
SELECT
title,
duration
FROM
(
	SELECT
		title,
		duration,
		CASE
			WHEN duration = '1 Season' THEN 1
			ELSE REPLACE(duration, 'Seasons', '')
		END season_num
	FROM netflix
	WHERE type = 'TV show')t
WHERE season_num > 5;

--9. Count the number of content items in each genre

SELECT
VALUE AS genre,
COUNT(VALUE) AS total_content
FROM netflix
CROSS APPLY STRING_SPLIT(listed_in, ',')
GROUP BY VALUE
ORDER BY total_content DESC;


--10.Find each year and the average numbers of content release in India on netflix. 
--return top 5 year with highest avg content release!

SELECT TOP 5
	YEAR(date_added) AS added_year,
	COUNT(*) AS total_content_per_year,
	ROUND(CAST(COUNT(*) AS FLOAT)/(SELECT COUNT(*) FROM netflix WHERE country = 'India')*100, 2) AS avg_content_per_year
FROM netflix
WHERE country LIKE '%India%'
GROUP BY YEAR(date_added)
ORDER BY avg_content_per_year DESC;



--11. List all movies that are documentaries

SELECT 
	type,
	title,
	listed_in
FROM netflix
WHERE type = 'Movie'
AND listed_in LIKE '%Documentaries%';


--12. Find all content without a director

SELECT 
	type, 
	title
FROM netflix
WHERE director IS NULL;


--13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

SELECT 
	*
FROM netflix
WHERE type = 'Movie'
AND
casts LIKE '%Salman Khan%'
AND YEAR(GETDATE()) - release_year <= 10


--14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

SELECT TOP 10
VALUE AS actor,
COUNT(*) AS total_appear
FROM netflix
CROSS APPLY STRING_SPLIT(casts, ',')
WHERE type = 'Movie' AND
	country LIKE '%India%'
GROUP BY VALUE
ORDER BY total_appear DESC



/*15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.*/


SELECT
	content_label,
	COUNT(content_label) AS total_cotent
FROM
(
SELECT
	CASE
		WHEN description LIKE '%kill%' THEN 'Bad'
		WHEN description LIKE '%viiolence%' THEN 'Bad'
		ELSE 'Good'
	END AS content_label
FROM netflix)t
GROUP BY content_label
