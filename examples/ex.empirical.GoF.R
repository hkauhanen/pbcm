x <- seq(from=0, to=1, length.out=100)
mockdata <- data.frame(x=x, y=x + rnorm(100, 0, 0.5))

myfitfun <- function(data, p) {
  res <- nls(y~a*x^p, data, start=list(a=1.1))
  list(a=coef(res), GoF=deviance(res))
}

empirical.GoF(mockdata, fun1=myfitfun, fun2=myfitfun,
              args1=list(p=1), args2=list(p=2))
