-- Create the final_project schema if it doesn't already exist
CREATE SCHEMA IF NOT EXISTS final_project;

-- Drop and create the countries table
CREATE TABLE IF NOT EXISTS final_project.countries (
    country_id SERIAL PRIMARY KEY,
    country_name TEXT UNIQUE,
    new_column TEXT
);

-- Economic stats table (financial, health, and tax-related)
CREATE TABLE IF NOT EXISTS final_project.economic (
    economic_id SERIAL PRIMARY KEY,
    country_id INT REFERENCES final_project.countries(country_id),
    armed_forces BIGINT,
    co2_emissions BIGINT,
    cpi FLOAT,
    fertility_rate FLOAT
);

-- Populate the economic table
INSERT INTO final_project.economic (country_id, armed_forces, co2_emissions, cpi, fertility_rate)
SELECT c.country_id, ws.armed_forces, ws.co2_emissions, ws.cpi, ws.fertility_rate
FROM final_project.world_stats ws
JOIN final_project.countries c ON ws.country_name = c.country_name;

-- Geography table (geographical data)
CREATE TABLE IF NOT EXISTS final_project.geography (
    geo_id SERIAL PRIMARY KEY,
    country_id INT NOT NULL,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    land_area BIGINT,
    agricultural_land BIGINT,
    forested_area BIGINT,
    FOREIGN KEY (country_id) REFERENCES final_project.countries(country_id) ON DELETE CASCADE
);

-- Populate the geography table
INSERT INTO final_project.geography (country_id, latitude, longitude, land_area, agricultural_land, forested_area)
SELECT c.country_id, ws.latitude, ws.longitude, ws.land_area, ws.agricultural_land, ws.forested_area
FROM final_project.world_stats ws
JOIN final_project.countries c ON ws.country_name = c.country_name;

-- Cities table (city-specific info)
CREATE TABLE IF NOT EXISTS final_project.cities (
    city_id SERIAL PRIMARY KEY,
    country_id INT NOT NULL,
    city_name TEXT,
    type TEXT,
    FOREIGN KEY (country_id) REFERENCES final_project.countries(country_id) ON DELETE CASCADE
);

-- Populate the cities table
INSERT INTO final_project.cities (country_id, city_name, type)
SELECT c.country_id, ws.capital_city AS city_name, 'capital' AS type
FROM final_project.world_stats ws
JOIN final_project.countries c ON ws.country_name = c.country_name;

-- Languages table (languages spoken)
CREATE TABLE IF NOT EXISTS final_project.languages (
    language_id SERIAL PRIMARY KEY,
    country_id INT NOT NULL,
    official_language TEXT,
    FOREIGN KEY (country_id) REFERENCES final_project.countries(country_id) ON DELETE CASCADE
);

-- Populate the languages table
INSERT INTO final_project.languages (country_id, official_language)
SELECT c.country_id, ws.official_language
FROM final_project.world_stats ws
JOIN final_project.countries c ON ws.country_name = c.country_name;

-- Financials table (country financial information)
CREATE TABLE IF NOT EXISTS final_project.financials (
    financial_id SERIAL PRIMARY KEY,
    country_id INT NOT NULL,
    gasoline_price DECIMAL(5, 2),
    minimum_wage DECIMAL(5, 2),
    tax_revenue FLOAT,
    total_tax_rate FLOAT,
    unemployment_rate FLOAT,
    FOREIGN KEY (country_id) REFERENCES final_project.countries(country_id) ON DELETE CASCADE
);

-- Populate the financials table
INSERT INTO final_project.financials (country_id, gasoline_price, minimum_wage, tax_revenue, total_tax_rate, unemployment_rate)
SELECT c.country_id, ws.gasoline_price, ws.minimum_wage, ws.tax_revenue, ws.total_tax_rate, ws.unemployment_rate
FROM final_project.world_stats ws
JOIN final_project.countries c ON ws.country_name = c.country_name;

-- Happiness table (happiness indicators)
CREATE TABLE IF NOT EXISTS final_project.happiness (
    happiness_id SERIAL PRIMARY KEY,
    country_id INT NOT NULL,
    life_ladder DECIMAL(5, 3),
    social_support DECIMAL(5, 3),
    healthy_life_expectancy DECIMAL(5, 2),
    freedom_life_choices DECIMAL(5, 3),
    generosity DECIMAL(5, 3),
    perceptions_of_corruption DECIMAL(5, 3),
    positive_affect DECIMAL(5, 3),
    negative_affect DECIMAL(5, 3),
    FOREIGN KEY (country_id) REFERENCES final_project.countries(country_id) ON DELETE CASCADE
);

-- Populate the happiness table
INSERT INTO final_project.happiness (country_id, life_ladder, social_support, healthy_life_expectancy, freedom_life_choices, generosity, perceptions_of_corruption, positive_affect, negative_affect)
SELECT c.country_id, hs.life_ladder, hs.social_support, hs.healthy_life_expectancy, hs.freedom_life_choices, hs.generosity, hs.perceptions_of_corruption, hs.positive_affect, hs.negative_affect
FROM final_project.happiness_stats hs
JOIN final_project.countries c ON hs.country_name = c.country_name;

-- Population table (population data)
CREATE TABLE IF NOT EXISTS final_project.population (
    population_id SERIAL PRIMARY KEY,
    country_id INT NOT NULL,
    population_density BIGINT,
    urban_population BIGINT,
    birth_rate FLOAT,
    infant_mortality FLOAT,
    life_expectancy BIGINT,
    FOREIGN KEY (country_id) REFERENCES final_project.countries(country_id) ON DELETE CASCADE
);

-- Populate the population table
INSERT INTO final_project.population (country_id, population_density, urban_population, birth_rate, infant_mortality, life_expectancy)
SELECT c.country_id, ws.population_density, ws.urban_population, ws.birth_rate, ws.infant_mortality, ws.life_expectancy
FROM final_project.world_stats ws
JOIN final_project.countries c ON ws.country_name = c.country_name;
