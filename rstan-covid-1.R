library(readr)
library(rstan)
library(cmdstanr)

# Read data csv
folder_path <- "C:/Users/Hardy/Dropbox/Programming/R-covid-rstan/"
file_name <- "data.csv"
data_path <- file.path(folder_path, file_name)
cdc_data <- read_csv(data_path)

# Clean names, percentage signs, NA values
names(cdc_data) <- make.names(names(cdc_data))
analysis_data <- na.omit(cdc_data[, c(
  "PCR.confirmed", "sVNT...Inhibition", "mNT.TITER..Log10.", 
  "Abbott.S.C.Values..Log10.", "Ortho.Index.Values..Log10."
)])
clean_text <- gsub("[^0-9.]", "", analysis_data$sVNT...Inhibition)
analysis_data$sVNT_proportion <- as.numeric(clean_text) / 100

# Create the mandatory structured list for RStan
stan_data_list <- list(
  # Sample Size 
  N = nrow(analysis_data), 
  
  # Main Continuous Target Outcomes
  y_mnt  = analysis_data$mNT.TITER..Log10.,
  y_svnt = analysis_data$sVNT_proportion,
  
  # Continuous Commercial Assays (Predictors)
  x_abbott = analysis_data$Abbott.S.C.Values..Log10.,
  x_ortho  = analysis_data$Ortho.Index.Values..Log10.,
  
  # Categorical Grouping Variables (Converted from Text to Integers 1 for Neg and 2 for Pos)
  pcr_status = as.integer(as.factor(analysis_data$PCR.confirmed))
)

# Verify the final structure is an R List
str(stan_data_list)


# Stan code
hierarchical_stan_code <- "
data {
  int<lower=0> N;              // 204
  array[N] int<lower=1, upper=2> pcr_status; // 1=Neg, 2=Pos
  vector[N] x_abbott;          // Predictor: Abbott Log10 scores
  vector[N] y_mnt;             // Outcome: mNT Titer Log10 scores
}

parameters {
  vector[2] alpha;             // 2 intercepts: alpha[1] for Neg, alpha[2] for Pos
  real beta;                   // Global slope for Abbott scores
  real<lower=0> sigma;         // Error variance
}

model {
  // Bayesian Priors
  alpha ~ normal(0, 5);        // Soft priors for both baseline groups
  beta ~ normal(0, 5);
  sigma ~ exponential(1);
  
  // Likelihood using vectorised group indexing
  for (i in 1:N) {
    y_mnt[i] ~ normal(alpha[pcr_status[i]] + beta * x_abbott[i], sigma);
  }
}
"

# Save the updated multi-level code to your disk
stan_path <- file.path(folder_path, "hierarchical_antibody_model.stan")
writeLines(hierarchical_stan_code, stan_path)
print("File 'hierarchical_antibody_model.stan' has been created successfully!")


# cmdstanr codes
model <- cmdstan_model(stan_path, force_recompile = TRUE)

# Run the Bayesian MCMC sampling
fit_cmdstan <- model$sample(
  data = stan_data_list,
  chains = 4,
  parallel_chains = 2,
  iter_warmup = 1000,
  iter_sampling = 1000
)

# Print the final hierarchical parameters
print(fit_cmdstan$summary(c("alpha[1]", "alpha[2]", "beta", "sigma")))

