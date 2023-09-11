-   <a href="#this-r-markdown-document" id="toc-this-r-markdown-document">1
    This R markdown document</a>
-   <a href="#the-case-study" id="toc-the-case-study">2 The case study</a>
-   <a href="#the-forecasting-workflow" id="toc-the-forecasting-workflow">3
    The forecasting workflow</a>
    -   <a href="#read-in-the-data" id="toc-read-in-the-data">3.1 Read in the
        data</a>
    -   <a href="#visualise-the-data" id="toc-visualise-the-data">3.2 Visualise
        the data</a>
-   <a href="#introducing-co-variates" id="toc-introducing-co-variates">4
    Introducing co-variates</a>
    -   <a href="#download-co-variates" id="toc-download-co-variates">4.1
        Download co-variates</a>
        -   <a href="#download-historic-data" id="toc-download-historic-data">4.1.1
            Download historic data</a>
        -   <a href="#download-future-weather-forecasts"
            id="toc-download-future-weather-forecasts">4.1.2 Download future weather
            forecasts</a>
-   <a href="#model-fitting" id="toc-model-fitting">5 Model fitting</a>
    -   <a href="#forecast-with-posteriors"
        id="toc-forecast-with-posteriors">5.1 Forecast with posteriors</a>
    -   <a href="#convert-to-efi-standard" id="toc-convert-to-efi-standard">5.2
        Convert to EFI standard</a>
-   <a href="#introduction-to-neon-forecast-challenge"
    id="toc-introduction-to-neon-forecast-challenge">6 Introduction to NEON
    forecast challenge</a>
    -   <a href="#aquatics-challenge" id="toc-aquatics-challenge">6.1 Aquatics
        challenge</a>
    -   <a href="#submission-requirements" id="toc-submission-requirements">6.2
        Submission requirements</a>
    -   <a href="#optional-submit-forecast"
        id="toc-optional-submit-forecast">6.3 Optional: Submit forecast</a>
    -   <a href="#possible-modifications-to-the-simple-model"
        id="toc-possible-modifications-to-the-simple-model">6.4 Possible
        modifications to the simple model:</a>
    -   <a href="#register-your-participation"
        id="toc-register-your-participation">6.5 Register your participation</a>
-   <a href="#decision-makers-request" id="toc-decision-makers-request">7
    <strong>Decision makers’ request</strong></a>

# 1 This R markdown document

This is a vignette on producing surface lake chlorophyll forecasts using
NEON data. Data are used in the NEON Forecasting Challenge and these
materials have been modified based on an original workshop materials
focused on submitting to the Challenge. To complete the workshop via
this markdown document the following packages will need to be installed:

-   `remotes`
-   `rjags`
-   `tidybayes`
-   `tidyverse`
-   `lubridate`
-   `neon4cast` (from github)

For the rjags code to work you first you need to install JAGS code from:
<https://mcmc-jags.sourceforge.io>

The following code chunk should be run to install packages. If you are
using the eco4cast/neon4cast Docker container you will not need to do
this install step.

``` r
install.packages('remotes')
install.packages('rjags')
install.packages('tidybayes')
install.packages('tidyverse') # collection of R packages for data manipulation, analysis, and visualisation
install.packages('lubridate') # working with dates and times
remotes::install_github('eco4cast/neon4cast') # package from NEON4cast challenge organisers to assist with forecast building and submission
```

