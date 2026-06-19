# ==============================================================================
# 1. INITIALIZE PACKAGES & CONFIGURE EXTRACTED MCMC PARAMETERS
# ==============================================================================
if(!require(ggplot2)) install.packages("ggplot2")
library(ggplot2)

# Extract intercepts and shared slope parameters from your first MCMC model
a1 <- 1.42   # alpha[1]: Baseline for PCR Negative group
a2 <- 2.14   # alpha[2]: Baseline for PCR Positive group
b  <- 0.544  # beta: Shared single global slope for the Abbott test score

# ==============================================================================
# 2. GENERATE AND STYLE POSTERIOR REGRESSION PLOT
# ==============================================================================
p <- ggplot(analysis_data, aes(x = Abbott.S.C.Values..Log10., y = mNT.TITER..Log10., color = PCR.confirmed)) +
  # Add real patient data points with a clean transparency blend
  geom_point(alpha = 0.6, size = 2.5) +
  
  # Draw the custom hierarchical regression line for the Negative Cohort
  geom_abline(intercept = a1, slope = b, color = "#1a365d", linetype = "dashed", linewidth = 1.2) +
  
  # Draw the custom hierarchical regression line for the Positive Cohort
  geom_abline(intercept = a2, slope = b, color = "#c53030", linetype = "solid", linewidth = 1.2) +
  
  # Format professional academic titles and dynamic axis descriptors
  labs(
    title = "Hierarchical Bayesian Posterior Regression Lines",
    subtitle = "Distinct immune baselines (alphas) sharing a unified Abbott test slope (beta)",
    x = "Commercial Abbott Assay Score (Log10 S/C Values)",
    y = "True Biological Neutralization Capacity (Log10 mNT TITER)",
    color = "Clinical PCR Diagnosis"
  ) +
  
  # Style with a clean modern aesthetic tailored for GitHub and publications
  theme_minimal(base_size = 14) +
  # Note: Values map to "Neg" and "Pos" to prevent 'No shared levels' warnings
  scale_color_manual(values = c("Neg" = "#1a365d", "Pos" = "#c53030")) +
  theme(
    plot.title = element_text(face = "bold", size = 16),
    legend.position = "bottom"
  )

# Display the plot in the RStudio plotting window
print(p)

# ==============================================================================
# 3. EXPORT AND SAVE GRAPH TO LOCAL FOLDER
# ==============================================================================
folder_path <- "C:/Users/Hardy/Dropbox/Programming/R-covid-rstan/"
plot_name <- "posterior_regression.png"
plot_path <- file.path(folder_path, plot_name)

ggsave(
  filename = plot_path, 
  plot     = p, 
  width    = 8, 
  height   = 5.5, 
  dpi      = 300
)

print("Plot successfully saved to your folder as 'posterior_regression.png'!")
