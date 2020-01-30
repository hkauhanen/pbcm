x <- seq(from=0, to=1, length.out=100)
mockdata <- data.frame(x=x, y=x + rnorm(100, 0, 0.5))

myfitfun <- function(data, p) {
  res <- nls(y~a*x^p, data, start=list(a=1.1))
  list(a=coef(res), GoF=deviance(res))
}

mygenfun <- function(a, p) { 
  x <- seq(from=0, to=1, length.out=100)
  y <- a*x^p + rnorm(100, 0, 0.5)
  data.frame(x=x, y=y)
}

pbcm.du(fun1=myfitfun, fun2=myfitfun, genfun1=mygenfun, genfun2=mygenfun, 
        reps=20, args1=list(p=1), args2=list(p=2), 
        genargs1=list(a=1.1, p=1), genargs2=list(a=1.1, p=2))

sweep <- lapply(X=seq(from=0.5, to=1.5, by=0.1),
                FUN=function(X) {
                  pbcm.du(fun1=myfitfun, fun2=myfitfun, genfun1=mygenfun,
                          genfun2=mygenfun, reps=20,
                          args1=list(p=1), args2=list(p=2), 
                          genargs1=list(a=X, p=1), genargs2=list(a=X, p=2))
                })

sweep <- do.call(rbind, sweep)

sweep$parameter <- ifelse(is.na(sweep$model1_a), sweep$model2_a, sweep$model1_a)

\dontrun{
  library(ggplot2)
  g <- ggplot(sweep, aes(x=DeltaGoF, fill=generator)) + geom_density(alpha=0.5) 
  g <- g + facet_wrap(.~parameter)
  print(g)
}
