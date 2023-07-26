-- COVID 19 DATA EXPLORATION

SELECT *
FROM Hello..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

SELECT *
FROM Hello..CovidVaccinations
ORDER BY 3,4

-- SELECTING DATA THAT WE NEED TO USE

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Hello..CovidDeaths
WHERE continent is not null
ORDER BY 1,2


-- Total Cases Vs Total Death
-- Demonstrates the likelihood of Dying from Covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM Hello..CovidDeaths
-- Where [location] Like '%India%'
WHERE continent is not null
ORDER BY 1,2


-- Total Cases Vs Population
-- Show what % of people got Covid
SELECT location, date, total_cases, population, (total_cases/population)*100 AS AcquiredPercentage
FROM Hello..CovidDeaths
-- Where [location] LIKE '%India%'
WHERE continent is not null
ORDER BY 1,2


-- Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)*100) AS PercentPopulationInfected
FROM Hello..CovidDeaths
WHERE continent is not null
GROUP BY [location],population
ORDER BY PercentPopulationInfected DESC


-- Countries with the Highest Death Count Per Population
SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM Hello..CovidDeaths
WHERE continent is not null
GROUP BY [location]
ORDER BY TotalDeathCount DESC


-- BREAKING THINGS BY CONTINENT

-- Continents with the Highest Death Count
SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM Hello..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS TOTAL
SELECT SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeath, (SUM(cast(new_deaths AS float))/SUM(cast(new_cases AS float))) * 100 AS DeathPercentage
FROM Hello..CovidDeaths
WHERE continent is not null
-- GROUP BY [date]
ORDER BY 1,2



-- GLOBAL NUMBERS PER DAY
SELECT date, SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeath, (SUM(cast(new_deaths AS float))/SUM(cast(new_cases AS float))) * 100 AS DeathPercentage
FROM Hello..CovidDeaths
WHERE continent is not null
GROUP BY [date]
ORDER BY 1,2


-- Total Population VS Vaccination 

SELECT CD.continent, CD.[location], CD.[date], CD.population, CV.new_vaccinations,
SUM(CV.new_vaccinations) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.date) AS RollingCountOfPeopleVaccinated
FROM Hello..CovidDeaths AS CD
    JOIN Hello..CovidVaccinations AS CV
    ON CD.[location] = CV.[location]
        AND CD.[date] = CV.[date]
WHERE CD.continent is not NULL
ORDER BY 2,3


-- USING CTE

With PopVsVac (Continent,location,date,population,new_vaccinations,RollingCountOfPeopleVaccinated)
AS
(
SELECT CD.continent, CD.[location], CD.[date], CD.population, CV.new_vaccinations,
SUM(CV.new_vaccinations) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.date) AS RollingCountOfPeopleVaccinated
FROM Hello..CovidDeaths AS CD
    JOIN Hello..CovidVaccinations AS CV
    ON CD.[location] = CV.[location]
        AND CD.[date] = CV.[date]
WHERE CD.continent is not NULL
)
SELECT *, (RollingCountOfPeopleVaccinated/population)*100 AS RollingPercentage
FROM PopVsVac


-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
    Continent NVARCHAR(255),
    LOCATION NVARCHAR(255),
    Date DATETIME,
    Population NUMERIC,
    New_Vaccinations NUMERIC,
    RollingCountOfPeopleVaccinated NUMERIC
)


INSERT INTO #PercentPopulationVaccinated
SELECT CD.continent, CD.[location], CD.[date], CD.population, CV.new_vaccinations,
SUM(CV.new_vaccinations) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.date) AS RollingCountOfPeopleVaccinated
FROM Hello..CovidDeaths AS CD
    JOIN Hello..CovidVaccinations AS CV
    ON CD.[location] = CV.[location]
        AND CD.[date] = CV.[date]
WHERE CD.continent is not NULL

SELECT *, (RollingCountOfPeopleVaccinated/population)*100 AS RollingPercentage
FROM #PercentPopulationVaccinated


-- Creating View For Later Visualizations

CREATE VIEW PERCENTPeopleVaccinated AS
SELECT CD.continent, CD.[location], CD.[date], CD.population, CV.new_vaccinations,
SUM(CV.new_vaccinations) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.date) AS RollingCountOfPeopleVaccinated
FROM Hello..CovidDeaths AS CD
    JOIN Hello..CovidVaccinations AS CV
    ON CD.[location] = CV.[location]
        AND CD.[date] = CV.[date]
WHERE CD.continent is not NULL