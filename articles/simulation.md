# Simulation studies

``` r

library(logcumulant)
```

The package includes utilities to reproduce the size and power studies.
They are Monte Carlo intensive; the examples below use small replication
counts for speed.

## Empirical size

Under a true null, a well-calibrated test rejects at approximately the
nominal level. The asymptotic reference over-rejects, while the
bootstrap restores size.

``` r

size_study(sample_sizes = c(30, 50, 100, 200), Nsim = 1000)
```

## Empirical power

Power against a set of alternatives, with optional size-correction for a
fair comparison:

``` r

power_study(n = 100, Nsim = 1000)
```

## Reproducing the figures

The complete set of diagrams in the accompanying paper can be
regenerated with the bundled script:

``` r

# from the package source directory
source("reproduce_all_figures.R")
```
