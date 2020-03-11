x <- seq(from=0, to=1, length.out=100)
mockdata <- data.frame(x=x, y=x + rnorm(100, 0, 0.5))

myfitfun <- function(data, p) {
  res <- nls(y~a*x^p, data, start=list(a=1.1))
  list(a=coef(res), GoF=deviance(res))
}

mygenfun <- function(model, p) { 
  x <- seq(from=0, to=1, length.out=100)
  y <- model$a*x^p + rnorm(100, 0, 0.5)
  data.frame(x=x, y=y)
}

pbcm.di(data=mockdata, fun1=myfitfun, fun2=myfitfun, genfun1=mygenfun,
        genfun2=mygenfun, reps=20, args1=list(p=1), args2=list(p=2), 
        genargs1=list(p=1), genargs2=list(p=2))
