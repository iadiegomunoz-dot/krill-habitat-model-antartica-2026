
library(mgcv)
library(tidyverse)

setwd("C:/Users/munoz/Downloads/antartica para el agente")

# 1. Load Data
cat("Loading Master Dataset...\n")
df <- read.csv("datasets/processed/krill_master_binomial_FINAL.csv")

# Custom AUC function to avoid pROC dependency
auc_simple <- function(labels, scores) {
  n_pos <- sum(labels == 1)
  n_neg <- sum(labels == 0)
  if(n_pos == 0 | n_neg == 0) return(NA)
  ranks <- rank(scores)
  (sum(ranks[labels == 1]) - n_pos * (n_pos + 1) / 2) / (n_pos * n_neg)
}

# 2. Temporal Split (Mandate: Train <= 2012, Validate 2013-2016)
cat("Splitting data into Train and Test sets...\n")
df_train <- df %>% filter(year <= 2012)
df_test  <- df %>% filter(year > 2012)

cat("Train records:", nrow(df_train), "\n")
cat("Test records:", nrow(df_test), "\n")

# 3. Fit Binomial GAM
cat("Fitting Binomial GAM (mgcv)...\n")
# Formula based on PROTOCOLO_MODELO_BINOMIAL.md
model_bin <- gam(presence ~ s(dist_talud, k=10) + 
                   s(pendiente, k=5) + 
                   s(profundidad, k=10) + 
                   s(sst_local, k=10) + 
                   s(ice_anomaly_prev, k=10) + 
                   s(SAM_9m, k=10) + 
                   s(month, bs="cc", k=6) + 
                   s(LATITUDE, LONGITUDE, k=20),
                 data = df_train, 
                 family = binomial(link = "logit"),
                 method = "REML")

# 4. Model Summary
cat("\n--- Model Summary ---\n")
print(summary(model_bin))

# 5. Evaluation
cat("\nEvaluating model on Test set...\n")
df_test$pred_prob <- predict(model_bin, newdata = df_test, type = "response")

# AUC-ROC
test_auc <- auc_simple(df_test$presence, df_test$pred_prob)
cat("Test AUC-ROC:", test_auc, "\n")

# 6. Save Model and Results
cat("Saving model to models/binomial_gam_v1.rds...\n")
if(!dir.exists("models")) dir.create("models")
saveRDS(model_bin, "models/binomial_gam_v1.rds")

# Save predictions for visualization later
write.csv(df_test, "datasets/processed/binomial_predictions_test.csv", row.names = FALSE)

# 7. Basic plots of partial effects
pdf("datasets/processed/gam_partial_effects.pdf")
plot(model_bin, pages=1, all.terms=TRUE, shade=TRUE, main="Partial Effects of Binomial GAM")
dev.off()

cat("\nTraining completed. AUC-ROC achieved:", test_auc, "\n")
