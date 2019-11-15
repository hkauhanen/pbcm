#' Data-informed Parametric Bootstrap Cross-fitting
#'
#' The data-informed Parametric Bootstrap Cross-fitting Method (PBCM) generates synthetic data from two models of a phenomenon parameterized by fits to an empirical dataset, and then cross-fits the models to these data. The result is two distributions of the goodness of fit metric DeltaGoF = GoF1 - GoF2, where GoF1 is the fit of model 1 and GoF2 the fit of model 2.
#'
#' Functions \code{fun1} and \code{fun2} must take \code{data} as an argument in addition to any arguments specified in \code{args1} and \code{args2}. \code{fun1} and \code{fun2} must return a list with at least one element carrying the goodness of fit; the name of this element may be specified through the \code{GoFname} argument, by default "GoF" is assumed. Functions \code{genfun1} and \code{genfun2} must take an argument named \code{model} (the output of \code{fun1} and \code{fun2}).
#'
#' @param data Data frame
#' @param fun1 First modelling function
#' @param fun2 Second modelling function
#' @param genfun1 Generator function for first model
#' @param genfun2 Generator function for second model
#' @param reps Number of Monte Carlo repetitions
#' @param args1 List of arguments passed to \code{fun1}
#' @param args2 List of arguments passed to \code{fun2}
#' @param genargs1 List of arguments passed to \code{genfun1}
#' @param genargs2 List of arguments passed to \code{genfun2}
#' @param nonparametric_bootstrap Whether \code{data} should be nonparametrically bootstrapped before the parametric bootstrap
#' @param verbose If \code{TRUE}, a progress bar is printed to the console and warnings are issued
#' @param GoFname Name of the element returned by \code{fun1} and \code{fun2} holding the goodness of fit; see Details
#' @return A data frame in long format with the following columns:
#' \describe{
#' \item{\code{rep}}{Monte Carlo repetition number}
#' \item{\code{generator}}{Generating model}
#' \item{\code{GoF1}}{Goodness of fit of model 1}
#' \item{\code{GoF2}}{Goodness of fit of model 2}
#' \item{\code{DeltaGoF}}{Equals GoF1 - GoF2}
#' }
#' In addition to these columns, each argument in the lists \code{genargs1} and \code{genargs2} is included as a column of its own, with the argument's name prefixed by "model1_" or "model2_".
#'
#' @references Wagenmakers, E.-J., Ratcliff, R., Gomez, P. & Iverson, G. J. (2004) Assessing model mimicry using the parametric bootstrap. \emph{Journal of Mathematical Psychology}, 48(1), 28-50.
#' @author Henri Kauhanen
#'
#' @importFrom utils setTxtProgressBar txtProgressBar
#' @export
pbcm.di <- function(data,
                    fun1,
                    fun2,
                    genfun1,
                    genfun2,
                    reps,
                    args1 = NULL,
                    args2 = NULL,
                    genargs1 = NULL,
                    genargs2 = NULL,
                    nonparametric_bootstrap = TRUE,
                    verbose = TRUE,
                    GoFname = "GoF") {
  original_data <- data

  if (verbose) {
    cat("Initializing output data frame...")
  }

  # output is stored in this dataframe
  out <- make_pbcm_output_df(reps=reps, genargs1=genargs1, genargs2=genargs2)
  if (verbose) {
    cat("\nBootstrapping...\n")
    pb <- txtProgressBar(max=reps, style=3)
  }

  # loop
  for (rep in 1:reps) {
    # nonparametric bootstrap (if requested)
    if (nonparametric_bootstrap) {
      data <- original_data[sample(1:nrow(original_data), size=nrow(original_data), replace=TRUE), ]
    } else {
      data <- original_data
    }

    # fit model 1 to data
    fun1_to_data <- tryCatch({
      argshere <- args1
      argshere$data <- data
      do.call(what=fun1, args=argshere)
    }, error=function(cond) {
      if (verbose) warning("Fitting model 1 to data failed")
      return(NULL)
    })

    # fit model 2 to data
    fun2_to_data <- tryCatch({
      argshere <- args2
      argshere$data <- data
      do.call(what=fun2, args=argshere)
    }, error=function(cond) {
      if (verbose) warning("Fitting model 2 to data failed")
      return(NULL)
    })

    # if these fits were okay, proceed
    if (!is.null(fun1_to_data) & !is.null(fun2_to_data)) {
      # generate synthetic data (parametric bootstrap) from genfun1
      data_on_fun1 <- tryCatch({
        argshere <- genargs1
        argshere$model <- fun1_to_data
        do.call(what=genfun1, args=argshere)
      }, error=function(cond) {
        if (verbose) warning("Generation from genfun1 failed")
        return(NULL)
      })

      # generate synthetic data (parametric bootstrap) from genfun2
      data_on_fun2 <- tryCatch({
        argshere <- genargs2
        argshere$model <- fun2_to_data
        do.call(what=genfun2, args=argshere)
      }, error=function(cond) {
        if (verbose) warning("Generation from genfun2 failed")
        return(NULL)
      })

      # (try to) cross-fit
      if (!is.null(data_on_fun1) & !is.null(data_on_fun2)) {
        # fun1 to fun1
        fun1_to_fun1 <- tryCatch({
          argshere <- args1
          argshere$data <- data_on_fun1
          do.call(what=fun1, args=argshere)
        }, error=function(cond) {
          if (verbose) warning("Fitting fun1 to fun1 failed")
          return(NULL)
        })

        # fun1 to fun2
        fun1_to_fun2 <- tryCatch({
          argshere <- args1
          argshere$data <- data_on_fun2
          do.call(what=fun1, args=argshere)
        }, error=function(cond) {
          if (verbose) warning("Fitting fun1 to fun2 failed")
          return(NULL)
        })

        # fun2 to fun1
        fun2_to_fun1 <- tryCatch({
          argshere <- args2
          argshere$data <- data_on_fun1
          do.call(what=fun2, args=argshere)
        }, error=function(cond) {
          if (verbose) warning("Fitting fun2 to fun1 failed")
          return(NULL)
        })

        # fun2 to fun2
        fun2_to_fun2 <- tryCatch({
          argshere <- args2
          argshere$data <- data_on_fun2
          do.call(what=fun2, args=argshere)
        }, error=function(cond) {
          if (verbose) warning("Fitting fun2 to fun2 failed")
          return(NULL)
        })

        # push results to out dataframe
        if (!is.null(fun1_to_fun1) & !is.null(fun2_to_fun1)) {
          out[out$rep==rep & out$generator=="model1", ]$GoF1 <- fun1_to_fun1[[GoFname]]
          out[out$rep==rep & out$generator=="model1", ]$GoF2 <- fun2_to_fun1[[GoFname]]
          out[out$rep==rep & out$generator=="model1", ]$DeltaGoF <- fun1_to_fun1[[GoFname]] - fun2_to_fun1[[GoFname]]
        }
        if (!is.null(fun1_to_fun2) & !is.null(fun2_to_fun2)) {
          out[out$rep==rep & out$generator=="model2", ]$GoF1 <- fun1_to_fun2[[GoFname]]
          out[out$rep==rep & out$generator=="model2", ]$GoF2 <- fun2_to_fun2[[GoFname]]
          out[out$rep==rep & out$generator=="model2", ]$DeltaGoF <- fun1_to_fun2[[GoFname]] - fun2_to_fun2[[GoFname]]
        }
      }
    }

    if (verbose) {
      setTxtProgressBar(pb, rep)
    }
  }

  # return
  if (verbose) {
    close(pb)
  }
  out
}
