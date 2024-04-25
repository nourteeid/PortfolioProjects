SELECT Location, date, total_cases, new_cases, total_deaths, population 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2 

-- Total Cases vs Total Deaths

SELECT Location, date,total_cases, total_deaths, (total_deaths/total_cases)*100 AS PercentDeaths 
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2 

--Total Cases vs Population
SELECT Location, Date, Population, total_cases, (total_cases/population)*100 AS PercentofCovidinPopulation
FROM PortfolioProject..CovidDeaths
--WHERE Location = 'Belgium'
ORDER BY 1,2 

-- Countries with highest infection rate vs population 
SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentofPopulationInfected 
FROM PortfolioProject..CovidDeaths
--WHERE Location = 'Belgium'
GROUP BY population, location
ORDER BY PercentofPopulationInfected  DESC

-- Countries with highest death count 
SELECT Location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE Location = 'Belgium'
WHERE continent IS NOT NULL
GROUP BY  location
ORDER BY TotalDeathCount DESC

-- Death Count BY Continents 
SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCountinCont
FROM PortfolioProject..CovidDeaths
--WHERE Location = 'Belgium'
WHERE continent IS NOT NULL
GROUP BY  continent
ORDER BY TotalDeathCountinCont DESC

-- Total Cases by Continents 
SELECT continent, MAX(cast(total_cases as int)) AS TotalCasesinCont
FROM PortfolioProject..CovidDeaths
--WHERE Location = 'Belgium'
WHERE continent IS NOT NULL
GROUP BY  continent
ORDER BY TotalCasesinCont DESC


-- Global Numbers
-- Global Death percent
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 
--Group By date
order by 1,2


-- Total Population vs Vaccinations

SELECT Death.continent, Death.location, Death.date, Death.population, Vaccines.new_vaccinations,
SUM(cast(Vaccines.new_vaccinations as int)) OVER (PARTITION BY death.location ORDER BY death.location , death.date) AS RollPeopleVaccinated
FROM PortfolioProject..CovidDeaths Death JOIN PortfolioProject..CovidVaccinations Vaccines 
ON Death.location = vaccines.location
and Death.date = Vaccines.date
WHERE Death.continent IS NOT NULL
ORDER BY 2,3


-- Percent of RollPeopleVaccinated
DROP TABLE IF EXISTS #PercentPopulationVaccinated --in case of alterations 
CREATE TABLE #PercentPopulationVaccinated (
Continent nvarchar(255), Location nvarchar(255), Date datetime, population numeric, New_Vaccination numeric, RollPeopleVaccinated numeric)

INSERT INTO  #PercentPopulationVaccinated 
SELECT Death.continent, Death.location, Death.date, Death.population, Vaccines.new_vaccinations,
SUM(cast(Vaccines.new_vaccinations as int)) OVER (PARTITION BY death.location ORDER BY death.location , death.date) AS RollPeopleVaccinated
FROM PortfolioProject..CovidDeaths Death JOIN PortfolioProject..CovidVaccinations Vaccines 
ON Death.location = vaccines.location
and Death.date = Vaccines.date
WHERE Death.continent IS NOT NULL
ORDER BY 2,3

SELECT *, (RollPeopleVaccinated/Population)*100 AS PeopleVaccinatedRollPercentage
FROM #PercentPopulationVaccinated

-- Views for Visualisations 
CREATE VIEW PercentPopulationVaccinated AS
SELECT Death.continent, Death.location, Death.date, Death.population, Vaccines.new_vaccinations,
SUM(cast(Vaccines.new_vaccinations as int)) OVER (PARTITION BY death.location ORDER BY death.location , death.date) AS RollPeopleVaccinated
FROM PortfolioProject..CovidDeaths Death JOIN PortfolioProject..CovidVaccinations Vaccines 
ON Death.location = vaccines.location
and Death.date = Vaccines.date
WHERE Death.continent IS NOT NULL

CREATE VIEW GlobalDeathPercentage AS
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 


CREATE VIEW TotalDeathsPerCountry AS
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS PercentDeaths 
FROM PortfolioProject..CovidDeaths


CREATE VIEW TotalCasesPerCountry AS
SELECT Location, date, Population, total_cases, (total_cases/population)*100 AS PercentofCovidinPopulation
FROM PortfolioProject..CovidDeaths

CREATE VIEW HighestInfectionRateperCountry AS
SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentofPopulationInfected 
FROM PortfolioProject..CovidDeaths
GROUP BY population, location


CREATE VIEW HighestDeathCountPerCountry AS
SELECT Location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY  location


CREATE VIEW HighestDeathContinent AS
SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCountinCont
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY  continent


CREATE VIEW TotalCasesContinent AS
SELECT continent, MAX(cast(total_cases as int)) AS TotalCasesinCont
FROM PortfolioProject..CovidDeaths
--WHERE Location = 'Belgium'
WHERE continent IS NOT NULL
GROUP BY  continent
