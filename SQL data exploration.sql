create table covid_vaccination(
iso_code varchar(100),
continent VARCHAR(100),
location VARCHAR(100),
date DATE,
total_tests	decimal,
new_tests decimal,
total_tests_per_thousand DECIMAL,
new_tests_per_thousand DECIMAL,
new_tests_smoothed	decimal,
new_tests_smoothed_per_thousand DECIMAL,
positive_rate DECIMAL,
tests_per_case DECIMAL,
tests_units	VARCHAR(100),
total_vaccinations decimal,
people_vaccinated decimal,
people_fully_vaccinated	decimal,
total_boosters decimal,
new_vaccinations decimal,
new_vaccinations_smoothed decimal,
total_vaccinations_per_hundred DECIMAL,
people_vaccinated_per_hundred	DECIMAL,
people_fully_vaccinated_per_hundred DECIMAL,
total_boosters_per_hundred	DECIMAL,
new_vaccinations_smoothed_per_million decimal,
new_people_vaccinated_smoothed decimal,
new_people_vaccinated_smoothed_per_hundred DECIMAL,
stringency_index DECIMAL,
population_density DECIMAL,
median_age	DECIMAL,
aged_65_older DECIMAL,	
aged_70_older DECIMAL,
gdp_per_capita DECIMAL,
extreme_poverty DECIMAL,
cardiovasc_death_rate DECIMAL,
diabetes_prevalence DECIMAL,
female_smokers DECIMAL,
male_smokers DECIMAL,
handwashing_facilities DECIMAL,
hospital_beds_per_thousand DECIMAL,
life_expectancy DECIMAL,
human_development_index DECIMAL,
excess_mortality_cumulative_absolute DECIMAL,
excess_mortality_cumulative	DECIMAL,
excess_mortality DECIMAL,
excess_mortality_cumulative_per_million DECIMAL
)


select * from covid_vaccination

select location, date, total_cases, new_cases,total_deaths,population from covid_deaths
order by 1,2

-- Looking at total cases vs total deaths 

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage from covid_deaths
where location like '%States%'
order by 1,2
 
 
-- Looking at total cases vs population 
select location, date, total_cases, population, (total_cases/population)*100 as cases from covid_deaths
where location like '%States%'
order by 1,2

--Looking at countries with highest infection rate compared to population 
select location,population, max(total_cases) as Highestinfectioncount, max(total_cases/population)*100 as percentofpopulationinfected from covid_deaths
group by location,population
order by percentofpopulationinfected desc

-- Showing the countries with highest death count per population 
select location,max(total_deaths) as totaldeathcount from covid_deaths
where continent is not null
group by location 
order by totaldeathcount desc

--showing continents with highest death count per population 
select location,max(total_deaths) as totaldeathcount from covid_deaths
where continent is null
group by location 
order by totaldeathcount desc

--Global Numbers
select location, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage from covid_deaths
where continent is not null 
order by 1,2

select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as deathpercentage from covid_deaths
where continent is not null 
order by 1,2

-- Looking at Total population vs vaccinations 
With popvsvac (continent,location,date,population,new_vaccinations,rollingpeoplevaccinated) as
(select covid_deaths.continent,covid_deaths.location,covid_deaths.date,covid_deaths.population, covid_vaccination.new_vaccinations,
sum(covid_vaccination.new_vaccinations) over (partition by covid_deaths.location order by covid_deaths.location, covid_deaths.date) as rollingpeoplevaccinated from covid_deaths
join covid_vaccination 
on covid_deaths.location = covid_vaccination.location 
and covid_deaths.date = covid_vaccination.date
where covid_deaths.continent is not null)
--order by 2,3
select * ,(rollingpeoplevaccinated/population)*100 from popvsvac


--Temp table 
create table precentpopulationvaccinated 
(continent varchar(100),
location varchar(100),
date date,
population decimal,
new_vaccination decimal,
rollingpeoplevaccinated decimal)

insert into precentpopulationvaccinated 
(select covid_deaths.continent,covid_deaths.location,covid_deaths.date,covid_deaths.population, covid_vaccination.new_vaccinations,
sum(covid_vaccination.new_vaccinations) over (partition by covid_deaths.location order by covid_deaths.location, covid_deaths.date) as rollingpeoplevaccinated from covid_deaths
join covid_vaccination 
on covid_deaths.location = covid_vaccination.location 
and covid_deaths.date = covid_vaccination.date
where covid_deaths.continent is not null)
--order by 2,3

select *, (rollingpeoplevaccinated/population)*100 from precentpopulationvaccinated 


--	Creating view to store data for later visualisation 
Create view Percentpopulationvaccinated as 
(select covid_deaths.continent,covid_deaths.location,covid_deaths.date,covid_deaths.population, covid_vaccination.new_vaccinations,
sum(covid_vaccination.new_vaccinations) over (partition by covid_deaths.location order by covid_deaths.location, covid_deaths.date) as rollingpeoplevaccinated from covid_deaths
join covid_vaccination 
on covid_deaths.location = covid_vaccination.location 
and covid_deaths.date = covid_vaccination.date
where covid_deaths.continent is not null)
--order by 2,3
