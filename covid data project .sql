select*
from PORTFOLIOPROJECT..CovidDeaths
where continent is not null
order by 3,4

--select*
--from PORTFOLIOPROJECT..CovidVaccinations
--order by 3,4

-- select data that we are going to be using 

select location, date, total_cases,new_cases, total_deaths,population
from PORTFOLIOPROJECT..CovidDeaths
where continent is not null
order by 1,2

--looking at total cases vs total deaths
-- shows likelihood of dying if you contract covid in your country 

select location, date, total_cases, total_deaths,(total_deaths/total_cases)* 100 as death_percentage 
from PORTFOLIOPROJECT..CovidDeaths
where location like '%india%'
and continent is not null
order by 1,2

-- looking total cases vs population 
-- shows what percentage of population got covid

select location, date,population, total_cases,(total_cases/population)* 100 as percentage_population_infected
from PORTFOLIOPROJECT..CovidDeaths
--where location like '%india%'
order by 1,2

-- looking at countries with highest infection rate compared to population 

select location, population, max(total_cases) as highest_infection_count, max((total_cases/population))* 100 as percent_population_infected
from PORTFOLIOPROJECT..CovidDeaths
--where location like '%india%'
group by location, population
order by percent_population_infected desc


-- showing countries with highest death count per population 

select location,  max(cast(total_deaths as int)) as total_death_count 
from PORTFOLIOPROJECT..CovidDeaths
--where location like '%india%'
where  continent is not null
group by location
order by total_death_count  desc

-- breaking by continent

--Showing continent  with highest death count per population 


select continent,  max(cast(total_deaths as int)) as total_death_count 
from PORTFOLIOPROJECT..CovidDeaths
--where location like '%india%'
where  continent is not null
group by continent
order by total_death_count  desc

--GLOBAL NUMBER

select  sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as  death_percentage 
from PORTFOLIOPROJECT..CovidDeaths
--where location like '%india%'
where continent is not null
--group by date
order by 1,2


-- looking at total population vs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over(partition by dea.location order by dea.location, 
dea.date)as rollingpeoplevaccinated
-- (rollingpeoplevaccinated/population)*100
from PORTFOLIOPROJECT..CovidDeaths dea
join PORTFOLIOPROJECT..CovidVaccinations  vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--use cte

with PopvsVac (Continent, Location, date,new_vaccinations, population, rollingpeoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, 
dea.date)as rollingpeoplevaccinated
--(rollingpeoplevaccinated/population)*100
from PORTFOLIOPROJECT..CovidDeaths dea
join PORTFOLIOPROJECT..CovidVaccinations  vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select*, (rollingpeoplevaccinated/population)*100
from PopvsVac


--temp table

drop table if exists  #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar (255), 
date datetime, 
population numeric, 
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, 
dea.date)as rollingpeoplevaccinated
-- (rollingpeoplevaccinated/population)*100
from PORTFOLIOPROJECT..CovidDeaths dea
join PORTFOLIOPROJECT..CovidVaccinations  vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select*,
(rollingpeoplevaccinated/population) *100
from #percentpopulationvaccinated




--creating view to store data for later visualization 


create view percentpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, 
dea.date)as rollingpeoplevaccinated
-- ,(rollingpeoplevaccinated/population)*100
from PORTFOLIOPROJECT..CovidDeaths dea
join PORTFOLIOPROJECT..CovidVaccinations  vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from percentpopulationvaccinated