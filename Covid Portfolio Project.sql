SELECT *
FROM PortfolioP..CovidDeaths
WHERE continent IS NOT NULL
order by 3,4

--SELECT *
--FROM PortfolioP..CovidVaccinations
--WHERE continent IS NOT NULL
--order by 3,4

--Select data that we are going to be using

SELECT location,date, total_cases, new_cases, total_deaths, population
FROM PortfolioP..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2 

-- Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in Ireland
SELECT location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioP..CovidDeaths
WHERE location like 'ireland'
ORDER BY 1,2 

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid
SELECT location,date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioP..CovidDeaths
WHERE location like 'ireland'
ORDER BY 1,2 

--Looking at Countries with Highest Infection Rate compared to Population
SELECT location,population, MAX(	total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as 
PercentPopulationInfected
FROM PortfolioP..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--Showing Countries with Highest Death Count per Population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioP..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--Break Down by Continent ----39
--SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
--FROM PortfolioP..CovidDeaths
--WHERE continent IS NULL
--GROUP BY location
--ORDER BY TotalDeathCount DESC

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioP..CovidDeaths
WHERE continent IS not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


--Showing Continents with the Highest Death Count per Population


--GLobal
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
FROM PortfolioP..CovidDeaths
WHERE continent is not null
ORDER By 1,2


-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioP..CovidDeaths dea
JOIN PortfolioP..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
order by 2,3

--USE CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioP..CovidDeaths dea
JOIN PortfolioP..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3
)
SELECT *,(RollingPeopleVaccinated/population)*100 AS PercentofPopVac
FROM PopvsVac

--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioP..CovidDeaths dea
JOIN PortfolioP..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent is not null
--order by 2,3

SELECT *,(RollingPeopleVaccinated/population)*100 AS PercentofPopVac
FROM #PercentPopulationVaccinated

--Creating view to store date for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioP..CovidDeaths dea
JOIN PortfolioP..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null








