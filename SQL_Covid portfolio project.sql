select * 
from CovidDeath
where continent is not null
order by 3, 4

--select * 
--from CovidVaccinations
--order by 3, 4

--Selecting data  that we are working on
Select Location, date, total_cases, new_cases, total_deaths, population
from CovidDeath
order by 1, 2

--Loking at Total cases vs total deaths, need to convert data types so we able to devide
-- we converted data types by adding 'cast' to the variables
--shows the likelihood of dying if contracted Covid in SA
Select Location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))* 100 as DeathTotal_Percent
from CovidDeath
where location like '%south%' 
order by 1, 2

--Looking at Total Cases vs Population

Select Location, date, population, total_cases, (total_cases/population)* 100 as DeathTotal_Percent
from CovidDeath
where location like '%south%' 
order by 1, 2

-- Looking at Countries with highest infection rate compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))* 100 as PercentPopulationInfected
from CovidDeath
--where location like '%south%' 
where continent is not null
group by Location, population
order by PercentPopulationInfected desc


-- Showing Continents with highest Death Count per Population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeath
--where location like '%south%' 
where continent is not null
group by continent
order by TotalDeathCount desc


-- Looking at the data grouped by Continent
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeath
--where location like '%south%' 
where continent is not null
group by location
order by TotalDeathCount desc


--joining CovidDeath table with CovidVaccination by date and location
select* 
from CovidDeath dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date

-- GLOBAL NUMBERS

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))
/SUM(New_Cases)*100 as DeathPercentage
from CovidDeath
where continent is not null
order by 1,2

--looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(Cast(vac.new_vaccinations as int)) OVER(Partition by dea.location order by dea.location,
 dea.date) as RollingPeopleVaccinated
from CovidDeath dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1, 2, 3


-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(Cast(vac.new_vaccinations as int)) OVER(Partition by dea.location order by dea.location,
 dea.date) as RollingPeopleVaccinated
from CovidDeath dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select * , (RollingPeopleVaccinated/Population) * 100
from PopvsVac


--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(Cast(vac.new_vaccinations as int)) OVER(Partition by dea.location order by dea.location,
 dea.date) as RollingPeopleVaccinated
from CovidDeath dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select * , (RollingPeopleVaccinated/Population) * 100
from #PercentPopulationVaccinated


--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATION

create view globalNumbers as 
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))
/SUM(New_Cases)*100 as DeathPercentage
from CovidDeath
where continent is not null
--order by 1,2

create view populationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(Cast(vac.new_vaccinations as int)) OVER(Partition by dea.location order by dea.location,
 dea.date) as RollingPeopleVaccinated
from CovidDeath dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(Cast(vac.new_vaccinations as int)) OVER(Partition by dea.location order by dea.location,
 dea.date) as RollingPeopleVaccinated
from CovidDeath dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