Additionally, R version 4.2 is required to run the neon4cast package.
It’s also worth checking your Rtools is up to date and compatible with R
4.2, see
(<https://cran.r-project.org/bin/windows/Rtools/rtools42/rtools.html>).

``` r
version$version.string
```

    ## [1] "R version 4.2.2 (2022-10-31)"

``` r
library(tidybayes)
library(tidyverse)
```

    ## ── Attaching packages ─────────────────────────────────────── tidyverse 1.3.2 ──
    ## ✔ ggplot2 3.4.0      ✔ purrr   0.3.5 
    ## ✔ tibble  3.1.8      ✔ dplyr   1.0.10
    ## ✔ tidyr   1.2.1      ✔ stringr 1.4.1 
    ## ✔ readr   2.1.3      ✔ forcats 0.5.2 
    ## ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
    ## ✖ dplyr::filter() masks stats::filter()
    ## ✖ dplyr::lag()    masks stats::lag()

``` r
library(lubridate)
```

    ## Loading required package: timechange
    ## 
    ## Attaching package: 'lubridate'
    ## 
    ## The following objects are masked from 'package:base':
    ## 
    ##     date, intersect, setdiff, union

``` r
library(rjags)
```

    ## Loading required package: coda
    ## Linked to JAGS 4.3.0
    ## Loaded modules: basemod,bugs

If you do not wish to run the code yourself you can follow along via the
rendered markdown which can be viewed from the [Github
repository](https://github.com/OlssonF/NEON-forecast-challenge-workshop).

# 2 The case study

In this water quality forecasting example we will produce 30 day ahead
forecasts of lake surface chlorophyll concentration. Chlorophyll
concentration is a proxy used in water quality monitoring for algal
biomass. Large chlorophyll values can be an indication of algal blooms.
Algal blooms can be a problem for managers as they are linked to low
oxygen concentrations, fish kills and toxin production, all important
water quality parameters. The concentration of chlorophyll in natural
waters is driven by a complex interaction of temperatures, nutrients,
and hydrodynamic conditions that is not well quantified and can be quite
stochastic in nature - a great challenge for forecasters!

# 3 The forecasting workflow

## 3.1 Read in the data

We start forecasting by first looking at the historic data - called the
‘targets’. These data are available near real-time, with the latency of
approximately 24-48 hrs but for this introduction we will look at a
subset of the historic data.

``` r
#read in the targets data
targets <- read_csv('Data/targets-neon-chla.csv')
target_sites <- targets |> 
  distinct(site_id) |> 
  pull()
```

Information on the NEON sites can be found in the
`NEON_Field_Site_Metadata_20220412.csv` file on the eco4cast GitHub. It
can be filtered to only include the sites we will be looking at. This
table has information about the field sites, including location,
ecoregion, information about the watershed (e.g. elevation, mean annual
precipitation and temperature), and lake depth.

``` r
# read in the sites data
aquatic_sites <- read_csv("https://raw.githubusercontent.com/eco4cast/neon4cast-targets/main/NEON_Field_Site_Metadata_20220412.csv") |>
  dplyr::filter(field_site_id %in% target_sites)
```

Let’s take a look at the targets data!

``` r
glimpse(targets)
```

    ## Rows: 3,866
    ## Columns: 4
    ## $ datetime    <date> 2017-08-27, 2017-08-28, 2017-08-29, 2017-08-30, 2017-08-3…
    ## $ site_id     <chr> "BARC", "BARC", "BARC", "BARC", "BARC", "BARC", "BARC", "B…
    ## $ variable    <chr> "chla", "chla", "chla", "chla", "chla", "chla", "chla", "c…
    ## $ observation <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…

The columns of the targets file show the time step (daily for this water
quality data), the 4 character site code (`site_id`), the variable being
measured, and the mean daily observation. Here we are looking only at
two lake sites (`BARC` and `SUGG`) chlorophyll concentration (ug/L)
(`chla`) observations.

## 3.2 Visualise the data

``` r
targets %>%
  ggplot(., aes(x = datetime, y = observation)) +
  geom_point() +   
  theme_bw() + theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5)) +
  facet_wrap(~site_id, scales = 'free_y')+
  labs(title = 'chla')
```

![Figure: Chlorophyll targets data at two lake sites provided by EFI for
the NEON forecasting
challgenge.](WQ_forecasting_vignette_files/figure-markdown_github/unnamed-chunk-6-1.png)

# 4 Introducing co-variates

One important step to overcome when thinking about generating forecasts
is to include co-variates in the model. A chlorophyll forecast, for
example, may be benefit from information about past and future weather.
Below is code snippets for downloading past and future NOAA weather
forecasts for all of the NEON sites. The 3 types of data are as follows:

-   stage_1: raw forecasts - 31 member ensemble forecasts at 3 hr
    intervals for the first 10 days, and 6 hr intervals for up to 35
    days at the NEON sites.
-   stage_2: a processed version of Stage 1 in which fluxes are
    standardized to per second rates, fluxes and states are interpolated
    to 1 hour intervals and variables are renamed to match conventions.
    We recommend this for obtaining future weather. Future weather
    forecasts include a 30-member ensemble of equally likely future
    weather conditions.
-   stage_3: can be viewed as the “historical” weather and is
    combination of day 1 weather forecasts (i.e., when the forecasts are
    most accurate).

This code create a connection to the dataset hosted on the eco4cast
server. To download the data you have to tell the function to
`collect()` it. These data set can be subsetted and filtered using
`dplyr` functions prior to download to limit the memory usage.

You can read more about the NOAA forecasts available for the NEON sites
[here:](https://projects.ecoforecast.org/neon4cast-docs/Shared-Forecast-Drivers.html)

## 4.1 Download co-variates

### 4.1.1 Download historic data

We will generate a chlorophyll forecast using `air_temperature` as a
co-variate. Note: This code chunk can take a little to execute as it
accesses the NOAA data depending on your internet connection.

``` r
# past stacked weather
bucket <- "neon4cast-drivers/noaa/gefs-v12/stage3/parquet/"
s3_past <- arrow::s3_bucket(bucket, endpoint_override = "data.ecoforecast.org", anonymous = TRUE)

variables <- c("air_temperature")
#Other variable names can be found at https://projects.ecoforecast.org/neon4cast-docs/Shared-Forecast-Drivers.html#stage-3

noaa_past <- arrow::open_dataset(s3_past) |> 
  dplyr::filter(site_id %in% target_sites,
                datetime >= ymd('2017-01-01'),
                variable %in% variables) |> 
  collect()

noaa_past[1:10,]
```

    ## # A tibble: 10 × 9
    ##    datetime            site_id longitude latitude family  param…¹ varia…² height
    ##    <dttm>              <chr>       <dbl>    <dbl> <chr>     <int> <chr>   <chr> 
    ##  1 2020-09-27 18:00:00 BARC        -82.0     29.7 ensemb…       1 air_te… 2 m a…
    ##  2 2020-09-27 18:00:00 BARC        -82.0     29.7 ensemb…       2 air_te… 2 m a…
    ##  3 2020-09-27 18:00:00 BARC        -82.0     29.7 ensemb…       3 air_te… 2 m a…
    ##  4 2020-09-27 18:00:00 BARC        -82.0     29.7 ensemb…       4 air_te… 2 m a…
    ##  5 2020-09-27 18:00:00 BARC        -82.0     29.7 ensemb…       5 air_te… 2 m a…
    ##  6 2020-09-27 18:00:00 BARC        -82.0     29.7 ensemb…       6 air_te… 2 m a…
    ##  7 2020-09-27 18:00:00 BARC        -82.0     29.7 ensemb…       7 air_te… 2 m a…
    ##  8 2020-09-27 18:00:00 BARC        -82.0     29.7 ensemb…       8 air_te… 2 m a…
    ##  9 2020-09-27 18:00:00 BARC        -82.0     29.7 ensemb…       9 air_te… 2 m a…
    ## 10 2020-09-27 18:00:00 BARC        -82.0     29.7 ensemb…      10 air_te… 2 m a…
    ## # … with 1 more variable: prediction <dbl>, and abbreviated variable names
    ## #   ¹​parameter, ²​variable

This is a stacked ensemble forecast of the one day ahead forecasts. To
get an estimate of the historic conditions we can take a mean of these
ensembles. We will also need to convert the temperatures to Celsius from
Kelvin.

``` r
# aggregate the past to mean values
noaa_past_mean <- noaa_past |> 
  mutate(datetime = as_date(datetime)) |> 
  group_by(datetime, site_id, variable) |> 
  summarize(prediction = mean(prediction, na.rm = TRUE), .groups = "drop") |> 
  pivot_wider(names_from = variable, values_from = prediction) |> 
  # convert air temp to C
  mutate(air_temperature = air_temperature - 273.15) |> 
  filter(datetime <= as_date(max(targets$datetime)))
```

We can then look at the future weather forecasts in the same way but
using the `noaa_stage2()`. The forecast becomes available from NOAA at
5am UTC the following day, so if we were producing realtime forecasts we
would need take the NOAA forecast from yesterday to make the water
quality forecasts. But for this example we will produce forecasts from
the end of the targets for the next 35 days. The stage 2 NOAA forecast
is all an ensemble of 31 simulations which we can use to produce an
estimate of driver uncertainty in the chlorophyll forecast.

### 4.1.2 Download future weather forecasts

``` r
# Note: New forecast only available at 5am UTC the next day - so if forecasting in realtime look for yesterday's forecast

# generate forecast(s) for June 2023
forecast_date <- as_date(max(targets$datetime))

bucket <- paste0("neon4cast-drivers/noaa/gefs-v12/stage2/parquet/0/", forecast_date) 
s3_future <- arrow::s3_bucket(bucket = bucket, endpoint_override = 'data.ecoforecast.org', anonymous = TRUE)

variables <- c("air_temperature")

noaa_future <- arrow::open_dataset(s3_future) |> 
  dplyr::filter(datetime >= forecast_date,
                site_id %in% target_sites,
                variable %in% variables) |> 
  collect()
```

The forecasts are hourly and we are interested in using daily mean air
temperature for lake chlorophyll forecast generation.

``` r
noaa_future_daily <- noaa_future |> 
  mutate(datetime = as_date(datetime)) |> 
  # mean daily forecasts at each site per ensemble
  group_by(datetime, site_id, parameter, variable) |> 
  summarize(prediction = mean(prediction)) |>
  pivot_wider(names_from = variable, values_from = prediction) |>
  # convert to Celsius
  mutate(air_temperature = air_temperature - 273.15) |> 
  select(datetime, site_id, air_temperature, parameter)
```

    ## `summarise()` has grouped output by 'datetime', 'site_id', 'parameter'. You can
    ## override using the `.groups` argument.

``` r
noaa_future_daily[1:10,]
```

    ## # A tibble: 10 × 4
    ## # Groups:   datetime, site_id, parameter [10]
    ##    datetime   site_id air_temperature parameter
    ##    <date>     <chr>             <dbl>     <int>
    ##  1 2023-05-31 BARC               24.5         1
    ##  2 2023-05-31 BARC               23.4         2
    ##  3 2023-05-31 BARC               24.6         3
    ##  4 2023-05-31 BARC               22.9         4
    ##  5 2023-05-31 BARC               24.3         5
    ##  6 2023-05-31 BARC               23.6         6
    ##  7 2023-05-31 BARC               24.9         7
    ##  8 2023-05-31 BARC               22.6         8
    ##  9 2023-05-31 BARC               23.4         9
    ## 10 2023-05-31 BARC               23.8        10

Now we have a timeseries of historic data and a 30 member ensemble
forecast of future air temperatures.

``` r
ggplot(noaa_future_daily, aes(x=datetime, y=air_temperature)) +
  geom_line(aes(group = parameter), alpha = 0.4)+
  geom_line(data = noaa_past_mean, colour = 'darkblue') +
  facet_wrap(~site_id, scales = 'free')
```

![Figure: historic and future NOAA air temeprature forecasts at lake
sites](WQ_forecasting_vignette_files/figure-markdown_github/unnamed-chunk-11-1.png)

``` r
ggplot(noaa_future_daily, aes(x=datetime, y=air_temperature)) +
  geom_line(aes(group = parameter), alpha = 0.4)+
  geom_line(data = noaa_past_mean, colour = 'darkblue') +
  coord_cartesian(xlim = c(forecast_date - days(60),
                           forecast_date + days(35)))+
  facet_wrap(~site_id, scales = 'free')
```

![Figure: last two months of historic air temperature forecasts and 35
day ahead
forecast](WQ_forecasting_vignette_files/figure-markdown_github/unnamed-chunk-11-2.png)

# 5 Model fitting

We will fit a simple dynamic JAGS model with historic air temperature
and the chlorophyll targets data. Using this model we can then use our
future estimates of air temperature (all 30 ensembles) to forecast
chlorophyll at each site. The model will estimate both process and
observational uncertainty. In addition, the ensemble weather forecast
will also give an estimate of driver data uncertainty.

We will start by joining the historic weather data with the targets to
aid in fitting the model.

``` r
targets_lm <- targets |> 
  pivot_wider(names_from = 'variable', values_from = 'observation') |> 
  left_join(noaa_past_mean, 
            by = c("datetime","site_id"))

targets_lm[1050:1060,]
```

    ## # A tibble: 11 × 4
    ##    datetime   site_id  chla air_temperature
    ##    <date>     <chr>   <dbl>           <dbl>
    ##  1 2020-12-26 BARC     1.91            11.8
    ##  2 2020-12-27 BARC     1.64            13.4
    ##  3 2020-12-28 BARC     1.46            16.5
    ##  4 2020-12-29 BARC     1.17            16.9
    ##  5 2020-12-30 BARC     1.23            18.3
    ##  6 2020-12-31 BARC     1.32            20.0
    ##  7 2021-01-01 BARC     1.58            20.8
    ##  8 2021-01-02 BARC     1.40            20.4
    ##  9 2021-01-03 BARC     1.80            19.6
    ## 10 2021-01-04 BARC     1.06            15.7
    ## 11 2021-01-05 BARC     1.40            15.8

``` r
example_site <- 'SUGG'

site_target <- targets_lm |> 
  filter(site_id == example_site)

#Find when the data for the site starts and filter to only 
#more recent datetimes with no NAs
first_no_na <- site_target |> 
  filter(!is.na(air_temperature) & !is.na(chla)) |> 
  summarise(min = min(datetime)) |> 
  pull(min)

site_target <- site_target |> 
  filter(datetime >= first_no_na)
```

We fit the model as a state-space Bayesian model. The following is BUGS
code that specifies the model. Explaining the Bayesian model is beyond
the scope of this tutorial.

``` r
jags_code <- "
model{

  # Priors
  beta1 ~ dnorm(0, 1/10000)
  beta2 ~ dnorm(0, 1/10000)
  sd_process ~ dunif(0.00001, 100)
  
  #Convert Standard Deviation to precision
  tau_obs <- 1 / pow(sd_obs, 2)
  tau_process <- 1 / pow(sd_process, 2)

  #Initial conditions
  chla_latent[1] <- chla_init
  y[1] ~ dnorm(chla_latent[1], tau_process)  

  #Loop through data points
  for(i in 2:n){
      # Process model
      chla_pred[i] <- beta1 * chla_latent[i-1] + beta2 * air_temp[i]
      chla_latent[i] ~ dnorm(chla_pred[i], tau_process)

      # Data model
      y[i]  ~ dnorm(chla_latent[i], tau_obs)
  }
}
"
```

Set up the fixed inputs for the JAGS model specification. This includes
the covariates, observations, loop indexes, initial conditions, and any
fixed parameter values. Here we fix the standard deviation of the
observations, since it is challenging to estimate without multiple
measurements at the same datetime.

``` r
data <- list(air_temp = site_target$air_temperature,
             y = site_target$chla,
             n = length(site_target$air_temperature),
             sd_obs = 0.1,
             chla_init = site_target$chla[1])
```

Initialize random variables in JAGS model for each of the 3 chains.

``` r
nchain <- 3
inits <- list()
for(i in 1:nchain){
  inits[[i]] <- list(beta1 = rnorm(1, 0.34, 0.05), 
                     beta2 = rnorm(1, 0.11, 0.05),
                     sd_process = runif(1, 0.05, 0.15 ))
}
```

Build JAGS model object and fit JAGS code

``` r
j.model <- jags.model(file = textConnection(jags_code),
                      data = data,
                      inits = inits,
                      n.chains = 3)
```

    ## Compiling model graph
    ##    Resolving undeclared variables
    ##    Allocating nodes
    ## Graph information:
    ##    Observed stochastic nodes: 716
    ##    Unobserved stochastic nodes: 1230
    ##    Total graph size: 5845
    ## 
    ## Initializing model

``` r
#Run MCMC
jags.out   <- coda.samples(model = j.model,
                           variable.names = c("beta1", 
                                              "beta2",
                                              "chla_latent",
                                              "sd_process"),
                           n.iter = 5000)
```

Convert MCMC object to tidy data and remove iterations in burn-in. We
only keep the latent state on last day for use as initial conditions in
the forecast.

``` r
burn_in <- 1000
chain <- jags.out %>%
  tidybayes::spread_draws(beta1, beta2, sd_process, chla_latent[day]) |> 
  filter(.iteration > burn_in) |> 
  ungroup()

max_day <- max(chain$day)
chain <- chain |> 
  filter(day == max_day) |> 
  select(-day)
```

Visualize the chain to inspect for convergence.

``` r
chain |> 
  pivot_longer(beta1:chla_latent, names_to = "variable" , values_to = "value") |> 
  ggplot(aes(x = .iteration, y = value, color = factor(.chain))) +
  geom_line() +
  facet_wrap(~variable, scale = "free")
```

![](WQ_forecasting_vignette_files/figure-markdown_github/unnamed-chunk-19-1.png)

## 5.1 Forecast with posteriors

Here we generate a forecast using 500 random draws from the posterior
distributions. The following code loops over the samples and then
forecasts each day in the future. It also samples from the ensembles in
the NOAA weather forecast.

The forecasted values is the latent state forecast with observation
uncertainty added.

``` r
num_samples <- 500

noaa_future_site <- noaa_future_daily |> 
  filter(site_id == example_site)

n_days <- length(unique(noaa_future_site$datetime))
chla_latent <- matrix(NA, num_samples, n_days)   
y <- matrix(NA, num_samples, n_days) #y is the forecasted observation
forecast_df <- NULL



#loop over posterior samples
for(i in 1:num_samples){
  sample_index <- sample(x = 1:nrow(chain), size = 1, replace = TRUE)
  noaa_ensemble <- sample(x = 1:30, size = 1)
  noaa_future_site_ens <- noaa_future_site |> filter(parameter == noaa_ensemble)
  #Initialize with a sample from the most recent latent state posterior distribution
  chla_latent[i,1] <- chain$chla_latent[sample_index]
  y[i, 1] <- rnorm(1, chla_latent[i,1], sd = data$sd_obs)
  
  #loop over forecast days
  for(j in 2:n_days){
    pred <- chla_latent[i,j-1] * chain$beta1[sample_index] +
      noaa_future_site_ens$air_temperature[j] * chain$beta2[sample_index]
    
    chla_latent[i,j] <- rnorm(1, pred, chain$sd_process[sample_index])
    y[i,j] <- rnorm(1, chla_latent[i,j], sd = data$sd_obs)
    
  }
  
  #Build formated forecast
  df <- tibble(datetime = noaa_future_site_ens$datetime,
               site_id = example_site,
               variable = "chla",
               parameter = i,
               prediction = y[i, ])
  
  forecast_df <- bind_rows(forecast_df, df)
}
```

We now have 500 possible trajectories of chlorophyll-a at each site and
each day. On this plot each line represents one of the possible
trajectories and the range of forecasted trajectories is a simple
quantification of the uncertainty in our forecast.

Looking back at the forecasts we produced:

``` r
forecast_df %>% 
  ggplot(.,aes(x=datetime, y=prediction, group = parameter)) + 
  geom_point(data = subset(targets, site_id == 'SUGG'),
             aes(x=datetime, y=observation, group = 'obs'), colour = 'black') +
  geom_line(alpha = 0.3, aes(colour = 'ensemble member (parameter)')) + 
  facet_wrap(~site_id, scales = 'free_y') +
  scale_x_date(expand = c(0,0), date_labels = "%d %b") +
  labs(y = 'value') +
  geom_vline(aes(linetype = 'reference_datetime', 
                 xintercept = as_date(max(targets$datetime))), 
             colour = 'blue', size = 1.5) +
  labs(title = 'site_id', subtitle = 'variable = temperature', caption = 'prediction') + 
  annotate("text", x = min(forecast_df$datetime) - days(10), y = 40, label = "past")  +
  annotate("text", x = min(forecast_df$datetime) + days(12), y = 40, label = "future")  +
  theme_bw() +
  coord_cartesian(xlim = c(min(forecast_df$datetime) - 30, Sys.Date())) +
  scale_linetype_manual(values = 'dashed', name = '')+
  scale_colour_manual(name = '', values = 'red')
```

![](WQ_forecasting_vignette_files/figure-markdown_github/unnamed-chunk-21-1.png)

## 5.2 Convert to EFI standard

Forecast standards are useful for maintaining consistent formats across
forecast generations. For an ensemble forecast the standards specifthe y
following columns:

-   `datetime`: forecast timestamp for each time step
-   `reference_datetime`: The start of the forecast; this should be 0
    times steps in the future. This should only be one value of
    reference_datetime in the file
-   `site_id`: NEON code for site
-   `family`: name of probability distribution that is described by the
    parameter values in the parameter column; only `normal` or
    `ensemble` are currently allowed.
-   `parameter`: integer value for forecast replicate (from the `.rep`
    in fable output);
-   `variable`: standardized variable name from the theme
-   `prediction`: forecasted value (from the `.sim` column in fable
    output)
-   `model_id`: model name (no spaces)

We need to make sure the dataframe is in the correct format. This is an
ensemble forecast (specified in the `family` column).

``` r
# Remember to change the model_id when you make changes to the model structure!
my_model_id <- 'your_model_id'

forecast_df_efi <- forecast_df %>%
  mutate(model_id = my_model_id,
         reference_datetime = as_date(min(datetime)) - days(1),
         family = 'ensemble',
         parameter = as.character(parameter)) %>%
  select(model_id, datetime, reference_datetime, site_id, family, parameter, variable, prediction)
```

For the NEON forecast Challenge (including the aquatics theme) the
following standards are needed for a forecast submission.

# 6 Introduction to NEON forecast challenge

These data collected by NEON and form part of the EFI-NEON Forecasting
Challenge. The Challenge asks the scientific community to produce
ecological forecasts of future conditions at NEON sites by leveraging
NEON’s open data products. The Challenge is split into five themes that
span aquatic and terrestrial systems, and population, community, and
ecosystem processes across a broad range of ecoregions. We are excited
to use this Challenge to learn more about the predictability of
ecological processes by forecasting NEON data before it is collected.

Which modeling frameworks, mechanistic processes, and statistical
approaches best capture community, population, and ecosystem dynamics?
These questions are answerable by a community generating a diverse array
of forecasts. The Challenge is open to any individual or team from
anywhere around the world that wants to submit forecasts. Sign up
[here.](https://projects.ecoforecast.org/neon4cast-docs/Participation.html).

## 6.1 Aquatics challenge

What: Freshwater surface water temperature, oxygen, and chlorophyll-a.

Where: 7 lakes and 27 river/stream NEON sites.

When: Daily forecasts for at least 30-days in the future. New forecast
submissions, that use new data to update the forecast, are accepted
daily. The only requirement is that submissions are predictions of the
future at the time the forecast is submitted. To submit a forecast to
the Challenge these need to be **realtime** (actual forecasts of the
future)! Real-time data are available for submissions to the Challenge.
See
[documentation](https://projects.ecoforecast.org/neon4cast-docs/Aquatics.html).

Today we looked at just two of the lake sites and forecasted chlorophyll
concentration of a historic time period. For the challenge, you can
chose to submit to any/all of the sites! You can also chose to submit
any of the three focal variables (temperature, oxygen, and chlorophyll).
But should be acutal forecasts of the future! Find more information
about the aquatics challenge
[here](https://projects.ecoforecast.org/neon4cast-docs/Aquatics.html).

## 6.2 Submission requirements

For the Challange, forecasts must include quantified uncertainty. The
file can represent uncertainty using an ensemble forecast (multiple
realizations of future conditions) or a distribution forecast (with mean
and standard deviation), specified in the family and parameter columns
of the forecast file.

For an ensemble forecast, the `family` column uses the word `ensemble`
to designate that it is a ensemble forecast and the parameter column is
the ensemble member number (1, 2, 3 …). For a distribution forecast, the
`family` column uses the word `normal` to designate a normal
distribution and the parameter column must have the words mu and sigma
for each forecasted variable, site_id, and datetime. For forecasts that
don’t have a normal distribution we recommend using the ensemble format
and sampling from your non-normal distribution to generate a set of
ensemble members that represents your distribution. I will go through
examples of both `ensemble` and `normal` forecasts as examples.

The full list of required columns and format can be found in the
[Challenge
documentation](https://projects.ecoforecast.org/neon4cast-docs/Submission-Instructions.html).

## 6.3 Optional: Submit forecast

The final step to submit a formatted forecast to the Challenge is below.
The forecast organizers have created tools to help aid in the submission
process. These tools can be downloaded from Github using
`remotes::install_github(eco4cast/neon4cast)`. These include functions
for submitting, scoring and reading forecasts:

-   `submit()` - submit the forecast file to the neon4cast server where
    it will be scored
-   `forecast_output_validator()` - will check the file is in the
    correct format to be submitted
-   `check_submission()` - check that your submission has been uploaded
    to the server

The file name needs to be in the format
theme-reference_datetime-model_id

``` r
# Start by writing the forecast to file
theme <- 'aquatics'
date <- forecast_df_efi$reference_datetime[1]
forecast_name_1 <- paste0(forecast_df_efi$model_id[1], ".csv")
forecast_file_1 <- paste(theme, date, forecast_name_1, sep = '-')
forecast_file_1
```

    ## [1] "aquatics-2023-05-30-your_model_id.csv"

``` r
if (!dir.exists('Forecasts')) {
  dir.create('Forecasts')
}
write_csv(forecast_df_efi, file.path('Forecasts', forecast_file_1))

neon4cast::forecast_output_validator(file.path('Forecasts', forecast_file_1))
```

    ## Forecasts/aquatics-2023-05-30-your_model_id.csv

    ## ✔ file name is correct
    ## ✔ forecasted variables found correct variable + prediction column
    ## ✔ file has ensemble distribution in family column
    ## ✔ file has parameter and family column with ensemble generated distribution
    ## ✔ file has site_id column
    ## ✔ file has time column
    ## ✔ file has correct time column
    ## ✔ file has reference_datetime column
    ## Forecast format is valid

    ## [1] TRUE

``` r
# can uses the neon4cast::forecast_output_validator() to check the forecast is in the right format
neon4cast::submit(forecast_file = file.path('Forecasts', forecast_file_1),
                  ask = FALSE) # if ask = T (default), it will produce a pop-up box asking if you want to submit
```

## 6.4 Possible modifications to the simple model:

-   Include additional NOAA co-variates in the linear model (remember to
    ‘collect’ and subset the right data from NOAA)
-   Specify a non-linear relationship
-   Include a lag in the predictors

Remember to change the `model_id` so you can differentiate different
forecasts!

## 6.5 Register your participation

It’s really important that once you start submitting forecasts to the
Challenge that you register your participation. We ask that you complete
this [form](https://nd.qualtrics.com/jfe/form/SV_9MJ29y2xNrBOjqZ) which
asks you some simple questions about your forecast and team. This is
crucial for a couple of reasons:

1.  We can keep track different forecast submissions during the scoring
    process to see which forecast is performing the best. Your
    `model_id` will be used to track the submissions so any new forecast
    model requires a new `model_id`.
2.  The form gives consent for submissions to be included in
    Challenge-wide syntheses being carried out by the Challenge
    organisers. Partipants in the Challenge will be invited to join the
    synthesis projects on an opt-in basis.

Questions about Challenge registration and synthesis participation can
be directed to [Freya Olsson](mailto:freyao@vt.edu).

# 7 **Decision makers’ request**

Lake and reservoir managers could use forecasts of chlorophyll
concentrations in surface waters for a number of reasons. For example, a
forecast at 1-30 days ahead could be used to:

-   To inform swimming/boating restrictions for safe recreation (given
    the toxin production by some algae species - chlorophyll a can be a
    useful proxy)
-   Prepare water treatment processes - buy/replace filters, buy
    chemicals, change staffing levels, switch to an alternate drinking
    water supply

Using the baseline model introduced above, the lake managers are
interested in a 1-30 day ahead forecast for July 2023 (and beyond if you
like) to understand when a bloom might occur in the next month to inform
the open/close status of the lake for swimming and to organise the
drinking water treatment processes. A lake will be closed for swimming
if concentrations go above 20 mg/L.

The forecasts should address the following questions:

-   should one lake be chosen for drinking water this month over the
    other? (how do the forecasts of chlorophyll concentration differ
    between the sites? which is higher/lower?)
-   what are the maximum concentrations that will occur in the next 30
    days? And when will this maximum level occur?
-   are chlorophyll concentrations likely to be higher or lower than
    normal for the time of year? (comparison with a climatology
    forecast)
-   what are the chances that the lake(s) will be closed in the next
    month for swimming?

New data will be available later in the week to assess the success of
your forecasts.

Note: These lakes monitored by NEON are not used for drinking water and
the threshold indicated above is for illustrative purposes only!
