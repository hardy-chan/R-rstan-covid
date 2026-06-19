# Bayesian Serology Evaluation: A Human-AI Learning Project

This repository serves as a self-directed learning exercise focused on Bayesian data analysis, probabilistic programming with **Stan (`cmdstanr`)**, and advanced data visualization in **R**. 

The code pipeline and statistical models were designed, debugged, and optimized through a collaborative interaction between myself and an AI assistant.

---

## Final Model Visualization

Below is the output of our two-slope linear regression evaluating the relationship between Abbott commercial scores and reference micro-neutralization (mNT) titers (modeled in [`rstan-covid-2.R`](./rstan-covid-2.R) and plotted in [`visualize-2.R`](./visualize-2.R)).


<img width="3000" height="1800" alt="two-slope-linear-regression" src="https://github.com/user-attachments/assets/241ffc1f-d0d8-4238-ba9a-023b4ab1cd14" />

### What this Plot Shows

* **The Lines:** These show the average trend for each group. The dark line shows what happens with the healthy group (Negative), and the red line shows what happens with the infected group (Positive). 
* **The Shaded Ribbons:** This is the model's "95% confidence zone." The narrower the band, the more confident the model is about where the average trend line truly sits. It shows our uncertainty about the average line itself, not the spread of individual patient dots.
* **The Flat Baseline:** The Negative group forms a perfect flat line at 1.0. This happens because the laboratory equipment has a "limit of detection." It cannot read a score lower than 1.0, so any zero or ultra-low result gets automatically rounded up to 1.0.

---

## What I Learned About The Bayesian Data Science Workflow

Through building this project, I learned the end-to-end process of translating raw observational data into a fully realized Bayesian statistical model:

* **File Management & Reproducibility:** Programmatically building paths via `file.path()` and handling file input/output using `read_csv()` and `writeLines()`.
* **Data Cleansing:** Sanitizing column strings with `make.names()`, filtering row omissions using `na.omit()`, extracting proportions from text in % with `gsub()`.
* **Data Typings for Stan:** Mapping factor characters to exact numeric sequences (`as.integer(as.factor(...))`) and packing parameters into an R list matrix container.
* **Stan Model Development:** Declaring separate data inputs, parameters, and model distributions across a standard native `.stan` layout.
* **Prior Allocation:** Assigning weakly informative regularizing bounds (`normal(0, 5)` and `exponential(1)`) to establish baseline model shapes.
* **Vectorized Computations:** Speeding up MCMC calculations via vectorized element-wise multiplication arrays (`beta[pcr_status] .* x_abbott`) to entirely eliminate loop delays.
* **MCMC Inference Engines:** Directing the No-U-Turn sampler via `cmdstan_model()` and controlling active parameter arguments like warmup stages, seeds, and parallel chains.
* **Visualizing Results:** Drawing median lines and 95% Bayesian credible intervals overlaying the raw data using `ggplot2`, `stat_lineribbon()`, and exporting high-resolution assets with `ggsave()`.

---

## What I Learned About Real-World Immunology Data

This project helped me understand the difference between commercial and laboratory testing methods, and why they require completely different data handling steps before you can model them.

### The Two Types of Tests

1. **Binding Tests (Abbott & Ortho):** These are rapid, automated machine tests used for screening large populations. They simply count how many antibodies are present in the blood sample that stick to the virus, but they don't test how strong they are.
2. **Neutralization Tests (mNT & sVNT):** These are specialized laboratory tests. They don't just count the antibodies; they actually test if those antibodies are functional and strong enough to actively block and defeat the virus.

### How the Data Scales (And Why)

1. **Log10 Scaling (Abbott, Ortho, and mNT):** These metrics track antibody concentrations and serum dilutions (like diluting a sample by halves: 1:10, 1:20, 1:40). Because these biological numbers grow exponentially, taking the Log10 is necessary to flatten curved lines into straight diagonals, making standard linear regression possible.
2. **Percentage Scaling (sVNT):** This test measures the *percentage of viral inhibition* (how much of the virus was successfully blocked). Because percentages naturally stop between 0% and 100%, the data is bounded as a decimal proportion between `0.0` and `1.0` and does not need a log scale.

---

## What I Learned From A Previous Shared-Slope Error

In the first stage of this learning project (modeled in [`rstan-covid-1.R`](./rstan-covid-1.R) and plotted in [`visualize-1.R`](./visualize-1.R)), I built a baseline model using a **single global slope (one shared angle)** for both lines. In the first stage of this learning project, I built a baseline **Hierarchical model with a single global slope ($\beta$)**, and the result is visualized as follows:

<img width="2400" height="1650" alt="posterior_regression" src="https://github.com/user-attachments/assets/be8b8420-0c1a-4304-acdb-e70b5141283b" />

### Why a shared slope at first?
* It seemed reasonable to assume that the Abbott machine test would track immune changes at the **exact same rate for everyone**, whether they were healthy or sick. 

### The apparent mistake
* **The Healthy Group (Dashed Blue Line):** The blue dots form a perfect flat line at the bottom. But this model forced the dashed blue line to tilt upward into empty space where there are no dots.

### The wall (limit of detection) and the rounding-up
* The **mNT** score does not read below 10. Less than 10 is treated as 10 in the data.

### The fix
* The Stan code is updated to calculate **two different angles** (`beta[pcr_status]`). This allowed the blue line to stay perfectly flat on the floor, and allowed the red line to climb steeply to accurately match the real data.

---

## Project Stack
* **Language:** R (v4.6.0)
* **Probabilistic Engine:** CmdStanR / Stan
* **Key Packages:** `cmdstanr`, `ggplot2`, `dplyr`, `tidybayes`, `readr`

---

## The dataset
Downloaded from CDC at https://data.cdc.gov/Coronavirus-and-Other-Respiratory-Viruses/Examination-of-SARS-CoV-2-serological-test-results/hhvg-83jq/about_data

This repository analyzes a CDC validation dataset of 204 human serum samples. It blends qualitative reference classifications (PCR-confirmed status) with quantitative serological measurements from commercial high-throughput platforms and standard laboratory neutralization assays.

