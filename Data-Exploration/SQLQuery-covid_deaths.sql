-- Select the data that we are going to be using
SELECT *
FROM Covid_Database.coviddeaths
WHERE continent is not NULL
ORDER BY 1,2;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Covid_Database.coviddeaths
ORDER BY 1,2;

-- Looking at total cases vs total deaths
-- Shows the likelihood of dying if you contact covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM Covid_Database.coviddeaths
WHERE location = 'Malaysia'
ORDER BY 1,2;

-- Looking at total cases vs populations
-- Shows what percentage of populations who got Covid

SELECT location, date, total_cases, population, (total_cases/population)*100 AS ContactedPopulation
FROM Covid_Database.coviddeaths
ORDER BY 1,2;

-- What countries has the highest infection rate 
-- Looking at countries with highest infection rate compared to population

SELECT location, MAX(total_cases) AS HighestInfectionCount, population, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM Covid_Database.coviddeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected desc;

-- Showing Countries with highest death count per population 

SELECT location, MAX(CAST(total_deaths as SIGNED)) AS TotalDeathCount
FROM Covid_Database.coviddeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount desc;

-- BREAK IT DOWN BY CONTINENT

SELECT continent, MAX(cast(total_deaths as SIGNED)) AS TotalDeathCount
FROM Covid_Database.coviddeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount desc;

-- Showing continents with the highest death count
SELECT continent, MAX(cast(total_deaths as SIGNED)) AS TotalDeathCount
FROM Covid_Database.coviddeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount desc;

-- -- Checking data with continent is null
SELECT location, count(*) AS null_continents_count
FROM Covid_Database.coviddeaths
WHERE continent IS NULL
GROUP BY location;

-- To filter some rows in location 
SELECT location, SUM(population) as total_population, continent
FROM Covid_Database.coviddeaths
WHERE location NOT IN ('High income', 'Low income', 'Lower middle income', 'Upper middle income', 'World')
GROUP BY location, continent;

-- Showing total death count based on continent 
SELECT continent, MAX(cast(total_deaths as UNSIGNED)) AS TotalDeathCount
FROM Covid_Database.coviddeaths
WHERE continent is not NULL AND location NOT IN ('High income', 'Low income', 'Lower middle income', 'Upper middle income', 'World')
GROUP BY continent
ORDER BY TotalDeathCount desc;

-- Showing total new cases per day
SELECT date,
  SUM(new_cases) AS TotalCases,
  SUM(CAST(new_deaths AS UNSIGNED)) AS TotalDeaths,
  SUM(CAST(new_deaths AS UNSIGNED)) / NULLIF(SUM(new_cases), 0) * 100 AS DeathPercentage
FROM Covid_Database.coviddeaths
WHERE continent IS NOT NULL
  AND new_cases IS NOT NULL
  AND new_cases > 0
  AND new_deaths IS NOT NULL
  AND new_deaths > 0
GROUP BY date
ORDER BY date;

-- NOTE: NULLIF(SUM(new_cases), 0) in the calculation of DeathPercentage to handle the division by zero scenario. 
-- This ensures that if the sum of new_cases is 0, the result will be null instead of producing an error.

-- Showing total cases, total deaths and death percentages as total across the world (not group by date)
SELECT SUM(new_cases) AS TotalCases,
  SUM(CAST(new_deaths AS UNSIGNED)) AS TotalDeaths,
  SUM(CAST(new_deaths AS UNSIGNED)) / NULLIF(SUM(new_cases), 0) * 100 AS DeathPercentage
FROM Covid_Database.coviddeaths
WHERE continent IS NOT NULL
  AND new_cases IS NOT NULL
  AND new_cases > 0
  AND new_deaths IS NOT NULL
  AND new_deaths > 0
ORDER BY 1,2;

