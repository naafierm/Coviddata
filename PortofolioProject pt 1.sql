select * 
from ProjectPortofolio..CovidDeaths
order by 3,4

select * 
from ProjectPortofolio..CovidVaccinations
order by 3,4

--Select Data that we are going  to be using 
select location, date, total_cases, new_cases, total_deaths, population
from ProjectPortofolio..CovidDeaths
order by 1,2

--Percentage between deaths and cases
select location, date, total_cases, total_deaths, (CONVERT(float,total_deaths)/NULLIF(CONVERT(float,total_cases),0))*100 as DeathPercentage
from ProjectPortofolio..CovidDeaths
order by 1,2

select location, date, total_cases, total_deaths, (CONVERT(float,total_deaths)/NULLIF(CONVERT(float,total_cases),0))*100 as DeathPercentage
from ProjectPortofolio..CovidDeaths
where location like '%states%'
order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got covid
select location, date, population, total_cases, (CONVERT(float,total_cases)/NULLIF(CONVERT(float,population),0))*100 as PopulationCasesPercentage
from ProjectPortofolio..CovidDeaths
where location like '%states%'
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population
select location, population, MAX(total_cases) as HighestInfectionCount, MAX(CONVERT(float,total_cases)/NULLIF(CONVERT(float,population),0))*100 as PercentPopulationInfected
from ProjectPortofolio..CovidDeaths
--where location like '%states%'
group by location, population
order by location 

--Showing Countries with Highest Death Count per Population
select location, MAX(total_deaths) as TotalDeathCount
from ProjectPortofolio..CovidDeaths
Where continent is not null
group by location
order by TotalDeathCount desc

select location, MAX(total_deaths) as TotalDeathCount
from ProjectPortofolio..CovidDeaths
Where continent is null
group by location
order by TotalDeathCount desc

--LETS BREAK THINGS DOWN BY CONTINENT

--Showing contintents with the highest death count per population
select continent, MAX(total_deaths) as TotalDeathCount
from ProjectPortofolio..CovidDeaths
Where continent is not null
group by continent
order by TotalDeathCount desc

--GLOBAL NUMBER
select date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(CONVERT(float,new_deaths))/SUM(CONVERT(float,new_cases))*100 as DeathPercentage
from ProjectPortofolio..CovidDeaths
--where location like '%states%'
where continent is not null
group By date
order by 1,2

select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(CONVERT(float,new_deaths))/SUM(CONVERT(float,new_cases))*100 as DeathPercentage
from ProjectPortofolio..CovidDeaths
--where location like '%states%'
where continent is not null
--group By date
order by 1,2


select * 
from ProjectPortofolio..CovidVaccinations

select *
from ProjectPortofolio..CovidDeaths dea
join ProjectPortofolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from ProjectPortofolio..CovidDeaths dea
join ProjectPortofolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.date) as TotalVaccinated
from ProjectPortofolio..CovidDeaths dea
join ProjectPortofolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--use CTE
With PopvsVac(Continent, Location, Date, Population, New_vaccinations, TotalVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.date) as TotalVaccinated
from ProjectPortofolio..CovidDeaths dea
join ProjectPortofolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (TotalVaccinated/Population)*100
From PopvsVac

--TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric, 
New_vaccinations numeric, 
TotalVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.date) as TotalVaccinated
from ProjectPortofolio..CovidDeaths dea
join ProjectPortofolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
order by 2,3

Select *, (TotalVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating view to store data for later visualization

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.date) as TotalVaccinated
from ProjectPortofolio..CovidDeaths dea
join ProjectPortofolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select * 
From PercentPopulationVaccinated