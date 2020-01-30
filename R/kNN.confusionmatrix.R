#' Confusion Matrices through k Nearest Neighbours Classification
#'
#' Computes confusion matrices (one for each value of \eqn{k}) using \eqn{k}-NN classification from the results of two parametric bootstraps, one of these being labelled a holdout set and tested against the other one.
#'
#' The function takes each \code{DeltaGoF} value from \code{df.holdout}, compares it against the \code{DeltaGoF} distributions in \code{df}, and decides based on \eqn{k}-NN classification. By convention, we take model 2 as the null hypothesis and model 1 as the alternative. Hence a false positive, for instance, means the situation where model 2 generated the data but the decision was in favour of model 1.
#'
#' @param df Data frame output by \code{\link{pbcm.di}} or \code{\link{pbcm.du}}
#' @param df.holdout Data frame output by \code{\link{pbcm.di}} or \code{\link{pbcm.du}}
#' @param k Number of neighbours to consider in k-NN classification; may be a vector of integers
#' @param ties Which way to break ties in k-NN classification (see \code{\link{kNN.classification}})
#' @param verbose If \code{TRUE}, prints a progress bar and issues warnings
#' @return A data frame with the following columns:
#' \describe{
#' \item{\code{k}}{Number of nearest neighbours}
#' \item{\code{P}}{Number of positives}
#' \item{\code{N}}{Number of negatives}
#' \item{\code{TP}}{Number of true positives}
#' \item{\code{FP}}{Number of false positives}
#' \item{\code{TN}}{Number of true negatives}
#' \item{\code{FN}}{Number of false negatives}
#' \item{\code{alpha}}{Type I error (false positive) rate; equal to \code{FP} divided by \code{N}}
#' \item{\code{beta}}{Type II error (false negative) rate; equal to \code{FN} divided by \code{P}}
#' }
#' In addition to these columns, each argument that was passed via \code{genargs1} and \code{genargs2} to \code{\link{pbcm.di}} or \code{\link{pbcm.du}} to generate \code{df.holdout} is included as a column of its own.
#' @author Henri Kauhanen
#' @seealso \code{\link{kNN.classification}}, \code{\link{pbcm.di}}, \code{\link{pbcm.du}}
#' @example examples/ex.kNN.confusionmatrix.R
#'
#' @export
kNN.confusionmatrix <- function(df,
                                df.holdout,
                                k,
                                ties = "model2",
                                verbose = TRUE) {
  # positive and negative cases
  positives <- df.holdout[df.holdout$generator=="model1" & !is.na(df.holdout$DeltaGoF), ]
  negatives <- df.holdout[df.holdout$generator=="model2" & !is.na(df.holdout$DeltaGoF), ]
  T_positives <- nrow(positives)
  T_negatives <- nrow(negatives)

  # total numbers of values in non-holdout distributions
  T_model1 <- nrow(df[df$generator=="model1" & !is.na(df$DeltaGoF), ])
  T_model2 <- nrow(df[df$generator=="model2" & !is.na(df$DeltaGoF), ])

  # collect results here
  out <- expand.grid(k=k, P=T_positives, N=T_negatives, TP=NA, FP=NA, TN=NA, FN=NA, alpha=NA, beta=NA)

  for (i in 1:nrow(out)) {
    # If k is larger than the numbers of DeltaGoF values in the distributions,
    # classification cannot occur for such k. Test for this first, and only
    # proceed if k is small enough.
    this_k <- out[i,]$k
    if (this_k > T_model1 | this_k > T_model2) {
      if (verbose) warning(paste0("Cannot classify for k = ", this_k, " (not enough values in bootstrap distributions)"))
    } else {
      # get true positives and false negatives
      TP <- 0
      for (j in 1:T_positives) {
        if (kNN.classification(df=df, DeltaGoF.emp=positives[j,]$DeltaGoF, k=this_k, verbose=verbose, ties=ties)$decision == "model1") TP <- TP + 1
      }
      FN <- T_positives - TP

      # get true negatives and false positives
      TN <- 0
      for (j in 1:T_negatives) {
        if (kNN.classification(df=df, DeltaGoF.emp=negatives[j,]$DeltaGoF, k=this_k, verbose=verbose, ties=ties)$decision == "model2") TN <- TN + 1
      }
      FP <- T_negatives - TN

      # push to out
      out[i,]$TP <- TP
      out[i,]$FN <- FN
      out[i,]$TN <- TN
      out[i,]$FP <- FP
      out[i,]$alpha <- FP/T_negatives
      out[i,]$beta <- FN/T_positives
    }
  }

  if (1==0) {
  # add genargs to out frame
  genargs2 <- names(df.holdout)[grep(names(df.holdout), pattern="^model2_")]
  genargs1 <- names(df.holdout)[grep(names(df.holdout), pattern="^model1_")]
  if (length(genargs2) != 0) {
    for (i in length(genargs2):1) {
      argval <- unique(df.holdout[[genargs2[[i]]]])
      argval <- argval[!is.na(argval)]
      out <- cbind(rep(argval, nrow(out)), out)
      names(out)[1] <- genargs2[i]
    }
  }
  if (length(genargs1) != 0) {
    for (i in length(genargs1):1) {
      argval <- unique(df.holdout[[genargs1[[i]]]])
      argval <- argval[!is.na(argval)]
      out <- cbind(rep(argval, nrow(out)), out)
      names(out)[1] <- genargs1[i]
    }
  }
  }

  # return
  out
}
