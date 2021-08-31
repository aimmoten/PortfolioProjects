
SELECT * 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4

--SELECT * 
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3, 4

-- SELECT DATA THAT WE ARE GOING TO BE USING 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- LOOKING AT TOTAL CASES VS TOTAL DEATHS
-- SHOWS THE LIKELIHOOD OF DYING IF YOU CONTRACT COVID IN YOUR COUNTRY

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage 
FROM PortfolioProject..CovidDeaths
WHERE location = 'United States'
ORDER BY 1,2

-- LOOKING AT THE TOTAL CASES VS THE POPULATION
-- SHOWS WHAT PERCENTAGE OF POPULATION GOT COVID

SELECT location, date, population,total_cases, (total_cases/population)*100 AS CovidPercentage 
FROM PortfolioProject..CovidDeaths
WHERE location = 'United States'
ORDER BY 1,2

-- LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentofPopulationInfected 
FROM PortfolioProject..CovidDeaths
GROUP BY population, location
ORDER BY PercentofPopulationInfected DESC

-- SHOWING COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION

SELECT location, MAX(CAST(TOTAL_DEATHS AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- BREAKING IT DOWN BY CONTINENT
-- SHOWING CONTINENTS WITH THE HIGHEST DEATH COUNT PER POPULATION

SELECT continent, MAX(CAST(TOTAL_DEATHS AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

SELECT location, MAX(CAST(TOTAL_DEATHS AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS  NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- GLOBAL COVID NUMBERS

SELECT date, SUM(NEW_CASES) AS TotalCases, SUM(CAST(NEW_DEATHS AS int)) AS TotalDeaths, SUM(CAST(NEW_DEATHS AS INT))/SUM(NEW_CASES)*100 AS DeathPercentage 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

SELECT SUM(NEW_CASES) AS TotalCases, SUM(CAST(NEW_DEATHS AS int)) AS TotalDeaths, SUM(CAST(NEW_DEATHS AS INT))/SUM(NEW_CASES)*100 AS DeathPercentage 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- LOOKING AT TOTAL POPULATION VS VACCINATIONS 

SELECT DEA.continent, DEA.location, DEA.date,DEA.population, VAC.new_vaccinations
, SUM(CAST(VAC.NEW_VACCINATIONS AS int)) OVER (PARTITION BY DEA.LOCATION ORDER BY DEA.LOCATION, DEA.DATE) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
ORDER BY 2,3

-- USE CTE

WITH PopulationVsVaccination (CONTINENT, LOCATION,DATE, POPULATION, NEW_VACCINATIONS, ROLLINGPEOPLEVACCINATED)
AS
(
SELECT DEA.continent, DEA.location, DEA.date,DEA.population, VAC.new_vaccinations
, SUM(CAST(VAC.NEW_VACCINATIONS AS int)) OVER (PARTITION BY DEA.LOCATION ORDER BY DEA.LOCATION, DEA.DATE) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
)

SELECT *, (ROLLINGPEOPLEVACCINATED/POPULATION)*100
FROM PopulationVsVaccination

-- TEMP TABLE

DROP TABLE IF EXISTS #PercentOfPopulationVaccinated
CREATE TABLE #PercentOfPopulationVaccinated
(
Continent nvarchar(255),
Locatoin nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentOfPopulationVaccinated
SELECT DEA.continent, DEA.location, DEA.date,DEA.population, VAC.new_vaccinations
, SUM(CAST(VAC.NEW_VACCINATIONS AS int)) OVER (PARTITION BY DEA.LOCATION ORDER BY DEA.LOCATION, DEA.DATE) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL

SELECT *, (ROLLINGPEOPLEVACCINATED/POPULATION)*100
FROM #PercentOfPopulationVaccinated

-- CREATING VIEW TO STORE DATA FOR VISUALIZATOINS

CREATE VIEW PercentOfPopulationVaccinated AS 
SELECT DEA.continent, DEA.location, DEA.date,DEA.population, VAC.new_vaccinations
, SUM(CAST(VAC.NEW_VACCINATIONS AS int)) OVER (PARTITION BY DEA.LOCATION ORDER BY DEA.LOCATION, DEA.DATE) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
-- ORDER BY 2,3

SELECT * 
FROM PercentOfPopulationVaccinated