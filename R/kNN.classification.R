#' k Nearest Neighbours Classification
#'
#' Carry out k Nearest Neighbours (k-NN) classification on the results of a parametric boostrap.
#'
#' Calculated the cumulative distance (sum of squared differences) of \code{DeltaGoF.emp} to both \code{DeltaGoF} distributions found in \code{df} (i.e. one with model 1 as generator and one with model 2 as generator), taking into account the \code{k} nearest neighbours only. Decides in favour of model 1 if this cumulative distance to the model 1 distribution is smaller than than the distance to model 2, and vice versa. If distances are equal, decision is made according to the \code{ties} argument.
#'
#' @param df Results of bootstrap; the output of \code{\link{pbcm.di}} or \code{\link{pbcm.du}}
#' @param DeltaGoF.emp Empirical value of goodness of fit (e.g. from \code{\link{empirical.GoF}})
#' @param k Number of neighbours to employ in classification; may be a vector of integers
#' @param ties Which way should ties (when distance to the two distributions is equal) be broken? By default, we break in favour of model 2, taking this to be the null model in the comparison.
#' @param verbose If \code{TRUE}, warnings are issued to the console
#' @return A data frame containing the computed distances and decisions, one row per each value of \code{k}
#' @seealso \code{\link{empirical.GoF}}, \code{\link{pbcm.di}}, \code{\link{pbcm.du}}
#' @author Henri Kauhanen
#' @references Schultheis, H. & Singhaniya, A. (2015) Decision criteria for model comparison using the parametric bootstrap cross-fitting method. \emph{Cognitive Systems Research}, 33, 100-121.
#'
#' @export
kNN.classification <- function(df,
                               DeltaGoF.emp,
                               k,
                               ties = "model2",
                               verbose = TRUE) {
  # collect output in this data frame
  out <- expand.grid(k=k, dist_model1=NA, dist_model2=NA, decision=NA)

  # return immediately with NA data frame if any argument is unsuitable
  if (is.null(df) | is.na(DeltaGoF.emp)) {
    if (verbose) warning("k-NN classification failed - empty df or DeltaGoF.emp argument")
    return(out)
  }
  else if (k < 1) {
    if (verbose) warning("Value of k must be a positive integer")
    return(out)
  }

  # get distances from DeltaGoF.emp to bootstrapped DeltaGoFs in 'df'
  df$dist <- (df$DeltaGoF - DeltaGoF.emp)^2
  df_fun1 <- df[df$generator=="model1", ]
  df_fun2 <- df[df$generator=="model2", ]
  df_fun1 <- df_fun1[order(df_fun1$dist, decreasing=FALSE), ]
  df_fun2 <- df_fun2[order(df_fun2$dist, decreasing=FALSE), ]
  N1 <- sum(!is.na(df_fun1$DeltaGoF))
  N2 <- sum(!is.na(df_fun2$DeltaGoF))

  # classify for each value of k
  for (i in 1:nrow(out)) {
    # can only classify if k isn't too large
    if (out[i,]$k <= N1 & out[i,]$k <= N2) {
      d1 <- sum(df_fun1[1:out[i,]$k, ]$dist)
      d2 <- sum(df_fun2[1:out[i,]$k, ]$dist)
      out[i,]$dist_model1 <- d1
      out[i,]$dist_model2 <- d2
      if (d1 < d2) {
        out[i,]$decision <- "model1"
      } else if (d1 > d2) {
        out[i,]$decision <- "model2"
      } else {
        out[i,]$decision <- ties
      }
    }
  }

  # return
  out
}
