/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Converting Data Types

*/
Select *
From PortfolioProject..CovidDeaths
order by 3,4


-- เลือกข้อมูลที่จะเริ่มต้น

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 1,2

-- ผู้ติดเชื้อทั้งหมดเทียบกับการเสียชีวิตทั้งหมด
-- แสดงเปอร์เซ็นต์ของผู้เสียชีวิตกับผู้ติดเชื้อ

Select Location, date, total_cases,total_deaths, (CAST(total_deaths AS float) / total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
and continent is not null 
order by 1,2


-- ผู้ติดเชื้อทั้งหมดเทียบกับการเสียชีวิตทั้งหมด
-- แสดงเปอร์เซ็นต์ประชากรที่ติดเชื้อโควิด

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
order by 1,2

-- ประเทศที่มีเปอร์เซ็นต์การติดเชื้อสูงที่สุดเมื่อเทียบกับจำนวนประชากร

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  (Max(total_cases)/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where continent is not null 
Group by Location, Population
order by PercentPopulationInfected desc


-- ประเทศที่มีจำนวนผู้เสียชีวิตสูงสุด

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc

-- แสดงทวีปที่มีจำนวนผู้เสียชีวิตสูงสุด

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc

-- แสดงผู้ติดเชื้อ ผู้เสียชีวิต เปอร์เซ็นต์การเสียชีวิตเมื่อเปรียบเทียบกับผู้ติดเชื้อ

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 
order by 1,2


-- แสดงประชากรทั้งหมดเทียบกับการฉีดวัคซีน

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(ISNULL(CAST(vac.new_vaccinations AS bigint), 0)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null 
	order by 2,3

	-- ใช้ CTE เพื่อทำการคำนวณ Partition By 
	-- แสดงเปอร์เซ็นต์ของประชากรที่ได้รับวัคซีน

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(ISNULL(CAST(vac.new_vaccinations AS bigint), 0)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)

Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

	-- ใช้ Temp Table เพื่อทำการคำนวณ Partition By 


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
, SUM(ISNULL(CAST(vac.new_vaccinations AS bigint), 0)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date


Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated
