--Demographics
    -- Countries with the highest GDP, happiness ladder score, and an urban population exceeding 50% of the total population.
            SELECT 
                c.country_name,
                e.gdp,
                h.ladder_score,
                pd.urban_population
            FROM 
                countries c
            JOIN 
                economic e ON c.id = e.country_id
            JOIN 
                happiness h ON c.id = h.country_id
            JOIN 
                population_demographics pd ON c.id = pd.country_id
            WHERE 
                e.gdp IN (SELECT MAX(gdp) FROM economic)
                AND h.ladder_score IN (SELECT MAX(ladder_score) FROM happiness)
                AND pd.urban_population > 50;
    
    -- Correlation between generosity and happiness ladder score.
            WITH CorrelationData AS (
                SELECT 
                    s.generosity,
                    h.ladder_score
                FROM 
                    social s
                JOIN 
                    happiness h ON s.country_id = h.country_id
            ),
            Stats AS (
                SELECT 
                    COUNT(*) AS n,
                    SUM(generosity) AS sum_x,
                    SUM(ladder_score) AS sum_y,
                    SUM(generosity * ladder_score) AS sum_xy,
                    SUM(generosity * generosity) AS sum_xx,
                    SUM(ladder_score * ladder_score) AS sum_yy
                FROM 
                    CorrelationData
            )
            SELECT 
                (n * sum_xy - sum_x * sum_y) / 
                SQRT((n * sum_xx - sum_x * sum_x) * (n * sum_yy - sum_y * sum_y)) AS correlation_coefficient
            FROM 
                Stats;

--Geographical:                
    -- Country with the highest happiness score and the lowest perception of corruption.
            SELECT 
                h.country_name,
                h.ladder_score,
                s.perception_of_corruption
            FROM 
                happiness h
            JOIN 
                social s ON h.country_id = s.country_id
            ORDER BY 
                h.ladder_score DESC, 
                s.perception_of_corruption ASC
            LIMIT 1;

--Economical:
    -- Top countries with the highest combined happiness ladder score, minimum wage, and GDP.
            SELECT 
                c.country_name,
                h.ladder_score,
                e.minimum_wage,
                e.gdp,
                (h.ladder_score + e.minimum_wage + e.gdp) AS combined_score
            FROM 
                countries c
            JOIN 
                happiness h ON c.id = h.country_id
            JOIN 
                economic e ON c.id = e.country_id
            ORDER BY 
                combined_score DESC
            LIMIT 10;
    
    -- Country with the highest minimum wage and a high overall happiness ladder score.
            SELECT 
                c.country_name,
                e.minimum_wage,
                h.ladder_score
            FROM 
                countries c
            JOIN 
                economic e ON c.id = e.country_id
            JOIN 
                happiness h ON c.id = h.country_id
            WHERE 
                h.ladder_score > (SELECT AVG(ladder_score) FROM happiness)
            ORDER BY 
                e.minimum_wage DESC
            LIMIT 1;
    
    -- Correlation between minimum wage and happiness ladder score across countries.
            WITH CorrelationData AS (
                SELECT 
                    e.minimum_wage,
                    h.ladder_score
                FROM 
                    economic e
                JOIN 
                    happiness h ON e.country_id = h.country_id
            ),
            Stats AS (
                SELECT 
                    COUNT(*) AS n,
                    SUM(minimum_wage) AS sum_x,
                    SUM(ladder_score) AS sum_y,
                    SUM(minimum_wage * ladder_score) AS sum_xy,
                    SUM(minimum_wage * minimum_wage) AS sum_xx,
                    SUM(ladder_score * ladder_score) AS sum_yy
                FROM 
                    CorrelationData
            )
            SELECT 
                (n * sum_xy - sum_x * sum_y) / 
                SQRT((n * sum_xx - sum_x * sum_x) * (n * sum_yy - sum_y * sum_y)) AS correlation_coefficient
            FROM 
                Stats;
    
    -- How tax revenue or tax rates affect the perception of corruption or happiness ladder score.
            WITH CorrelationData AS (
                SELECT 
                    f.tax_revenue,
                    f.total_tax_rate,
                    h.perception_of_corruption,
                    h.ladder_score
                FROM 
                    financials f
                JOIN 
                    countries c ON f.country_id = c.id
                JOIN 
                    happiness h ON c.id = h.country_id
            )
            SELECT 
                (SELECT CORR(tax_revenue, perception_of_corruption) FROM CorrelationData) AS corr_tax_revenue_corruption,
                (SELECT CORR(total_tax_rate, perception_of_corruption) FROM CorrelationData) AS corr_tax_rate_corruption,
                (SELECT CORR(tax_revenue, ladder_score) FROM CorrelationData) AS corr_tax_revenue_happiness,
                (SELECT CORR(total_tax_rate, ladder_score) FROM CorrelationData) AS corr_tax_rate_happiness;
    
