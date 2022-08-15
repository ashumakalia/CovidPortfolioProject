--Calculate Total cases vs Total Deaths
--shows the likelihood of dying from covid in United States

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths$
Where location like '%states%'
order by 1,2

--Calculate Total cases vs Population
--shows the percentage of COVID infected people in USA
Select Location, date, total_cases, population, (total_cases/population)*100 as InfectedPercentage 
from PortfolioProject.dbo.CovidDeaths$
--Where location like '%states%'
order by 1,2

--Countries with highest infected percentage of population
Select Location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as
InfectedPercentage
from PortfolioProject.dbo.CovidDeaths$
Group by Location, population
Order By InfectedPercentage desc

--Continents with highest Death count
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths$
Where continent is not null
Group by continent
Order By TotalDeathCount desc

--Global Numbers
Select date, SUM(new_cases) as global_cases, SUM(cast(new_deaths as int)) as global_deaths, 
(SUM(cast(new_deaths as int))/SUM(new_cases))*100 as globalDeathPercentage
from PortfolioProject.dbo.CovidDeaths$
where continent is not null
Group by date
order by 1,2

--calculate rolling count of people getting vaccinated each day. Use CTE to calculate vaccinated population
With PopVsVacPop (continent, location, date, population, new_vaccinations, TotalPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, 
dea.date) as TotalPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths$ dea
join PortfolioProject.dbo.CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)

Select *, (TotalPeopleVaccinated/population)*100
From PopVsVacPop


--temp table

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric, 
New_vaccinations numeric,
TotalPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, 
dea.date) as TotalPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths$ dea
join PortfolioProject.dbo.CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, (TotalPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

--Create Views to store data for data visualizations
Create View 
VaccinatedPopulation as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, 
dea.date) as TotalPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths$ dea
join PortfolioProject.dbo.CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *
From VaccinatedPopulation

Create View
DeathsvsCases as
Select date, SUM(new_cases) as global_cases, SUM(cast(new_deaths as int)) as global_deaths, 
(SUM(cast(new_deaths as int))/SUM(new_cases))*100 as globalDeathPercentage
from PortfolioProject.dbo.CovidDeaths$
where continent is not null
Group by date

Select *
From DeathsvsCases







