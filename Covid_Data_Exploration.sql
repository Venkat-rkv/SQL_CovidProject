
Select * 
from Project..CovidDeaths$
order by 3,4

---Data for getting started with our analysis
Select Location, date, total_cases, new_cases, total_deaths, population
From Project..CovidDeaths$
order by 1,2

---Analyzing the Total Cases vs Total Deaths 
---Helps project the chances of dying if you contract Covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Project..CovidDeaths$
where location='Canada'
order by 1,2

---Analyzing the Total Cases vs Population
---Helps identify the % of population infected
Select Location, date, total_cases, Population, (total_cases/population)*100 as PopulationInfected
From Project..CovidDeaths$
Where location='Canada'
order by 1,2

---Viewing countries with most infection count
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PopulationInfected
From Project..CovidDeaths$
Group by Location, Population
order by PopulationInfected desc

--Viewing Countries with most Death Count per Population
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Project..CovidDeaths$
where continent is not null
Group by Location
order by TotalDeathCount desc

--- Viewing contintents with the most death count per population
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Project..CovidDeaths$
Where continent is not null 
Group by continent
order by TotalDeathCount desc

---Overall Figures
Select SUM(new_cases) as total_cases, 
SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Project..CovidDeaths$
where continent is not null 
order by 1,2


Select * 
from Project..CovidVaccinations$
order by 3,4

---Viewing Total Population vs Vaccincation
Select DE.continent, DE.location, DE.date, DE.population, VAC.new_vaccinations,
SUM(cast(VAC.new_vaccinations as int)) OVER (Partition by DE.Location Order by DE.location, DE.Date) as RollingPeopleVaccinated
from Project..CovidDeaths$ DE
join Project..CovidVaccinations$ VAC
	on DE.location=VAC.location 
	AND DE.date=VAC.date
where DE.continent is not null 
order by 2,3

---Using CTE to perform calculation which cannot be done on the previous query
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select DE.continent, DE.location, DE.date, DE.population, VAC.new_vaccinations,
SUM(cast(VAC.new_vaccinations as int)) OVER (Partition by DE.Location Order by DE.location, DE.Date) as RollingPeopleVaccinated
from Project..CovidDeaths$ DE
join Project..CovidVaccinations$ VAC
	on DE.location=VAC.location 
	AND DE.date=VAC.date
where DE.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

---Using Temp table to perform the calculation for the column created through partition by
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
Select DE.continent, DE.location, DE.date, DE.population, VAC.new_vaccinations
, SUM(CONVERT(int,VAC.new_vaccinations)) OVER (Partition by DE.Location Order by DE.location, DE.Date) as RollingPeopleVaccinated
From Project..CovidDeaths$ DE
Join Project..CovidVaccinations$ VAC
	on DE.location=VAC.location 
	AND DE.date=VAC.date
where DE.continent is not null 

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

---Creating VIEWS to store the data that can be used later for visualization purpose

Create View PercentPopulationVaccinated as
Select DE.continent, DE.location, DE.date, DE.population, VAC.new_vaccinations
, SUM(CONVERT(int,VAC.new_vaccinations)) OVER (Partition by DE.Location Order by DE.location, DE.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Project..CovidDeaths$ DE
Join Project..CovidVaccinations$ VAC
	on DE.location=VAC.location 
	AND DE.date=VAC.date
where DE.continent is not null 
