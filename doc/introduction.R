## ----setup, include = FALSE----------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----mockdata------------------------------------------------------------
x <- seq(from=0, to=1, length.out=100)
mockdata <- data.frame(x=x, y=x + rnorm(100, 0, 0.5))
library(ggplot2)
g <- ggplot(mockdata, aes(x=x, y=y)) + geom_point()
print(g)

## ----myfitfun------------------------------------------------------------
myfitfun <- function(data, p) {
  res <- nls(y~a*x^p, data, start=list(a=1.1))
  list(a=coef(res), GoF=deviance(res))
}

## ----mygenfun------------------------------------------------------------
mygenfun <- function(model, p) {
  x <- seq(from=0, to=1, length.out=100)
  y <- model$a*x^p + rnorm(100, 0, 0.5)
  data.frame(x=x, y=y)
}

## ----pbcm, results='hide'------------------------------------------------
myboot <- pbcm::pbcm.di(data=mockdata, fun1=myfitfun, fun2=myfitfun, genfun1=mygenfun, genfun2=mygenfun, reps=100, args1=list(p=1), args2=list(p=2), genargs1=list(p=1), genargs2=list(p=2))

## ----myboot--------------------------------------------------------------
head(myboot)

## ----mybootplot----------------------------------------------------------
g <- ggplot(myboot, aes(x=DeltaGoF, fill=generator)) + geom_density(alpha=0.5)
print(g)

## ----empirical-----------------------------------------------------------
emp <- pbcm::empirical.GoF(mockdata, fun1=myfitfun, fun2=myfitfun, args1=list(p=1), args2=list(p=2))
print(emp)

## ----kNN-----------------------------------------------------------------
pbcm::kNN.classification(df=myboot, DeltaGoF.emp=emp$DeltaGoF, k=10)

## ----kNNmultiple---------------------------------------------------------
pbcm::kNN.classification(df=myboot, DeltaGoF.emp=emp$DeltaGoF, k=c(1, 10, 50, 100))

## ----mygenfun2-----------------------------------------------------------
mygenfun.du <- function(a, p) {
  x <- seq(from=0, to=1, length.out=100)
  y <- a*x^p + rnorm(100, 0, 0.5)
  data.frame(x=x, y=y)
}

## ----pbcm.du, results='hide'---------------------------------------------
myboot <- pbcm::pbcm.du(fun1=myfitfun, fun2=myfitfun, genfun1=mygenfun.du, genfun2=mygenfun.du, reps=100, args1=list(p=1), args2=list(p=2), genargs1=list(a=1.0, p=1), genargs2=list(a=1.0, p=2))
head(myboot)

## ----sweep, results='hide'-----------------------------------------------
sweep <- lapply(X=seq(from=0.5, to=1.5, by=0.1),
                FUN=function(X) {
                  pbcm::pbcm.du(fun1=myfitfun, fun2=myfitfun, genfun1=mygenfun.du, genfun2=mygenfun.du, reps=100, args1=list(p=1), args2=list(p=2), genargs1=list(a=X, p=1), genargs2=list(a=X, p=2))
                })

## ----rbind---------------------------------------------------------------
sweep <- do.call(rbind, sweep)
sweep$parameter <- ifelse(is.na(sweep$model1_a), sweep$model2_a, sweep$model1_a)

## ----sweepvis, out.width='100%'------------------------------------------
g <- ggplot(sweep, aes(x=DeltaGoF, fill=generator)) + geom_density(alpha=0.5) + facet_wrap(.~parameter)
print(g)

