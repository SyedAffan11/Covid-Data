USE [AffanPortfolio]

Select* from AffanPortfolio..CovidDeaths$
Where continent is not null
ORDER BY 3,4
--SELECTING DATA THAT WE ARE GOING TO BE USING
Select Location, date,total_cases,new_cases,total_deaths,population 
from AffanPortfolio..CovidDeaths$
Where continent is not null
Order by 1,2

--Total cases vs total deaths 
Select Location, date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Deathpercentage
from AffanPortfolio..CovidDeaths$
Where location like '%pakistan'and continent is not null
Order by 1,2

--Total cases vs Population
Select Location, date,population,total_cases,(total_cases/population)*100 as contractionpercentage
from AffanPortfolio..CovidDeaths$
Where location like '%pakistan'and continent is not null

Order by 1,2 

--Countries With Highest Infection Rate compared to population
Select Location,population,MAX(total_cases)as HighestInfectionCount,MAX((total_cases/population))*100 as InfectionRate
from AffanPortfolio..CovidDeaths$
Where continent is not null
GROUP BY Location,population
Order by InfectionRate desc

--Countries with Highest Death Countr per population
Select Location,MAX(cast(total_deaths as int)) as TotalDeath
from AffanPortfolio..CovidDeaths$
Where continent is not null
GROUP BY Location
Order by TotalDeath desc

--Deaths in terms of continent

Select continent,MAX(cast(total_deaths as int)) as TotalDeath
from AffanPortfolio..CovidDeaths$
Where continent is not null
GROUP BY continent
Order by TotalDeath desc

--Global Numbers
Select date, SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 
as Deathpercentage
from AffanPortfolio..CovidDeaths$
Where continent is not null
GROUP BY date
Order by 1,2

Select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 
as Deathpercentage
from AffanPortfolio..CovidDeaths$
Where continent is not null
Order by 1,2

--Total population vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as int)) over	(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from AffanPortfolio..CovidDeaths$ dea
join AffanPortfolio..CovidVaccinations$ vac
ON dea.location= vac.location
   and dea.date= vac.date
Where dea.continent is not null
Order by 2,3

--Use CTE

with POPvsVAC (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as int)) over	(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from AffanPortfolio..CovidDeaths$ dea
join AffanPortfolio..CovidVaccinations$ vac
ON dea.location= vac.location
   and dea.date= vac.date
Where dea.continent is not null
)
select *,(RollingPeopleVaccinated/population)*100 from POPvsVAC

--TEMP TABLE

drop table if exists PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric,
)


INSERT INTO #PercentPopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as int)) over	(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from AffanPortfolio..CovidDeaths$ dea
join AffanPortfolio..CovidVaccinations$ vac
ON dea.location= vac.location
   and dea.date= vac.date
Where dea.continent is not null
--Order by 2,3

select *,(RollingPeopleVaccinated/population)*100 from #PercentPopulationVaccinated
--drop view PercentPopulationVaccinated 
-- Creating VIew to store data for later visualizations
Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as int)) over	(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from AffanPortfolio..CovidDeaths$ dea
join AffanPortfolio..CovidVaccinations$ vac
ON dea.location= vac.location
   and dea.date= vac.date
Where dea.continent is not null
--Order by 2,3
Select * from  PercentPopulationVaccinated
 
