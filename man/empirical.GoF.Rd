% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/empirical.GoF.R
\name{empirical.GoF}
\alias{empirical.GoF}
\title{Empirical Goodnesses of Fit}
\usage{
empirical.GoF(
  data,
  fun1,
  fun2,
  args1 = NULL,
  args2 = NULL,
  verbose = TRUE,
  GoFname = "GoF"
)
}
\arguments{
\item{data}{Data frame}

\item{fun1}{Modelling function 1}

\item{fun2}{Modelling function 2}

\item{args1}{List of arguments passed to \code{fun1}}

\item{args2}{List of arguments passed to \code{fun2}}

\item{verbose}{If \code{TRUE}, warnings are printed to the console}

\item{GoFname}{Name of the element returned by \code{fun1} and \code{fun2} holding the goodness of fit}
}
\value{
A 1-row data frame of three columns:
\describe{
\item{\code{GoF1}}{Goodness of fit for model 1}
\item{\code{GoF2}}{Goodness of fit for model 2}
\item{\code{DeltaGoF}}{Equal to \code{GoF1 - GoF2}}
}
}
\description{
Fit models 1 and 2 to data and return the empirical goodnesses of fit as well as the difference in goodness of fit.
}
\details{
Functions \code{fun1} and \code{fun2} must accept \code{data} as an argument in addition to any arguments specified in \code{args1} and \code{args2}. They must return a list with an element carrying the calculated goodness of fit; by default the name of this element is taken to be the string \code{"GoF"} but this behaviour can be changed through the \code{GoFname} argument.
}
\examples{
x <- seq(from=0, to=1, length.out=100)
mockdata <- data.frame(x=x, y=x + rnorm(100, 0, 0.5))

myfitfun <- function(data, p) {
  res <- nls(y~a*x^p, data, start=list(a=1.1))
  list(a=coef(res), GoF=deviance(res))
}

empirical.GoF(mockdata, fun1=myfitfun, fun2=myfitfun,
              args1=list(p=1), args2=list(p=2))
}
\author{
Henri Kauhanen
}
