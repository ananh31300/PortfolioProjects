select * 
from PortfolioProject..covidDeaths
where continent is not null
order by 3,4

--select * 
--from PortfolioProject..covidvaccinations
--order by 3,4
select location, datepart(year ,date), total_cases, new_cases, total_deaths, population
from PortfolioProject..covidDeaths
order by 1,2

---- Looking at total cases  and total deaths
---- Show likelihood of  dying  if you  contract covid in your country
select location, date,total_cases,total_deaths, round((total_deaths*100/total_cases),2) as Deathpercentage
from PortfolioProject..covidDeaths
where location = 'Vietnam'
order by 1,2

--- Look at total cases vs Population
--- Show what percentage of population got covid 
select location, date,population, total_cases, round((total_cases*100/population ),4) as CovidPercentage
from PortfolioProject..covidDeaths
---where location = 'Vietnam'
order by 1,2

--- Looking at  countries with highest Infection Rate compared to Population
select location,population, Max(total_cases) as HighestInfectionCount, Max(round((total_cases*100/population ),4))as HighestCovidPercentage
from PortfolioProject..covidDeaths
--where location = 'Vietnam'
group by location,population
order by 4 Desc

--- showing Countries with highest Death Count per Population
select Location,Population, max(cast(total_deaths as int)) as TotalDeathCount, Max(round((total_deaths*100/population ),4))as TotalDeathPercentage
from PortfolioProject..covidDeaths
where continent is not null
--and location = 'Vietnam'
group by location,population
order by 4 Desc

--- LET'S BREAK THINGS DOWN BY CONTINENT
select CONTINENT, max(cast(total_deaths as int)) as TotalDeathCount, Max(round((total_deaths*100/population ),4))as TotalDeathPercentage
from PortfolioProject..covidDeaths
where continent is not null
--and location = 'Vietnam'
group by CONTINENT
order by TotalDeathPercentage Desc

--GLOBAL NUMBERS
select SUM(new_cases ) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, round(SUM(cast(new_deaths as int ))*100/SUM(new_cases),2) as Deathpercentage
from PortfolioProject..covidDeaths
--where location = 'Vietnam'
where continent is not null
--group by date
order by 1,2

---- Looking at  Total Population vs Vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as numeric(12,0))) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--,( RollingPeopleVaccinated/population)*100
from covidDeaths dea join Covidvaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3



--- USE CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as numeric(12,0))) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
---order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--TEMP TABLE
drop table #PercentPopulationVaccination
go

Create Table #PercentPopulationVaccination 
(
Continent nvarchar(225),
Location nvarchar(225),
Date Datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as numeric(12,0))) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
---where dea.continent is not null 
---order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccination

---creating view to store  data for later  visualization

create view PercentPopulationVaccination as
Select top(5) dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as numeric(12,0))) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
----order by 2,3;


select * from PercentPopulationVaccination