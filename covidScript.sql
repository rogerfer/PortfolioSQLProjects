SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths


-- Looking at Total Cases vs Total Deaths
-- shows likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like '%tugal%' 
ORDER BY 1,2


-- Looking at Total Cases vs Population
--Show what percentage of population got Covid
SELECT Location, date, Population, total_cases, (total_cases/population)*100 as DPercentPopulation
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like '%tugal%' 
ORDER BY 1,2


-- Looking at Countries with Highest Infection Rate comapred to Population
--
SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
GROUP BY Location, Population
ORDER BY PercentPopulationInfected desc


-- Showing Countries with Highest Death Count per Population
SELECT Location, MAX(cast(Total_deaths as int)) as TotalDeathsCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY Location, Population
ORDER BY TotalDeathsCount desc


-- Showing continents with highest death count per population
SELECT location, MAX(cast(Total_deaths as int)) as TotalDeathsCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathsCount desc


-- Global Numbers
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

--**********************************************************************************************
--*****************************************************************************************************
-- Looking at Total Population vs VAccinations -- Usando CTE (Common Table Expression)
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

--******************Temp Table da anterior*********
DROP Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

--***************************************************************************************
--**************************************************************************************


--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null



SELECT *
FROM PercentPopulationVaccinated