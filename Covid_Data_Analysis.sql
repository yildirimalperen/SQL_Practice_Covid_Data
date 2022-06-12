-- Looking total cases vs total deaths  

select * 
from Project..covid_deaths
where continent is not null
order by 3,4

-- selecting data that I'm starting with

select location, date, total_cases,	total_deaths, population
from Project..covid_deaths
where continent is not null
order by 1,2

-- Total Cases & Total Deaths
-- shows likelihood of dying ratio if you contact covid in your country

select location, date, total_cases, total_deaths, population, round((total_deaths/total_cases)*100,1) as DeathPercentage
from Project..covid_deaths
Where location like '%states%' 
and continent is not null
order by 2

--shows what percentage of population infected

select location, date,population, total_cases,  round((total_cases/population)*100,2) as infection_rate
from Project..covid_deaths
Where location like '%turkey%' 
order by 1,2

-- looking at countries with highest infaction rate

select location, population, max(total_cases) as Highest_rate ,  round(max((total_cases/population))*100,2) as infection_rate
from Project..covid_deaths
group by location, population
order by 4 desc


-- showing countries with Highest Death Count per Population

select Location, Max(cast(total_deaths as int)) as TotalDeathCount
From Project..covid_deaths
where continent is not null
group by location
order by TotalDeathCount desc;

-- let's check by continet
-- showing continents with highest death count per population

select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From Project..covid_deaths
where continent is not null
group by continent
order by TotalDeathCount desc;

-- global numbers

select  sum(new_cases) as cumulative_cases, sum(cast(new_deaths as int)) as cumulative_deaths, round(sum(cast(new_deaths as int))/ sum(new_cases)*100,2) as percentage
from Project..covid_deaths
where continent is not null
-- group by date
order by 1,2


-- simple join
-- looking total population vs vaccination
-- shows percentage of population that recieved at least one covid vaccine

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from Project..covid_deaths dea
join Project..covid_vaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- using CTE to perform calculation on partition by in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Project..covid_deaths dea
Join Project..covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


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
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


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
