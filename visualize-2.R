library(ggplot2)
library(dplyr)
library(tidybayes)
library(tidyr)

# Safety Filter: Re-verify that pcr_numeric exists and filter out incomplete cases
#analysis_data <- analysis_data %>%
#  filter(PCR.confirmed %in% c("Neg", "Pos")) %>%
#  mutate(pcr_numeric = if_else(PCR.confirmed == "Pos", 2, 1)) %>%
#  filter(!is.na(Abbott.S.C.Values..Log10.), !is.na(mNT.TITER..Log10.))

# Print data row count to verify it is not empty
print(paste("Rows available for plotting:", nrow(analysis_data)))

# Safe Global Grid Generation
# This generates a shared x-axis range, preventing 'Inf' or empty groups from crashing seq()
x_range <- seq(
  min(analysis_data$Abbott.S.C.Values..Log10., na.rm = TRUE), 
  max(analysis_data$Abbott.S.C.Values..Log10., na.rm = TRUE), 
  length.out = 100
)

# Combine the x range with both explicit categorical groups
plot_grid <- expand.grid(
  x_abbott = x_range,
  pcr_numeric = c(1, 2)
) %>%
  mutate(
    PCR.confirmed = if_else(pcr_numeric == 2, "Pos", "Neg")
  )

# Extract draws and calculate the predictions across the grid
predicted_curves <- fit_cmdstan$draws(c("alpha", "beta"), format = "draws_df") %>%
  spread_draws(alpha[pcr_group], beta[pcr_group]) %>%
  inner_join(plot_grid, by = c("pcr_group" = "pcr_numeric")) %>%
  mutate(y_predicted = alpha + beta * x_abbott)

# Render the final plot
ggplot(data = analysis_data, aes(x = Abbott.S.C.Values..Log10., y = mNT.TITER..Log10., color = PCR.confirmed)) +
  # Draw raw data points
  geom_point(alpha = 0.5, size = 2) +
  
  # Calculate and plot the 95% Bayesian credible ribbon + median line
  stat_lineribbon(
    data = predicted_curves, 
    aes(x = x_abbott, y = y_predicted, fill = PCR.confirmed),
    .width = c(0.95), 
    alpha = 0.35
  ) +
  
  # Aesthetics and labeling
  scale_color_manual(values = c("Neg" = "#2c3e50", "Pos" = "#e74c3c")) +
  scale_fill_manual(values = c("Neg" = "#b2bec3", "Pos" = "#fab1a0")) +
  labs(
    title = "Bayesian Two-Slope Linear Regression",
    subtitle = "Relationship between Abbott Commercial Scores and mNT Titers",
    x = "Abbott S/C Values (Log10)",
    y = "mNT Titer (Log10)",
    color = "PCR Status",
    fill = "95% Credible Interval"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    legend.position = "bottom",
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  )

# Save the plot with optimized print dimensions and high resolution (300 DPI)
folder_path <- "C:/Users/Hardy/Dropbox/Programming/R-covid-rstan/"
image_name <- "two-slope-linear-regression.png"
output_image_path <- file.path(folder_path, image_name)
ggsave(
  filename = output_image_path,
  plot     = last_plot(), # Automatically selects the last displayed ggplot graph
  device   = "png",
  width    = 10,          # Width in inches
  height   = 6,           # Height in inches
  dpi      = 300          # High-definition resolution for reports or publications
)
print(paste("Image saved at", output_image_path))
