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

--Loking at total cases vs total deaths, expressing total_deaths as a percentage of total cases
Select location, date, total_cases, total_deaths, (total_deaths*100/total_cases) as deathPercentage
From PortfolioProject..coviddeaths
where location like '%states%' 
Order by 1,2 asc
-- First case was reported in the United on 2020-01-22 and first death was reported on 2020-02-29

--Loking at Total Cases vs Population
--Likelihood of dying if you get infected in the US at a given date till 05-24-2021
Select location, date, population, total_cases, (total_cases*100/population) as InfectedPercentage
From PortfolioProject..coviddeaths
where location like '%states%'
Order by 1,2 asc
--10% of the US population was infected by COVID by 05-24-2021 which is 33143662

--Which country has the highest infection rate?
Select location, population, max(total_cases) as higestInfectionCount, max(total_cases*100/population) as InfectedPercentage
From PortfolioProject..coviddeaths
--where location like '%states%'
group by population, location
Order by InfectedPercentage desc
--Andorra has the highest infection rate, 17.56% of its population is infected

--When each country reported its first case?
select location, continent, min(date) as first_case, max(total_cases*100/population) as FinalInfectedPercentage
from PortfolioProject..coviddeaths
where continent is not null
group by location, continent
order by first_case asc
-- According to the given dataset Argentina, Mexico reported their first case on 01-01-2020 and first case from china was reported on 22-01-2020

--Which country has the highest death count?
Select location, max(cast(total_deaths as int)) as higestDeathCount, max(total_deaths*100/population) as percentage_of_death_in_TotalPopulation
From PortfolioProject..coviddeaths
where continent is not null -- to not display Asia, Europe, World so on..
group by location
Order by higestDeathCount desc
-- US has the highest death count 590320 which is 0.8 percentage of its population

-- Breaking things down by continent
-- Highest Death by Continent
Select location, max(cast(total_deaths as int)) as higestDeathCount
From PortfolioProject..coviddeaths
--where location like '%states%'
where continent is null 
group by location
Order by higestDeathCount desc
--Europe tops in death count

-- Setting up Drilldown Views for Tableau for later
-- Will be able to click on continent and then be able to drill down to locations later
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
order by date

select sum(new_cases) as total_cases, 
sum(cast(new_deaths as int)) as total_deaths,
(sum(cast(new_deaths as int))/(sum(new_cases)))*100 as DeathPercentage
from PortfolioProject..coviddeaths
where continent is not null
--group by date
--order by DeathPercentage desc
--Globally, 2.08% of the total infected cases resulted in death

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

-- Use CTE to find cumulative percentage of population vaccinated in each location
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
select continent, location, date, population,new_vaccinations,
cumulativeNumberOfVaccinations,(cumulativeNumberOfVaccinations/population)*100 as PercentageVaccinated
from PopvsVac
order by 2,3

--Another way by creating temp table
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

Select *,(cumulativeNumberOfVaccinations/population)*100 as PercentageVaccinated
from #PercentagePopulationVaccinated

--Creating Views to store data for later visualizations
Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location,
dea.date) as cumulativeNumberOfVaccinations
from PortfolioProject..covidvax vac join PortfolioProject..coviddeaths dea
on dea.location = vac.location and dea.date=vac.date
where dea.continent is not null and vac.new_vaccinations is not null

select *,(cumulativeNumberOfVaccinations/population)*100 as PercentageVaccinated
from PercentPopulationVaccinated