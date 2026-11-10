library(lme4)
d <- read.csv("results/sc_verbs.csv")
m0 <- lmer(logRT ~ freq + length + freq_prev + length_prev +
(1 | subject) + (1 | item), data = d, REML = FALSE)
m_dist <- update(m0, . ~ . + distance)
m_full <- update(m0, . ~ . + surp_full + surp_full_prev)
m_lam1 <- update(m0, . ~ . + surp_lam1 + surp_lam1_prev)
m_lam2 <- update(m0, . ~ . + surp_lam2 + surp_lam2_prev)
m_lam4 <- update(m0, . ~ . + surp_lam4 + surp_lam4_prev)
m_lam8 <- update(m0, . ~ . + surp_lam8 + surp_lam8_prev)
anova(m0, m_dist) # likelihood ratio test for distance
fixef(m_dist)["distance"] # coefficient of distance
ll <- c(base = logLik(m0), full = logLik(m_full), lam1 = logLik(m_lam1),
lam2 = logLik(m_lam2), lam4 = logLik(m_lam4), lam8 = logLik(m_lam8))
write.csv(data.frame(model = names(ll), loglik = ll, n = nrow(d)),
"sc_loglik.csv", row.names = FALSE)

sc_anova <- anova(m0, m_dist) 
print(sc_anova)
sc_distance <- fixef(m_dist)["distance"]
print(sc_distance)