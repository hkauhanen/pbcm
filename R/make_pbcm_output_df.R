make_pbcm_output_df <- function(reps,
                                genargs1,
                                genargs2) {
  out1 <- data.frame(rep=1:reps, generator="model1", GoF1=NA, GoF2=NA, DeltaGoF=NA)
  out2 <- data.frame(rep=1:reps, generator="model2", GoF1=NA, GoF2=NA, DeltaGoF=NA)

  if (length(genargs2) != 0) {
    for (i in length(genargs2):1) {
      out1 <- cbind(rep(NA, nrow(out1)), out1)
      names(out1)[1] <- paste0("model2_", names(genargs2)[i])
    }
  }

  if (length(genargs1) != 0) {
    for (i in length(genargs1):1) {
      out1 <- cbind(rep(genargs1[[i]], nrow(out1)), out1)
      names(out1)[1] <- paste0("model1_", names(genargs1)[i])
    }
  }

  if (length(genargs2) != 0) {
    for (i in length(genargs2):1) {
      out2 <- cbind(rep(genargs2[[i]], nrow(out2)), out2)
      names(out2)[1] <- paste0("model2_", names(genargs2)[i])
    }
  }

  if (length(genargs1) != 0) {
    for (i in length(genargs1):1) {
      out2 <- cbind(rep(NA, nrow(out2)), out2)
      names(out2)[1] <- paste0("model1_", names(genargs1)[i])
    }
  }

  rbind(out1, out2)
}
