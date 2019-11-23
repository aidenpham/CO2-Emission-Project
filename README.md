# CO2-Emission-Project
How do economic factors of a country correlate to its CO2 emission per capita?

The primary objective of this report is to find the relationships (impact) between the economic indicators (apart from GDP) and the CO2 emissions per capita of a country. We focused on the indicators that are related to the economy of a country. These indicators belong to the following groups:
● Economic Policy & Debt
● Social Protection & Labor: Economic activity

A quick correlation study will be made between the indicators selected and CO2 emission per capita. The high correlations (indicators) will be selected for further modelling. 

In the Modelling Part, we will build a Bayesian model based on Markov chain using RJAGS package in R. Next, the coefficients obtained by our Bayesian model will be cross-checked against the coefficients from a simple linear model. Finally, posteriors predicted by our model will be compared against actual values (from WDI data) to see whether there is any significant bias.

Results:
1. The results from the correlation analysis helped us to choose 6 indicators that have high correlation with CO2 emission per capita. These indicators fall into two groups: 1. Value added per worker (productivity) and 2. Percentage of employment in each sector. Out of 6 indicators, 5 have positive correlation while 1 indicator (% employment in agriculture) has negative correlation with CO2 emissions per capita. 

2. Our analysis indicated that North America had the largest CO2/emission per capita, and their productivity per capita was the highest for all sectors. In contrast, the African and South Asian countries have lower emissions and productivity, which also correlates to the lower economic development in these countries.

3. In terms of employment distribution, North America has the highest percentage of employment in service and the lowest in agriculture compared to other regions. As a result, they also have the highest CO2 per capita. The opposite pattern was observed for South Asia and Sub-Saharan Africa. We can say that when a country transitions from an agriculture-based to a service-based economy, their CO2 emission per capita will generally rise.

4. The modelling part of this report focused on the relationship between economic factors and CO2 emission per capita. CO2 emission per capita was the dependent variable, while the other 6 indicators were independent variables in this model. Due to multicollinearity, the independent variables with the highest VIF were removed, and our final model could predict CO2 per capita based on 2 independent variables (namely productivity in industry and % employment in industry) with an R square of nearly 0.6. 

5. The coefficients obtained by our Bayesian model was cross-checked against the coefficients from a simple linear model. Finally,
posteriors predicted by our model was compared against actual values (from WDI data) to see whether there is any significant bias. Possible future work will be to explore more economic indicators and fit more variables to the model.
