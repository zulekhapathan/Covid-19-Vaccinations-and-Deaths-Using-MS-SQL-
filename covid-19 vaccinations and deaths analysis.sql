--total deaths, cases and deaths rate by country
select location,
coalesce(sum(total_deaths),0) as total_deaths,
coalesce(sum(total_cases),0) as total_cases,
coalesce(sum(total_deaths)*100/nullif(sum(total_cases),0),0) as death_rate_percentage
from coviddeathss
--where continent is not null
group by location
order by death_rate_percentage desc;

--global vaccination rate
select sum(cast(people_fully_vaccinated as bigint))*100/sum(d.population) as vaccinated_percentage from covidvaccinationss v
join coviddeathss d on v.location=d.location and v.date=d.date

--daily new cases and new deaths ratio
select date,coalesce(sum(new_cases),0) as new_cases,
coalesce(sum(new_deaths),0) as new_deaths,
coalesce((sum(new_deaths)*100/nullif(sum(new_cases),0)),0) as daily_new_deaths_ratio
from coviddeathss
group by date
order by date 

--highest infection rate by country
select location,max(total_deaths*100.0/nullif(population,0)) as infection_rate
from coviddeathss
where continent is not null 
group by location,population 
order by infection_rate desc

--top 3 highest cases and deaths by country
with top3_countries_cases as(
select location, sum(total_cases) as total_cases,
row_number() over(order by sum(total_cases) desc) as rk from coviddeathss
where continent is not null
group by location),
top3_countries_deaths as (
select location,sum(total_deaths) as total_deaths,row_number() over(order by sum(total_deaths) desc) as rks 
from coviddeathss
where continent is not null
group by location)
SELECT location, total_cases, NULL AS total_deaths
FROM top3_countries_cases
WHERE rk <= 3
UNION
SELECT location, NULL AS total_cases,total_deaths
FROM top3_countries_deaths
WHERE rks <= 3
ORDER BY total_cases DESC, total_deaths DESC;

--Countries with the highest percentage of fully vaccinated people
select v.location,max(cast(v.people_fully_vaccinated as bigint)*100/nullif(d.population,0)) as vaccination_rate
from covidvaccinationss v
join coviddeathss d on d.location=v.location
group by v.location
order by vaccination_rate desc

-- highest percentage of fully vaccinated people in india
select v.location,max(cast(v.people_fully_vaccinated as bigint)*100/nullif(d.population,0)) as vaccination_rate
from covidvaccinationss v
join coviddeathss d on d.location=v.location
where v.location='India'
group by v.location
order by vaccination_rate desc

--worldwide vaccination rate 
select sum(cast(v.people_fully_vaccinated as bigint))*100/sum(d.population) as overall_vaccination_rate
from covidvaccinationss v 
join coviddeathss d on v.location=d.location

--total cases,deaths, and vaccination trends by month
select format(d.date,'yyyy-MM') as month,
sum(new_cases) as total_new_cases, sum(new_deaths) as total_new_deaths,
coalesce(sum(cast(v.people_fully_vaccinated as bigint)),0) as total_fully_vaccinated
from coviddeathss d 
join covidvaccinationss v on d.date=v.date and d.location=v.location
group by format(d.date,'yyyy-MM')
order by month

--Countries with the Highest Death-to-Vaccination Ratio
select d.location,coalesce(sum(total_deaths),0) as total_deaths,
coalesce(max(v.people_fully_vaccinated),0) as fully_vaccinated,
coalesce((max(d.total_deaths) * 100 / nullif(sum(convert(bigint,v.people_fully_vaccinated)), 0)),0) as death_to_vaccine_ratio
from coviddeathss d 
join covidvaccinationss v on d.location=v.location and d.date=v.date
where d.continent is not null 
group by d.location
order by death_to_vaccine_ratio desc

--Total deaths by continent.
select continent,sum(total_deaths) as total_deaths from coviddeathss
where continent is not null
group by continent
order by total_deaths desc

--cummulative daily vaccinations in each country
select location,date, coalesce(new_vaccinations,0) as new_vaccinations, 
coalesce(sum(convert(bigint,new_vaccinations)) over(partition by location order by date),0) as cummulative_vaccinations 
from covidvaccinationss
where continent is not null --and location = 'India'
order by 1,2

--countries with the highest percentage of population receives at least one vaccination.
select v.location, max(convert(bigint,people_vaccinated))*100/max(convert(bigint,d.population)) as received_vaccination 
from covidvaccinationss v
join coviddeathss d on d.location=v.location
where people_vaccinated is not null
group by v.location
order by received_vaccination desc

--survival rate on new cases and deaths 
select ((sum(new_cases)-sum(new_deaths))/sum(new_cases))*100 as survival_rate_on_new_cases from coviddeathss;

--survival rate worldwide
select ((sum(total_cases)-sum(total_deaths))/sum(total_cases))*100 as survival_rate_worldwide from coviddeathss;