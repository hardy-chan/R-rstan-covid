
data {
  int<lower=0> N;                            // Total number of sample rows
  array[N] int<lower=1, upper=2> pcr_status; // Group tracking: 1=Neg, 2=Pos
  vector[N] x_abbott;                        // Predictor: Abbott Log10 scores
  vector[N] y_mnt;                           // Outcome: mNT Titer Log10 scores
}

parameters {
  vector[2] alpha;                           // alpha[1] = Neg Intercept, alpha[2] = Pos Intercept
  vector[2] beta;                            // beta[1]  = Neg Slope,     beta[2]  = Pos Slope
  real<lower=0> sigma;                       // Shared residual error variance
}

model {
  // Weakly informative Bayesian priors for group parameters
  alpha ~ normal(0, 5);        
  beta  ~ normal(0, 5);
  sigma ~ exponential(1);
  
  // Vectorized calculation mapping individual slopes/intercepts per row
  // The .* operator performs element-wise multiplication of the vectors
  y_mnt ~ normal(alpha[pcr_status] + beta[pcr_status] .* x_abbott, sigma);
}

