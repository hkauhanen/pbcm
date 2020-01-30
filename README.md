---
output: github_document
---

<!-- README.md is generated from README.Rmd. Please edit that file -->


# pbcm

pbcm is an R package that implements both data-informed and data-uninformed versions of the Parametric Bootstrap Cross-fitting Method (PBCM; Wagenmakers et al. 2004), a general-purpose technique for binary model selection. Some auxiliary routines, such as decision through *k* nearest neighbours classification (Schultheis & Singhaniya 2015), are also implemented.

## Installation

You can install the released version of pbcm from [CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("pbcm")
```

## Basic usage

Suppose we have the following data:

```r
x <- seq(from=0, to=1, length.out=100)
mockdata <- data.frame(x=x, y=x + rnorm(100, 0, 0.5))
ggplot2::ggplot(mockdata, aes(x=x, y=y)) + ggplot2::geom_point()
```

Suppose we wish to find out which of the following two models best explains these data:

* Model 1: `y = a*x + E`
* Model 2: `y = a*x^2 + E`

where `E` is some Gaussian noise.

The first thing to do is to define our own routine for fitting these models. We could use a dedicated routine for each model, but because of the simplicity of the example and the obvious parallels between the two models, we're in fact going to parameterize a single function. We're going to use R's implementation of nonlinear least squares, `nls`, here:

```r
myfitfun <- function(data, p) {
  res <- nls(y~a*x^p, data, start=list(a=1.1))
  list(a=coef(res), GoF=deviance(res))
}
```

Note that `myfitfun` takes a (mandatory) `data` argument which is used to pass the data the models are fit to, and that it returns a list, one of whose elements holds the goodness of fit (`GoF`).

To generate the parametric bootstrap, we need another function that generates synthetic data based on a model parameterization:

```r
mygenfun <- function(model, p) {
  x <- seq(from=0, to=1, length.out=100)
  y <- model$a*x^p + rnorm(100, 0, 0.5)
  data.frame(x=x, y=y)
}
```

This function takes a mandatory `model` argument, which is used to pass around model realizations (the output of the `myfitfun` function).

Now we're set to actually run the bootstrap:

```r
myboot <- pbcm::pbcm.di(data=mockdata, fun1=myfitfun, fun2=myfitfun, genfun1=mygenfun, genfun2=mygenfun, reps=100, args1=list(p=1), args2=list(p=2), genargs1=list(p=1), genargs2=list(p=2))
```

Here, `args1` and `args2` hold arguments passed to `myfitfun`, while `genargs1` and `genargs2` hold arguments passed to `mygenfun`. Let's take a glimpse at the result:

```r
head(myboot)
```

We can easily produce a nice plot of the `DeltaGoF` distributions:

```r
ggplot2::ggplot(myboot, aes(x=DeltaGoF, fill=generator)) + ggplot2::geom_density(alpha=0.5)
```



This is a basic example which shows you how to solve a common problem:


```r
## basic example code
```

What is special about using `README.Rmd` instead of just `README.md`? You can include R chunks like so:


```r
summary(cars)
#>      speed           dist       
#>  Min.   : 4.0   Min.   :  2.00  
#>  1st Qu.:12.0   1st Qu.: 26.00  
#>  Median :15.0   Median : 36.00  
#>  Mean   :15.4   Mean   : 42.98  
#>  3rd Qu.:19.0   3rd Qu.: 56.00  
#>  Max.   :25.0   Max.   :120.00
```

You'll still need to render `README.Rmd` regularly, to keep `README.md` up-to-date.

You can also embed plots, for example:

<img src="man/figures/README-pressure-1.png" title="plot of chunk pressure" alt="plot of chunk pressure" width="100%" />

In that case, don't forget to commit and push the resulting figure files, so they display on GitHub!


## References

Schultheis, H. & Singhaniya, A. (2015) Decision criteria for model comparison using the parametric bootstrap cross-fitting method. *Cognitive Systems Research*, 33, 100–121.

Wagenmakers, E.-J., Ratcliff, R., Gomez, P. & Iverson, G. J. (2004) Assessing model mimicry using the parametric bootstrap. *Journal of Mathematical Psychology*, 48(1), 28–50.
