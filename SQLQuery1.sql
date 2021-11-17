
Select *
From PortfolioProject_SQLDE1..covidDeath
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject_SQLDE1..covidVaccination
--order by 3,4

-- Select Data that we are going to be using
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject_SQLDE1..covidDeath
order by 1,2

-- Total cases vs Total deaths (likelihood of dying if you contract covid)
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathPerc
From PortfolioProject_SQLDE1..covidDeath
Where location like '%cameroon%'
order by 1,2

-- Total cases vs Population
Select Location, date, total_cases, population, (total_cases/population)*100 as popPerc
From PortfolioProject_SQLDE1..covidDeath
Where location like '%cameroon%'
order by 1,2

--Countries with highest infection rate compared to population
Select Location, population, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population))*100 as populationinfectedPerc
From PortfolioProject_SQLDE1..covidDeath
Where continent is not null
Group by location, population
order by populationinfectedPerc desc

-- Countries with the highest death count per population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject_SQLDE1..covidDeath
Where continent is not null
Group by location
order by TotalDeathCount desc

-- Continents break down
-- Continents with the highest death counts per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject_SQLDE1..covidDeath
Where continent is not null
Group by continent
order by TotalDeathCount desc


--Global numbers
Select SUM(new_cases) as NC, SUM(cast(new_deaths as int)) as ND, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathPerc
From PortfolioProject_SQLDE1..covidDeath
Where continent is not null
--group by date
order by 1,2


-- Total population vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) 
as rollingPeopleVaccinated 
From PortfolioProject_SQLDE1..covidVaccination vac
Join PortfolioProject_SQLDE1..covidDeath dea
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

-- Use CTE

With PopvsVac (continent, location, date, population, new_vaccinations, rollingPeopleVaccinated)
as (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) 
as rollingPeopleVaccinated 
From PortfolioProject_SQLDE1..covidVaccination vac
Join PortfolioProject_SQLDE1..covidDeath dea
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select *, (rollingPeopleVaccinated/population)*100 as populationpVaccinatedPerc
From PopvsVac


-- Temporary table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
rollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) 
as rollingPeopleVaccinated 
From PortfolioProject_SQLDE1..covidVaccination vac
Join PortfolioProject_SQLDE1..covidDeath dea
	On dea.location = vac.location
	and dea.date = vac.date

Select *, (rollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

-- View (store data for later visualization)
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) 
as rollingPeopleVaccinated 
From PortfolioProject_SQLDE1..covidVaccination vac
Join PortfolioProject_SQLDE1..covidDeath dea
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *
From PercentPopulationVaccinated
