SELECT *
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations$
--ORDER BY 3,4

-- Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT null
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelyhood of dying if you contract Covid in your country.

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM PortfolioProject..CovidDeaths$
where location like '%states'
AND continent IS NOT null
ORDER BY 1,2

-- Looking at the total cases vs the population
-- Shows what percentage of population got covid

SELECT Location, date, population, total_cases, (total_cases/population)*100 AS Percent_Popiulation_Infected
FROM PortfolioProject..CovidDeaths$
where location like '%states'
AND continent IS NOT null
ORDER BY 1,2

-- Looking at countries with highest infection rate compared to population

SELECT Location, population, max(total_cases) AS highest_infection_count, MAX((total_cases/population))*100 AS Percent_Popiulation_Infected
FROM PortfolioProject..CovidDeaths$
-- where location like '%states'
WHERE continent IS NOT null
GROUP BY population, location
ORDER BY Percent_Popiulation_Infected DESC

-- Showing Countries with highest death count per population
-- Had to change nvarchar as INT for calculation to function correctly. 

SELECT Location, MAX(CAST(total_deaths as INT)) AS total_death_count
FROM PortfolioProject..CovidDeaths$
-- where location like '%states'
WHERE continent IS NOT null
GROUP BY Location
ORDER BY total_death_count DESC

-- Now we're breaking it down by continent



-- Showing continents with the highest death count


SELECT continent, MAX(CAST(total_deaths as INT)) AS total_death_count
FROM PortfolioProject..CovidDeaths$
-- where location like '%states'
WHERE continent IS not null
GROUP BY continent
ORDER BY total_death_count DESC




-- Global Numbers

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS Total_Deaths, SUM(CAST(New_Deaths AS int))/SUM(new_cases) *100 AS DeathsPercentage
FROM PortfolioProject..CovidDeaths$
--where location like '%states'
WHERE continent IS NOT null
--GROUP BY date
ORDER BY 1,2

--Looking at total population vs total vaccination

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CAST(v.new_vaccinations AS int)) OVER (Partition by d.location ORDER BY d.Location
, d.date) AS  RollingPeopleVaccinated -- calculation starts over once the location changes. 
, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths$ d
JOIN CovidVaccinations$ v
	ON d.location = v.location
	and d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY 2,3



-- USE CTE

WITH PopvsVac(Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CAST(v.new_vaccinations AS int)) OVER (Partition by d.location ORDER BY d.Location
, d.date) AS  RollingPeopleVaccinated -- calculation starts over once the location changes. 
-- , (RollingPeopleVaccinated/population)*100
FROM CovidDeaths$ d
JOIN CovidVaccinations$ v
	ON d.location = v.location
	and d.date = v.date
WHERE d.continent IS NOT NULL
-- ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac





-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)



Insert into #PercentPopulationVaccinated
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CAST(v.new_vaccinations AS int)) OVER (Partition by d.location ORDER BY d.Location
, d.date) AS  RollingPeopleVaccinated -- calculation starts over once the location changes. 
-- , (RollingPeopleVaccinated/population)*100
FROM CovidDeaths$ d
JOIN CovidVaccinations$ v
	ON d.location = v.location
	and d.date = v.date
-- WHERE d.continent IS NOT NULL
-- ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated AS 
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CAST(v.new_vaccinations AS int)) OVER (Partition by d.location ORDER BY d.Location
, d.date) AS  RollingPeopleVaccinated -- calculation starts over once the location changes. 
-- , (RollingPeopleVaccinated/population)*100
FROM CovidDeaths$ d
JOIN CovidVaccinations$ v
	ON d.location = v.location
	and d.date = v.date
WHERE d.continent IS NOT NULL
--ORDER BY 2,3


SELECT *
FROM PercentPopulationVaccinated