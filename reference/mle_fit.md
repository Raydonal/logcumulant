# Maximum-likelihood fit of a reliability distribution

Fits one of the six supported families by maximum likelihood, optimizing
on the log-scale of the parameters for numerical stability, and returns
the estimates together with the observed-information-based covariance.

## Usage

``` r
mle_fit(x, dist, init = NULL)
```

## Arguments

- x:

  Numeric vector of positive observations.

- dist:

  Character; distribution name.

- init:

  Optional numeric length-2 vector of starting values.

## Value

A list with elements `theta` (estimates), `Sigma` (covariance of
\\\sqrt{n}(\hat\theta-\theta)\\), `loglik`, and `conv` (convergence
flag).

## Examples

``` r
set.seed(1)
x <- rdist(200, "Gamma", c(3, 0.5))
fit <- mle_fit(x, "Gamma")
fit$theta
#> [1] 2.9954739 0.4774092
```
