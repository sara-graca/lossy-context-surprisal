d_ns <- read.csv("results/ns_verbs.csv")
dl <- d_ns[d_ns$distance > 1.0, ]
nrow(dl)

m0l <- lmer(logRT ~ freq + length + freq_prev + length_prev +
            (1 | subject) + (1 | item), data = dl, REML = FALSE)
fit <- function(v) logLik(update(m0l, as.formula(paste(". ~ . +", v, "+", v, "_prev"))))
ll <- c(base = logLik(m0l), full = fit("surp_full"), lam1 = fit("surp_lam1"),
        lam2 = fit("surp_lam2"), lam4 = fit("surp_lam4"), lam8 = fit("surp_lam8"))
write.csv(data.frame(model = names(ll), loglik = ll, n = nrow(dl)),
          "results/ns_long_loglik.csv", row.names = FALSE)