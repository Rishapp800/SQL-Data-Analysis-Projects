Select * From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--Select * From PortfolioProject..CovidVaccinations
--order by 3,4

--Selecting Data That I am Using

Select Location, date, total_cases,new_cases,total_deaths,population
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Looking at Total Cases Vs Total Deaths
--Shows the likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathRate
From PortfolioProject..CovidDeaths
Where Location like '%India%' and continent is not null
order by 1,2 

--Looking at Total cases vs population
--Shows what percentage of population got Covid

Select Location, date,total_cases,population, (total_cases/population)*100 as InfectionRate
From PortfolioProject..CovidDeaths
Where Location like '%India%' and continent is not null
order by 1,2 

--Looking at Countries with highest Infection Rate compared to population

Select Location,population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as HighestInfectionRate
From PortfolioProject..CovidDeaths
where continent is not null
group by Location,population
order by 4 desc

--Showing Countries with Highest Death Count per population

Select Location,MAX(cast(total_deaths as int)) as HighestdeathCount
From PortfolioProject..CovidDeaths
where continent is not null
group by Location
order by 2 desc

--Showing Continents with highest death count per population--Showing Continents with highest death count per population

Select continent,MAX(cast(total_deaths as int)) as HighestdeathCount
From PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by 2 desc

-- Showing Global Numbers

Select SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathRate
From PortfolioProject..CovidDeaths
Where continent is not null
--group by date
order by 1,2 

-- Joining Covid Deaths and Vaccinations data

Select * 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date

-- Vaccinations Vs Population
--Using CTE

With PopvsVac ( Continent , Location , Date , Population , New_Vaccinations , RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location,dea.date, dea.population , vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
)
Select *,(RollingPeopleVaccinated/Population) as VaccinationRate From PopVsVac


--Using TempTable

DROP Table if exists #PercentPopluationVaccinated
Create Table #PercentPopluationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopluationVaccinated
Select dea.continent, dea.location,dea.date, dea.population , vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null

Select * ,(RollingpeopleVaccinated/population)*100 as VaccinationRate
From #PercentPopluationVaccinated


-- Creating View to store data for later visualizations

Drop View  if exists PercentPopulationvaccinated
USE PortfolioProject
GO
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location,dea.date, dea.population , vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null

Select * From PercentPopulationvaccinated
