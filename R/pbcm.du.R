#' Data-uninformed Parametric Bootstrap Cross-fitting
#'
#' description
#'
#' details
#'
#' @param fun1 First modelling function
#' @param fun2 Second modelling function
#' @param genfun1 Generator function for first model
#' @param genfun2 Generator function for second model
#' @param genargs1 List of arguments passed to first generator function
#' @param genargs2 List of arguments passed to second generator function
#' @param reps Number of Monte Carlo repetitions
#' @param GOF FIXME
#' @param progressbar Whether a (text) progress bar ought to be printed
#' @return FIXME
#'
#' @importFrom utils setTxtProgressBar txtProgressBar
#' @export
pbcm.du <- function(fun1,
		    fun2,
		    genfun1,
		    genfun2,
		    genargs1,
		    genargs2,
		    reps,
		    GOF = "RSS",
		    progressbar = TRUE) {
	if (progressbar) {
		cat("Initializing output data frame...")
	}

	# output is stored in this dataframe
	out1 <- data.frame(rep=1:reps, generator="fun1", GOF1=NA, GOF2=NA, DeltaGOF=NA)
	out2 <- out1
	if (length(genargs2) != 0) {
		for (i in length(genargs2):1) {
			out1 <- cbind(rep(NA, nrow(out1)), out1)
			names(out1)[1] <- paste0("fun2_", names(genargs2)[i])
		}
	}
	if (length(genargs1) != 0) {
		for (i in length(genargs1):1) {
			out1 <- cbind(rep(genargs1[[i]], nrow(out1)), out1)
			names(out1)[1] <- paste0("fun1_", names(genargs1)[i])
		}
	}
	if (length(genargs2) != 0) {
		for (i in length(genargs2):1) {
			out2 <- cbind(rep(genargs2[[i]], nrow(out2)), out2)
			names(out2)[1] <- paste0("fun2_", names(genargs2)[i])
		}
	}
	if (length(genargs1) != 0) {
		for (i in length(genargs1):1) {
			out2 <- cbind(rep(NA, nrow(out2)), out2)
			names(out2)[1] <- paste0("fun1_", names(genargs1)[i])
		}
	}
	out <- rbind(out1, out2)
	if (progressbar) {
		cat("\n")
		pb <- txtProgressBar(max=reps, style=3)
	}

	# loop
	for (rep in 1:reps) {
		if (progressbar) {
			setTxtProgressBar(pb, rep)
		}
	}

	# return
	close(pb)
	out
}
