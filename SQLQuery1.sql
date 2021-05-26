Select *
From PortfolioProject..coviddeaths
Order by 3,4

/* select *
from PortfolioProject..covidvax
order by 3,4 */

-- Select Data that I'm going to be using 
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..coviddeaths
Order by 1,2

--Loking at total cases vs total deaths, expressing number of deaths as % of total cases
-- Likelihood of dying if you get infected
Select location, date, total_cases, total_deaths, (total_deaths*100/total_cases) as deathPercentage
From PortfolioProject..coviddeaths
where location like '%states%'
Order by 1,2 asc

--Loking at Total Cases vs Population
Select location, date, population, total_cases, (total_cases*100/population) as InfectedPercentage
From PortfolioProject..coviddeaths
where location like '%states%'
Order by 1,2 asc

--what country has the highest infection rate
Select location, population, max(total_cases) as higestInfectionCount, max(total_cases*100/population) as InfectedPercentage
From PortfolioProject..coviddeaths
--where location like '%states%'
group by population, location
Order by InfectedPercentage desc

--what country has the highest death count
Select location, max(cast(total_deaths as int)) as higestDeathCount
From PortfolioProject..coviddeaths
--where location like '%states%'
where continent is not null -- to not display Asia, Europe, World so on..
group by location
Order by higestDeathCount desc

-- Breaking things down my continent
Select location, max(cast(total_deaths as int)) as higestDeathCount
From PortfolioProject..coviddeaths
--where location like '%states%'
where continent is null -- to not display Asia, Europe, World so on..
group by location
Order by higestDeathCount desc

-- Setting up Drilldown Views for Tableau for later
-- will be able to clink on continent and then be able to drill down to countries later

--Showing continents with the highest death count per population
Select continent, max(cast(total_deaths as int)) as higestDeathCount
From PortfolioProject..coviddeaths
where continent is not null -- to not display Asia, Europe, World so on..
group by continent
Order by higestDeathCount desc

-- Global Numbers of new cases per day, deaths per day and % of deaths per day
select date, sum(new_cases) as total_cases, 
sum(cast(new_deaths as int)) as total_deaths,
(sum(cast(new_deaths as int))/(sum(new_cases)))*100 as DeathPercentage
from PortfolioProject..coviddeaths
where continent is not null
group by date
order by DeathPercentage desc

select sum(new_cases) as total_cases, 
sum(cast(new_deaths as int)) as total_deaths,
(sum(cast(new_deaths as int))/(sum(new_cases)))*100 as DeathPercentage
from PortfolioProject..coviddeaths
where continent is not null
--group by date
--order by DeathPercentage desc

Select *
from PortfolioProject..covidvax vac join 
PortfolioProject..coviddeaths dea
on dea.location = vac.location and dea.date=vac.date

--Looking at total population vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..covidvax vac join 
PortfolioProject..coviddeaths dea
on dea.location = vac.location 
and dea.date=vac.date
where dea.continent is not null and vac.new_vaccinations is not null
order by 2,3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location,
dea.date) as cumulativeNumberOfVaccinations
from PortfolioProject..covidvax vac join 
PortfolioProject..coviddeaths dea
on dea.location = vac.location 
and dea.date=vac.date
where dea.continent is not null and vac.new_vaccinations is not null
order by 2,3

-- Use CTE

With PopvsVac(continent, location, date, population, new_vaccinations, 
cumulativeNumberOfVaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location,
dea.date) as cumulativeNumberOfVaccinations
from PortfolioProject..covidvax vac join PortfolioProject..coviddeaths dea
on dea.location = vac.location and dea.date=vac.date
where dea.continent is not null and vac.new_vaccinations is not null
--order by 2,3
)
select *,(cumulativeNumberOfVaccinations/population)*100
from PopvsVac

--temp table
Drop table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
cumulativeNumberOfVaccinations numeric
)
Insert into #PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location,
dea.date) as cumulativeNumberOfVaccinations
from PortfolioProject..covidvax vac join PortfolioProject..coviddeaths dea
on dea.location = vac.location and dea.date=vac.date
where dea.continent is not null and vac.new_vaccinations is not null
--order by 2,3

Select *,(cumulativeNumberOfVaccinations/population)*100
from #PercentagePopulationVaccinated

--Creating Views to store data for later visualizations
Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location,
dea.date) as cumulativeNumberOfVaccinations
from PortfolioProject..covidvax vac join PortfolioProject..coviddeaths dea
on dea.location = vac.location and dea.date=vac.date
where dea.continent is not null and vac.new_vaccinations is not null

select * from PercentPopulationVaccinated