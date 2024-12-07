--Step #1:Creating Tables
        -- Create the final_project schema if it doesn't already exist
        CREATE SCHEMA IF NOT EXISTS final_project;
        
        -- Create the countries table
        CREATE TABLE final_project.countries ( 
            id SERIAL PRIMARY KEY, 
            country_name TEXT NOT NULL UNIQUE
        );
        
        -- Drop the cities table if it exists, then create a new one
        DROP TABLE IF EXISTS final_project.cities;
        CREATE TABLE final_project.cities (
          city_id SERIAL PRIMARY KEY,  -- Unique ID for each city record
          id INT NOT NULL,  -- Foreign key reference to countries table
          city_name TEXT NOT NULL,  
          city_type TEXT CHECK (city_type IN ('capital', 'largest')),  -- Ensure city type is either 'capital' or 'largest'
          FOREIGN KEY (id) REFERENCES final_project.countries(id) ON DELETE CASCADE  
        );
        
        -- Ensure each city is unique per country
        ALTER TABLE final_project.cities ADD CONSTRAINT unique_city_per_country UNIQUE (id, city_name);
        
        -- Create the happiness table to store happiness-related metrics
        CREATE TABLE final_project.happiness(
            id INT NOT NULL, -- Foreign key reference to countries table
            ladder_score DECIMAL(5, 3),
            social_support DECIMAL(5, 3),
            healthy_life_expectancy DECIMAL(5, 2),
            freedom_life_choices DECIMAL(5, 3),
            generosity DECIMAL(5, 3),
            perception_of_corruption DECIMAL(5, 3),
            FOREIGN KEY (id) REFERENCES final_project.countries(id) ON DELETE CASCADE
        );
        
        -- Create the languages table to store different languages
        CREATE TABLE final_project.languages (
            language_id SERIAL PRIMARY KEY,  
            language_name TEXT NOT NULL UNIQUE  -- Each language must have a unique name
        );
        
        -- Create the country_languages table to link countries with their languages
        CREATE TABLE final_project.country_languages (
            id INT NOT NULL,  -- Foreign key reference to countries table
            language_id INT NOT NULL, 
            PRIMARY KEY (id, language_id),  
            FOREIGN KEY (id) REFERENCES final_project.countries(id) ON DELETE CASCADE,
            FOREIGN KEY (language_id) REFERENCES final_project.languages(language_id) ON DELETE CASCADE
        );
        
        -- Create the economic table to store economic statistics
        CREATE TABLE final_project.economic (
            id INT PRIMARY KEY,  -- Foreign key reference to countries table
            armed_forces BIGINT,        
            co2_emissions BIGINT,        
            cpi FLOAT,                   
            fertility_rate FLOAT,       
            FOREIGN KEY (id) REFERENCES final_project.countries(id) ON DELETE CASCADE
        );
        
        -- Drop the geography table if it exists, then create a new one
        DROP TABLE IF EXISTS final_project.geography;
        CREATE TABLE final_project.geography (
            id INT PRIMARY KEY,  -- Foreign key reference to countries table
            latitude DOUBLE PRECISION, 
            longitude DOUBLE PRECISION, 
            land_area INT,           
            agricultural_land FLOAT,   
            forested_area FLOAT,       
            FOREIGN KEY (id) REFERENCES final_project.countries(id) ON DELETE CASCADE
        );
        
        -- Create the population_demographics table to store demographic data
        CREATE TABLE final_project.population_demographics (
            id INT PRIMARY KEY REFERENCES final_project.countries(id) ON DELETE CASCADE,
            population_density BIGINT,
            urban_population BIGINT
        );
        
        -- Create the health_metrics table to store health-related statistics
        CREATE TABLE final_project.health_metrics (
            id INT PRIMARY KEY REFERENCES final_project.countries(id) ON DELETE CASCADE,
            birth_rate FLOAT,
            infant_mortality FLOAT,
            life_expectancy FLOAT
        );
        
        -- Create the financials table to store financial data
        CREATE TABLE final_project.financials (
            id INT PRIMARY KEY,  -- Foreign key reference to countries table
            gasoline_price DECIMAL(5, 2),           
            minimum_wage DECIMAL(5, 2),            
            tax_revenue FLOAT,                     
            total_tax_rate FLOAT,                   
            unemployment_rate FLOAT,               
            FOREIGN KEY (id) REFERENCES final_project.countries(id) ON DELETE CASCADE  
        );
