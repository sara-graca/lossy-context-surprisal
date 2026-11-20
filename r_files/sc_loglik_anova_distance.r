library(lme4)
d <- read.csv("results/sc_verbs.csv")
d$condition <- relevel(factor(d$condition), ref = "Baseline")

m0 <- lmer(logRT ~ freq + length + freq_prev + length_prev +
(1 | subject) + (1 | item), data = d, REML = FALSE)
m_dist <- update(m0, . ~ . + distance)
m_full <- update(m0, . ~ . + surp_full + surp_full_prev)
m_lam1 <- update(m0, . ~ . + surp_lam1 + surp_lam1_prev)
m_lam2 <- update(m0, . ~ . + surp_lam2 + surp_lam2_prev)
m_lam4 <- update(m0, . ~ . + surp_lam4 + surp_lam4_prev)
m_lam8 <- update(m0, . ~ . + surp_lam8 + surp_lam8_prev)
m_lam16 <- update(m0, . ~ . + surp_lam16 + surp_lam16_prev)
m_lam32 <- update(m0, . ~ . + surp_lam32 + surp_lam32_prev)

ll <- c(base = logLik(m0), full = logLik(m_full), lam1 = logLik(m_lam1),
        lam2 = logLik(m_lam2), lam4 = logLik(m_lam4), lam8 = logLik(m_lam8),
        lam16 = logLik(m_lam16), lam32 = logLik(m_lam32))
write.csv(data.frame(model = names(ll), loglik = as.numeric(ll), n = nrow(d)),
"results/sc_loglik.csv", row.names = FALSE)

# 4(a): distance effect and its direction
sc_anova <- anova(m0, m_dist)        # likelihood ratio test for distance
print(sc_anova)
sc_distance <- fixef(m_dist)["distance"]   # coefficient of distance
print(sc_distance)

# 4(c): does surprisal explain the distance effect? (lambda_nat = 8)
m_dist_full <- update(m_dist, . ~ . + surp_full + surp_full_prev)
m_dist_lam  <- update(m_dist, . ~ . + surp_lam8 + surp_lam8_prev)

b_none <- fixef(m_dist)["distance"]
b_full <- fixef(m_dist_full)["distance"]
b_lam  <- fixef(m_dist_lam)["distance"]

print(b_none)
print(b_full)
print(b_lam)

# percent shrink compared with the model without surprisal
print(100 * (1 - b_full / b_none))
print(100 * (1 - b_lam / b_none))

# 4(d): which condition coefficients shrink when lossy surprisal is added?
m_cond     <- update(m0, . ~ . + condition)
m_cond_lam <- update(m_cond, . ~ . + surp_lam8 + surp_lam8_prev)

print(fixef(m_cond))
print(fixef(m_cond_lam))

# saved for the plot in the notebook
write.csv(data.frame(term = names(fixef(m_cond)), before = fixef(m_cond),
                     after = fixef(m_cond_lam)[names(fixef(m_cond))]),
          "results/sc_cond_coefs.csv", row.names = FALSE)