#' Empirical Goodnesses of Fit
#'
#' Fit models 1 and 2 to data and return the empirical goodnesses of fit as well as the difference in goodness of fit.
#'
#' Functions \code{fun1} and \code{fun2} must accept \code{data} as an argument in addition to any arguments specified in \code{args1} and \code{args2}. They must return a list with an element carrying the calculated goodness of fit; by default the name of this element is taken to be the string \code{"GoF"} but this behaviour can be changed through the \code{GoFname} argument.
#'
#' @param data Data frame
#' @param fun1 Modelling function 1
#' @param fun2 Modelling function 2
#' @param args1 List of arguments passed to \code{fun1}
#' @param args2 List of arguments passed to \code{fun2}
#' @param verbose If \code{TRUE}, warnings are printed to the console
#' @param GoFname Name of the element returned by \code{fun1} and \code{fun2} holding the goodness of fit
#' @return A 1-row data frame of three columns:
#' \describe{
#' \item{\code{GoF1}}{Goodness of fit for model 1}
#' \item{\code{GoF2}}{Goodness of fit for model 2}
#' \item{\code{DeltaGoF}}{Equal to \code{GoF1 - GoF2}}
#' }
#' @author Henri Kauhanen
#' @example examples/ex.empirical.GoF.R
#'
#' @export
empirical.GoF <- function(data,
                          fun1,
                          fun2,
                          args1 = NULL,
                          args2 = NULL,
                          verbose = TRUE,
                          GoFname = "GoF") {
  # fit fun1 to data
  fun1_to_data <- tryCatch({
    argshere <- args1
    argshere$data <- data
    do.call(what=fun1, args=argshere)
  }, error=function(cond) { 
    if (verbose) warning("Fitting fun1 to data failed: ", cond)
    return(NULL)
  })

  # fit fun2 to data
  fun2_to_data <- tryCatch({
    argshere <- args2
    argshere$data <- data
    do.call(what=fun2, args=argshere)
  }, error=function(cond) { 
    if (verbose) warning("Fitting fun2 to data failed: ", cond)
    return(NULL)
  })

  # check fits ok; recover GoFs
  ret <- data.frame(GoF1=NA, GoF2=NA, DeltaGoF=NA)
  if (!is.null(fun1_to_data) & !is.null(fun2_to_data)) {
    ret$GoF1 <- fun1_to_data[[GoFname]]
    ret$GoF2 <- fun2_to_data[[GoFname]]
    ret$DeltaGoF <- fun1_to_data[[GoFname]] - fun2_to_data[[GoFname]]
  }

  # return
  ret
}