--Step #2: Populating Tables
        -- Insert data into the countries table
        INSERT INTO final_project.countries (country_name)
        SELECT DISTINCT country_name
        FROM (
            SELECT country_name FROM world_stats
            UNION
            SELECT country_name FROM happiness_stats
        ) AS combined_countries;
        
        -- Insert data into the cities table for capital cities
        INSERT INTO final_project.cities (id, city_name, city_type)
        SELECT c.id, ws.capital_city, 'capital'
        FROM world_stats ws
        JOIN final_project.countries c ON ws.country_name = c.country_name
        WHERE ws.capital_city IS NOT NULL
        ON CONFLICT (id, city_name) DO NOTHING;
        
        -- Insert data into the cities table for largest cities
        INSERT INTO final_project.cities (id, city_name, city_type)
        SELECT c.id, ws.largest_city, 'largest'
        FROM world_stats ws
        JOIN final_project.countries c ON ws.country_name = c.country_name
        WHERE ws.largest_city IS NOT NULL
        ON CONFLICT (id, city_name) DO NOTHING;
        
        -- Insert data into the happiness table
        INSERT INTO final_project.happiness (id, ladder_score, social_support, healthy_life_expectancy, freedom_life_choices, generosity, perception_of_corruption)
        SELECT DISTINCT c.id, hs.ladder_score, hs.social_support, hs.healthy_life_expectancy, hs.freedom_life_choices, hs.generosity, hs.perception_of_corruption
        FROM happiness_stats hs
        JOIN final_project.countries c ON hs.country_name = c.country_name;
        
        -- Insert data into the languages table
        INSERT INTO final_project.languages (language_name)
        SELECT DISTINCT official_language
        FROM world_stats
        WHERE official_language IS NOT NULL;
        
        -- Insert data into the country_languages table to link countries with their official languages
        INSERT INTO final_project.country_languages (id, language_id)
        SELECT c.id, l.language_id
        FROM world_stats ws
        JOIN final_project.countries c ON ws.country_name = c.country_name
        JOIN final_project.languages l ON ws.official_language = l.language_name
        WHERE ws.official_language IS NOT NULL;
        
        -- Insert data into the economic table
        INSERT INTO final_project.economic (id, armed_forces, co2_emissions, cpi, fertility_rate)
        SELECT DISTINCT c.id, ws.armed_forces, ws.co2_emissions, ws.cpi, ws.fertility_rate
        FROM world_stats ws
        JOIN final_project.countries c ON ws.country_name = c.country_name;
        
        -- Insert data into the geography table
        INSERT INTO final_project.geography (id, latitude, longitude, land_area, agricultural_land, forested_area)
        SELECT DISTINCT c.id, ws.latitude, ws.longitude, ws.land_area, ws.agricultural_land, 
                        ws.forested_area 
        FROM world_stats ws
        JOIN final_project.countries c ON ws.country_name = c.country_name;
        
        -- Insert data into the population_demographics table
        INSERT INTO final_project.population_demographics (id, population_density, urban_population)
        SELECT c.id, ws.population_density, ws.urban_population
        FROM world_stats ws
        JOIN final_project.countries c ON ws.country_name = c.country_name;
        
        -- Insert data into the health_metrics table
        INSERT INTO final_project.health_metrics (id, birth_rate, infant_mortality, life_expectancy)
        SELECT c.id, ws.birth_rate, ws.infant_mortality, ws.life_expectancy
        FROM world_stats ws
        JOIN final_project.countries c ON ws.country_name = c.country_name;
        
        -- Insert data into the financials table
        INSERT INTO final_project.financials (id, gasoline_price, minimum_wage, tax_revenue, total_tax_rate, unemployment_rate)
        SELECT c.id, ws.gasoline_price, ws.minimum_wage, ws.tax_revenue, ws.total_tax_rate, ws.unemployment_rate
        FROM world_stats ws
        JOIN final_project.countries c ON ws.country_name = c.country_name;

