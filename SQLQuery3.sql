/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

-- Have a look at what CovidDeaths table contains

Select * 
from PortfolioProject..CovidDeaths 
where continent is not null
order by 3, 4

-- Have a look at what CovidVaccinations table contains

Select * 
from PortfolioProject..CovidVaccinations 
where continent is not null
order by 3,4

--Select the Data we will be using first 

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 1,2

--Total Cases vs Population
--Shows the Percentage of Infections 

Select Location, Date, Population, total_cases, (total_cases/population)*100 as PercentPopuInfected
from PortfolioProject..CovidDeaths
where continent is not null
--and Location like '%Tunisia%'
order by 1,2

-- Total Cases vs Total Deaths
--Shows the Percentage that you will probably die if covid was in your country

Select Location, Date, Population, total_cases, total_deaths, (CAST(total_deaths AS DECIMAL) / CAST(total_cases AS DECIMAL)) * 100 AS DeathPercent
from PortfolioProject..CovidDeaths
where continent is not null
--and Location like '%Tunisia%'
order by 1,2

--Total Cases vs Population
--Shows the Highest Infection rate compared to population

Select Location, population, MAX(total_cases) as HighestCasesCount, MAX(total_cases/population)*100 as PercentPopuInfected
from PortfolioProject..CovidDeaths
where continent is not null
Group by Location, population
--and Location like '%Tunisia%'
order by PercentPopuInfected DESC

--Check the highest deaths compared to population of each location

Select Location, population, MAX(cast(total_deaths as int)) as HighestdeathsCount
from PortfolioProject..CovidDeaths
where total_cases is not null
and continent is not null
Group by Location, population
--and Location like '%Tunisia%'
order by HighestdeathsCount DESC

--Check the highest deaths per continent

Select continent, MAX(cast(total_deaths as int)) as HighestdeathsCount
from PortfolioProject..CovidDeaths
where total_cases is not null
and continent is not null
Group by continent
--and Location like '%Tunisia%'
order by HighestdeathsCount DESC

--global numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, new_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentRollingPeopleVaccinated
From PopvsVac
where new_Vaccinations is not null

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 

Select *, (RollingPeopleVaccinated/Population)*100 as PercentRollingPeopleVaccinated
From #PercentPopulationVaccinated
where new_Vaccinations is not null

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
