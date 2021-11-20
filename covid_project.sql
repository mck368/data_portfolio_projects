CREATE DATABASE IF NOT EXISTS CovidProject;
USE CovidProject;

-- Sum of New Deaths
SELECT location, SUM(new_deaths) FROM deaths
WHERE continent != "" and location like '%canada%'
GROUP BY location
ORDER BY 1,2;

-- Max Total Deaths
SELECT location, MAX(cast(total_deaths as double)) FROM deaths
WHERE continent != "" and location like '%canada%'
GROUP BY location
ORDER BY 1,2;

-- Total Cases vs Total Deaths in the United States
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM CovidProject.deaths
WHERE location like '%states%'
ORDER BY 1,2;

-- Total Cases vs Population in the United States
SELECT location, date, total_cases, population, (total_cases/population)*100 as pop_percentage
FROM CovidProject.deaths
WHERE location like '%states%'
ORDER BY 1,2;

-- Total covid case rate per population by country
SELECT location, population, MAX(total_cases) as total_cases, MAX((total_cases/population))*100 as case_pop_percent
FROM CovidProject.deaths
WHERE continent != ""
GROUP BY location, population
ORDER BY population DESC;

-- Total death count by country
SELECT location, SUM(cast(new_deaths as double)) as total_deaths
FROM CovidProject.deaths
WHERE continent != ""
GROUP BY location
ORDER BY total_deaths DESC;

-- Total death count by continent
SELECT location, SUM(cast(new_deaths as double)) as total_deaths
FROM CovidProject.deaths
WHERE location = "Europe" or location = "Asia" or location = "South America" or location = "North America" or
location = "Africa" or location = "Oceania"
GROUP BY location
ORDER BY total_deaths DESC;

-- Global Numbers
SELECT SUM(cast(new_cases as double)) as total_cases,
	   SUM(cast(new_deaths as double)) as total_deaths,
	   SUM(cast(new_deaths as double))/SUM(cast(new_cases as double))*100 as percent_death
FROM CovidProject.deaths
WHERE continent != ""
-- GROUP BY date
ORDER BY 1,2;

-- Total Population vs. Vaccines
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
	   SUM(cast(v.new_vaccinations as double))
       OVER (Partition by d.location Order by d.location, d.date) as total_vaccinations,
       SUM((cast(v.new_vaccinations as double))/population)
       OVER (Partition by d.location Order by d.location, d.date) as percent_vaccinated
FROM CovidProject.deaths d
JOIN CovidProject.vaccines v
On d.location = v.location
and d.date = v.date
WHERE d.continent != ""
ORDER BY 2,3;

-- Create table with total vaccinations included as a column
DROP TABLE if exists CovidProject.percentPopVaxxed;
CREATE TABLE CovidProject.percentPopVaxxed AS
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
	   SUM(cast(v.new_vaccinations as double))
       OVER (Partition by d.location Order by d.location, d.date) as total_vaccinations
FROM CovidProject.deaths d
JOIN CovidProject.vaccines v
On d.location = v.location
and d.date = v.date
WHERE d.continent != ""
ORDER BY 2,3;

-- Creating View for visualizations
CREATE VIEW CovidProject.percentVaxxed AS
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
	   SUM(cast(v.new_vaccinations as double))
       OVER (Partition by d.location Order by d.location, d.date) as total_vaccinations
FROM CovidProject.deaths d
JOIN CovidProject.vaccines v
On d.location = v.location
and d.date = v.date
WHERE d.continent != "";









