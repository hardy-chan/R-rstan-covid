
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

