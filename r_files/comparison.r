library(lme4)

d_ns <- read.csv("results/ns_verbs.csv")
# distance is z-scored: z > 1 = raw distance > 3.61 words, i.e. the 100 verbs with distance >= 4
dl <- d_ns[d_ns$distance > 1.0, ]
print(nrow(dl))                     # 8063 rows
print(length(unique(dl$item)))      # 100 verbs

m0l <- lmer(logRT ~ freq + length + freq_prev + length_prev +
            (1 | subject) + (1 | item), data = dl, REML = FALSE)
fit <- function(v) logLik(update(m0l, as.formula(paste0(". ~ . + ", v, " + ", v, "_prev"))))

ll <- c(base = logLik(m0l), full = fit("surp_full"), lam1 = fit("surp_lam1"),
        lam2 = fit("surp_lam2"), lam4 = fit("surp_lam4"), lam8 = fit("surp_lam8"),
        lam16 = fit("surp_lam16"), lam32 = fit("surp_lam32"))
print(ll)
write.csv(data.frame(model = names(ll), loglik = as.numeric(ll), n = nrow(dl)),
          "results/ns_long_loglik.csv", row.names = FALSE)