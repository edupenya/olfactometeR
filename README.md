
<!-- README.md is generated from README.Rmd. Please edit that file -->

<img width="120px" alt="olfactometeR logo" align="right" src="man/figures/logo.png">

# olfactometeR - Streamlined data acquisition and analysis for olfactometer experiments

<!-- badges: start -->

<!-- badges: end -->

The olfactometeR package provides various features that optimise
olfactometer experiments from data acquisition to visualisation and
analysis. This package was largely written for personal use, but as the
currently available software programmes for olfactometer experiments are
either expensive or outdated and without an existing R package it has
made publically available.

*DISCLAIMER: olfactometeR is currently under active development and not
all features are optimised or available at present.*

## Installation

You can install the development version of olfactometeR from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("Dr-Joe-Roberts/olfactometeR")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(olfactometeR)
## basic example code
```

What is special about using `README.Rmd` instead of just `README.md`?
You can include R chunks like so:

``` r
summary(cars)
#>      speed           dist       
#>  Min.   : 4.0   Min.   :  2.00  
#>  1st Qu.:12.0   1st Qu.: 26.00  
#>  Median :15.0   Median : 36.00  
#>  Mean   :15.4   Mean   : 42.98  
#>  3rd Qu.:19.0   3rd Qu.: 56.00  
#>  Max.   :25.0   Max.   :120.00
```

You’ll still need to render `README.Rmd` regularly, to keep `README.md`
up-to-date.

You can also embed plots, for example:

<img src="man/figures/README-pressure-1.png" width="100%" />

In that case, don’t forget to commit and push the resulting figure
files, so they display on GitHub\!
