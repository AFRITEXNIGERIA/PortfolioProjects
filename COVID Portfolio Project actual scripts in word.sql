SELECT*
FROM PortfolioProjects..CovidDeaths$
Where continent is not null
ORDER BY 3,4


--SELECT*
--FROM PortfolioProjects..CovidVaccinations$
--ORDER BY 3,4

--Select Data that we are going to be using

SELECT Location,date,total_cases, new_cases, total_deaths, population
FROM PortfolioProjects..CovidDeaths$
Where continent is not null
order by 1,2


--Looking at Total Cases vs Total Deaths
--shows likelihood of dying if you contract covid in your country
SELECT Location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProjects..CovidDeaths$
Where location like '%Nigeria%' and continent is not null
order by 1,2

--Looking at Total Cases vs Population
--shows what percentage of population got covid

SELECT Location,date,population,total_cases,(total_cases/population)*100 as PercentagePopulationInfected
FROM PortfolioProjects..CovidDeaths$
--Where location like '%Nigeria%'
where continent is not null
order by 1,2

--Looking at countries with highest infection rate compared to population

SELECT Location,population,MAX(total_cases) as HighestInfectionCount,MAX(total_cases/population)*100 as 
PercentagePopulationInfected
FROM PortfolioProjects..CovidDeaths$
--Where location like '%Nigeria%'
where continent is not null
Group by Location, population
order by PercentagePopulationInfected desc


--showing Countries with highest Death count per population

SELECT Location,MAX( cast (total_deaths as int)) as TotalDeathCount

FROM PortfolioProjects..CovidDeaths$
--Where location like '%Nigeria%'
where continent is not null
Group by Location
order by TotalDeathCount desc

--let's break things down by continent

SELECT location,MAX( cast (total_deaths as int)) as TotalDeathCount

FROM PortfolioProjects..CovidDeaths$
--Where location like '%Nigeria%'
where continent is  null
Group by location
order by TotalDeathCount desc


-- Global Numbers

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(Cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
FROM PortfolioProjects..CovidDeaths$ 
--Where location like '%Nigeria%' 
WHERE continent is not null
--Group by date
order by 1,2

--Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) 
as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProjects..CovidDeaths$ dea
JOIN PortfolioProjects..CovidVaccinations$ vac
ON dea.location = vac.location
and dea.date=vac.date
Where dea.continent is not null
order by 2,3



--Use CTE
with PopvsVac(Continent, Location, Date, Population, New_Vaccinations,RollingPeopleVaccinated) 
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) 
as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProjects..CovidDeaths$ dea
JOIN PortfolioProjects..CovidVaccinations$ vac
ON dea.location = vac.location
and dea.date=vac.date
Where dea.continent is not null
--order by 2,3
)
Select*, (RollingPeopleVaccinated/population)*100
From PopvsVac




--Temp Table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) 
as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProjects..CovidDeaths$ dea
JOIN PortfolioProjects..CovidVaccinations$ vac
ON dea.location = vac.location
and dea.date=vac.date
--Where dea.continent is not null
--order by 2,3

Select*, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated




--Creating view to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) 
as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProjects..CovidDeaths$ dea
JOIN PortfolioProjects..CovidVaccinations$ vac
ON dea.location = vac.location
and dea.date=vac.date
Where dea.continent is not null
--order by 2,3

Select*
FROM PercentPopulationVaccinated