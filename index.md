# pbcm

pbcm is an R package that implements both data-informed and data-uninformed versions of the Parametric Bootstrap Cross-fitting Method (PBCM; Wagenmakers et al. 2004), a general-purpose technique for binary model selection. Some auxiliary routines, such as decision through *k* nearest neighbours classification (Schultheis & Singhaniya 2015), are also implemented.

## Installation

You can install the current version of pbcm using devtools:

``` r
devtools::install_github("hkauhanen/pbcm")
```

## Help!?

For basic usage notes, consult the vignette [An introduction to pbcm](articles/introduction.html) or the [function reference](reference/index.html) (each function provided by the package is supplied with examples).

## But what *is* this PBCM?

See Wagenmakers et al. (2004).

## I've found a bug

Please file an [issue](https://github.com/hkauhanen/pbcm/issues).

## References

Schultheis, H. & Singhaniya, A. (2015) Decision criteria for model comparison using the parametric bootstrap cross-fitting method. *Cognitive Systems Research*, 33, 100–121.

Wagenmakers, E.-J., Ratcliff, R., Gomez, P. & Iverson, G. J. (2004) Assessing model mimicry using the parametric bootstrap. *Journal of Mathematical Psychology*, 48(1), 28–50.
