/*

COVID-19 Data Analysis using SQL

*/

-- Select data that will be analysed
SELECT country, date, total_cases, new_cases, total_deaths, population
FROM covid_deaths
ORDER BY 1, 2

-- Total cases vs total deaths
SELECT country, date, total_cases, total_deaths, (CAST (total_deaths AS decimal)/total_cases)*100 AS death_percentage
FROM covid_deaths
WHERE country='India'
ORDER BY 1, 2

-- Total cases vs population
SELECT country, date, total_cases, population, (CAST (total_cases AS decimal)/population)*100 AS population_infected_percentage
FROM covid_deaths
WHERE country='India'
ORDER BY 1, 2

-- Countries with highest infection rate compared to population
SELECT country, population, MAX(total_cases) AS highest_cases_count, MAX((CAST (total_cases AS decimal)/population)*100) as population_infected_percentage
FROM covid_deaths
GROUP BY country, population
ORDER BY population_infected_percentage DESC

-- Countries with highest death
SELECT country, MAX(total_deaths) as total_death_count
FROM covid_deaths
WHERE continent IS NOT NULL AND total_deaths IS NOT NULL
GROUP BY country
ORDER BY total_death_count DESC

-- Showing continents with highest death
SELECT continent, MAX(total_deaths) as total_death_count
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC

-- Total new cases vs total new deaths
SELECT country, SUM(new_cases) as total_new_cases, SUM(new_deaths) as total_new_deaths
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY country
ORDER BY total_new_cases DESC

-- Shows percentage of population that has recieved at least one covid vaccine
SELECT d.continent, d.country, d.date, d.population, v.new_vaccinations, 
SUM(v.new_vaccinations) OVER (PARTITION BY d.country ORDER BY d.country, d.date) as rolling_people_vaccinated
FROM covid_deaths d JOIN covid_vaccinations v
ON d.country = v.country AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY 2, 3

-- Using CTE to perform Calculation on Partition By in previous query
WITH popvac (continent, country, date, population, new_vaccinations, rolling_people_vaccinated)
AS
(
	SELECT d.continent, d.country, d.date, d.population, v.new_vaccinations, 
	SUM(v.new_vaccinations) OVER (PARTITION BY d.country ORDER BY d.country, d.date) as rolling_people_vaccinated
	FROM covid_deaths d JOIN covid_vaccinations v
	ON d.country = v.country AND d.date = v.date
	WHERE d.continent IS NOT NULL
)
SELECT *, (CAST (rolling_people_vaccinated AS decimal)/population)*100 AS percent_vaccinated
FROM popvac

-- Using Temp Table to perform Calculation on Partition By in previous query
DROP TABLE IF EXISTS percent_vaccinated_population

CREATE TABLE percent_vaccinated_population
(
	continent varchar(255),
	country varchar(255),
	date date,
	population double precision,
	new_vaccinations double precision,
	rolling_people_vaccinated double precision
)

INSERT INTO percent_vaccinated_population
SELECT d.continent, d.country, d.date, d.population, v.new_vaccinations, 
SUM(v.new_vaccinations) OVER (PARTITION BY d.country ORDER BY d.country, d.date) AS rolling_people_vaccinated
FROM covid_deaths d JOIN covid_vaccinations v
ON d.country = v.country AND d.date = v.date

SELECT *, (CAST (rolling_people_vaccinated AS decimal)/population)*100 AS percent_vaccinated
FROM percent_vaccinated_population

-- create view to store data for a visualization
CREATE VIEW percent_population_vaccinated AS
SELECT d.continent, d.country, d.date, d.population, v.new_vaccinations, 
SUM(v.new_vaccinations) OVER (PARTITION BY d.country ORDER BY d.country, d.date) as rolling_people_vaccinated
FROM covid_deaths d JOIN covid_vaccinations v
ON d.country = v.country AND d.date = v.date
WHERE d.continent IS NOT NULL













