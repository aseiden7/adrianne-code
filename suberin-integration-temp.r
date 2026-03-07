# working on suberin integration code
## Integrating spectral regions
```{r suberin-integration-function}
suberin_spectral_integration <- function(dpt_data) {
  cat("Starting spectral integration processing...\n")
  
  # Load required library for integration
  if (!require(pracma, quietly = TRUE)) {
    install.packages("pracma")
    library(pracma)
  }
  
  # Prepare the data in the format needed for integration
  # Rename columns to match expected format
  comb <- dpt_data %>%
    select(filename, wavenumber, absorbance) %>%
    rename(sample = filename, wavelength = wavenumber, abs = absorbance)
  
  # Define spectral windows of interest
  red1 <- comb[comb$wavelength > 2918 & comb$wavelength < 2928, ]  # Aliphatic 1
  red2 <- comb[comb$wavelength > 2848 & comb$wavelength < 2858, ]  # Aliphatic 2  
  red3 <- comb[comb$wavelength > 1728 & comb$wavelength < 1749, ]  # Esters
  red4 <- comb[comb$wavelength > 1454 & comb$wavelength < 1472, ]  # fingerprint 1
  red5 <- comb[comb$wavelength > 1355 & comb$wavelength < 1375, ]  # fingerprint 2
  red6 <- comb[comb$wavelength > 1233 & comb$wavelength < 1253, ]  # fingerprint 3
  red7 <- comb[comb$wavelength > 1153 & comb$wavelength < 1183, ]  # fingerprint 4
  red8 <- comb[comb$wavelength > 714 & comb$wavelength < 728, ]  # fingerprint 5

  # Get unique samples
  sample <- unique(comb$sample)
  
  # Create integration results data frame
  S_ints <- data.frame(
    sample = sample,
    int_2918_2928 = numeric(length(sample)),
    int_2848_2858 = numeric(length(sample)),
    int_1728_1749 = numeric(length(sample)),
    int_1454_1472 = numeric(length(sample)),
    int_1355_1375 = numeric(length(sample)),
    int_1233_1253 = numeric(length(sample)),
    int_1153_1183 = numeric(length(sample)),
    int_714_728 = numeric(length(sample)),
    stringsAsFactors = FALSE
  )
  
  # Calculate integrated areas for each spectral window and sample
  cat("Processing", length(sample), "samples for integration...\n")
  for (i in seq_len(nrow(S_ints))) {
    current_sample <- sample[i]
    
    # Extract data for current sample from each spectral window
    sample_red1 <- red1[red1$sample == current_sample, ]
    sample_red2 <- red2[red2$sample == current_sample, ]
    sample_red3 <- red3[red3$sample == current_sample, ]
    sample_red4 <- red4[red4$sample == current_sample, ]
    sample_red5 <- red5[red5$sample == current_sample, ]
    sample_red6 <- red6[red6$sample == current_sample, ]
    sample_red7 <- red7[red7$sample == current_sample, ]
    sample_red8 <- red8[red8$sample == current_sample, ]
    # Calculate area under curve (integration) using trapezoidal rule
    if (nrow(sample_red1) > 1) {
      S_ints$int_2918_2928[i] <- pracma::trapz(sample_red1$wavelength, sample_red1$abs)
    }
    
    if (nrow(sample_red2) > 1) {
      S_ints$int_2848_2858[i] <- pracma::trapz(sample_red2$wavelength, sample_red2$abs)
    }
    
    if (nrow(sample_red3) > 1) {
      S_ints$int_1728_1749[i] <- pracma::trapz(sample_red3$wavelength, sample_red3$abs)
    }
    
    if (nrow(sample_red4) > 1) {
      S_ints$int_1454_1472[i] <- pracma::trapz(sample_red4$wavelength, sample_red4$abs)
    }
    
    if (nrow(sample_red5) > 1) {
      S_ints$int_1355_1375[i] <- pracma::trapz(sample_red5$wavelength, sample_red5$abs)
    }
    
    if (nrow(sample_red6) > 1) {
      S_ints$int_1233_1253[i] <- pracma::trapz(sample_red6$wavelength, sample_red6$abs)
    }
    
    if (nrow(sample_red7) > 1) {
      S_ints$int_1153_1183[i] <- pracma::trapz(sample_red7$wavelength, sample_red7$abs)
    }
    
    if (nrow(sample_red8) > 1) {
      S_ints$int_714_728[i] <- pracma::trapz(sample_red8$wavelength, sample_red8$abs)
    }
  }
  
  # Use existing metadata from the input data (no need to re-extract)
  cat("Using existing metadata from DPT data...\n")
  basic_meta <- dpt_data %>%
    select(filename, crop, timepoint, sample_type, ID) %>%
    distinct() %>%
    rename(sample = filename, type = sample_type)
  
  # Combine metadata with integration results
  ftir_suber <- merge(basic_meta, S_ints, by = "sample", all = TRUE)
  
  # Calculate derived metrics (same as original)
  ftir_suber$esterS <- ftir_suber$int_1728_1749
  ftir_suber$aliphaticS <- ftir_suber$int_2848_2858 + ftir_suber$int_2918_2928
  ftir_suber$fingerprintS <- ftir_suber$int_1454_1472 + ftir_suber$int_1355_1375 + ftir_suber$int_1233_1253 + ftir_suber$int_1153_1183 + ftir_suber$int_714_728
  ftir_suber$fingerprintS_no723 <- ftir_suber$int_1454_1472 + ftir_suber$int_1355_1375 + ftir_suber$int_1233_1253 + ftir_suber$int_1153_1183
  ftir_suber$total_suberin <- ftir_suber$aliphaticS + ftir_suber$esterS + ftir_suber$fingerprintS
  ftir_suber$aliphaticS_prop <- ftir_suber$aliphaticS / ftir_suber$total_suberin
  ftir_suber$esterS_prop <- ftir_suber$esterS / ftir_suber$total_suberin
  ftir_suber$fingerprintS_prop <- ftir_suber$fingerprintS / ftir_suber$total_suberin
  
  
  # Save the processed data to the output directory
  today <- format(Sys.Date(), "%Y-%m-%d")
  output_file <- file.path(outputs_folder, paste0("processed_suberin_int_data_", today, ".csv"))
  write.csv(ftir_suber, file = output_file, row.names = FALSE)
  cat("Saved processed integration data to:", output_file, "\n")
  
  cat("Integration processing completed successfully.\n")
  return(ftir_suber)
}
```

## Generating statistics
```{r import-suberin-integration-data, message=FALSE, warning=FALSE}
# Helper function to find the most recent processed integration data file
most_recent_suberin_file <- function(data_dir) {
  pattern <- "processed_suberin_int_data_.*\\.csv$"
  files <- list.files(data_dir, pattern = pattern, full.names = TRUE)
  
  if (length(files) == 0) {
    return(NULL)
  }
  
  # Extract dates from filenames and find the most recent
  dates <- stringr::str_extract(basename(files), "\\d{4}-\\d{2}-\\d{2}")
  most_recent_idx <- which.max(as.Date(dates))
  
  cat("Found", length(files), "processed suberin integration files\n")
  cat("Using most recent file:", basename(files[most_recent_idx]), "\n")
  
  return(files[most_recent_idx])
}
# Try to find the most recent processed integration data file
suber_ftir_file <- most_recent_suberin_file(integrated_ftir_data)

if (!is.null(suber_ftir_file) && file.exists(suber_ftir_file)) {
  suber_data <- read_csv(suber_ftir_file, show_col_types = FALSE)
  cat("Successfully loaded FTIR integration data from:", basename(suber_ftir_file), "\n")
  cat("Dimensions:", dim(suber_data), "\n")
  cat("Columns:", names(suber_data), "\n")
} else {
  cat("No processed integration data found. Processing raw DPT data to generate integration results...\n")
  
  # Check if we have the required dpt_data_roots from previous chunk
  if (!exists("dpt_data_roots") || nrow(dpt_data_roots) == 0) {
    stop("No DPT data available for integration. Please ensure the DPT data import was successful.")
  }
  
  # Process raw DPT data using the integrated function
  ftir_suber <- suberin_spectral_integration(dpt_data_roots)
  
  # Verify the processing was successful
  if (is.null(ftir_suber) || nrow(ftir_suber) == 0) {
    stop("Failed to process DPT data for integration.")
  }
  
  cat("Successfully processed", nrow(ftir_suber), "samples from DPT data\n")
  cat("Generated columns:", names(ftir_suber), "\n")
}

# Calculate summary statistics by group
crop_suber <- ftir_suber %>%
  mutate(crop = factor(crop, levels = c("noPlant", "wheat", "rice", "soy"))) %>%
  group_by(crop) %>%
  summarise(
    Mean_total_suberin = mean(total_suberin, na.rm = TRUE),
    SE_total_suberin = sd(total_suberin, na.rm = TRUE) / sqrt(n()),
    Mean_aliphaticS_prop = mean(aliphaticS_prop, na.rm = TRUE),
    SE_aliphaticS_prop = sd(aliphaticS_prop, na.rm = TRUE) / sqrt(n()),
    Mean_esterS_prop = mean(esterS_prop, na.rm = TRUE),
    SE_esterS_prop = sd(esterS_prop, na.rm = TRUE) / sqrt(n()),
    Mean_fingerprintS_prop = mean(fingerprintS_prop, na.rm = TRUE),
    SE_fingerprintS_prop = sd(fingerprintS_prop, na.rm = TRUE) / sqrt(n()),
    .groups = 'drop'
  )

timepoint_suber <- ftir_suber %>%
  group_by(timepoint) %>%
  summarise(
    Mean_total_suberin = mean(total_suberin, na.rm = TRUE),
    SE_total_suberin = sd(total_suberin, na.rm = TRUE) / sqrt(n()),
    Mean_aliphaticS_prop = mean(aliphaticS_prop, na.rm = TRUE),
    SE_aliphaticS_prop = sd(aliphaticS_prop, na.rm = TRUE) / sqrt(n()),
    Mean_esterS_prop = mean(esterS_prop, na.rm = TRUE),
    SE_esterS_prop = sd(esterS_prop, na.rm = TRUE) / sqrt(n()),
    Mean_fingerprintS_prop = mean(fingerprintS_prop, na.rm = TRUE),
    SE_fingerprintS_prop = sd(fingerprintS_prop, na.rm = TRUE) / sqrt(n()),
    Mean_fingerprintS_no723_prop = mean(fingerprintS_no723_prop, na.rm = TRUE),
    SE_fingerprintS_no723_prop = sd(fingerprintS_no723_prop, na.rm = TRUE) / sqrt(n()),
    .groups = 'drop'
  )

crop_timepoint_suber <- ftir_suber %>%
  mutate(crop = factor(crop, levels = c("noPlant", "wheat", "rice", "soy"))) %>%
  group_by(crop, timepoint) %>%
  summarise(
    Mean_total_suberin = mean(total_suberin, na.rm = TRUE),
    SE_total_suberin = sd(total_suberin, na.rm = TRUE) / sqrt(n()),
    Mean_aliphaticS_prop = mean(aliphaticS_prop, na.rm = TRUE),
    SE_aliphaticS_prop = sd(aliphaticS_prop, na.rm = TRUE) / sqrt(n()),
    Mean_esterS_prop = mean(esterS_prop, na.rm = TRUE),
    SE_esterS_prop = sd(esterS_prop, na.rm = TRUE) / sqrt(n()),
    Mean_fingerprintS_prop = mean(fingerprintS_prop, na.rm = TRUE),
    SE_fingerprintS_prop = sd(fingerprintS_prop, na.rm = TRUE) / sqrt(n()),
    Mean_fingerprintS_no723_prop = mean(fingerprintS_no723_prop, na.rm = TRUE),
    SE_fingerprintS_no723_prop = sd(fingerprintS_no723_prop, na.rm = TRUE) / sqrt(n()),
    .groups = 'drop'
  )
```
##############################################################################################
# Visualizing integrated ranges
#This code is modified from "Visualizing_FTIR_w_Elemental_Data.R"
```{r leila-plots-suberin}
# Recreate the EXACT plotting function from Leila_code_modified.Rmd
suber_proportion_plots <- function(stats_data, group_col, title_prefix) {
  # Choose colors based on grouping variable
  colors_to_use <- if(group_col == "crop") crop_colors else timepoint_colors
  
  p1 <- ggplot(data = stats_data, aes_string(x = group_col, y = "Mean_total_suberin", fill = group_col)) +
    geom_col(alpha = 0.8) +
    geom_errorbar(aes_string(ymin = "Mean_total_suberin - SE_total_suberin", 
                            ymax = "Mean_total_suberin + SE_total_suberin"),
                  width = 0.2) +
    theme_classic() +
    scale_fill_manual(values = colors_to_use) +
    labs(title = paste0(title_prefix, "Total (relative) Suberin"),
         x = str_to_title(group_col),
         y = "Total Suberin Proportion") +
    theme(legend.position = "none",
          axis.text.x = element_text(angle = 45, hjust = 1),
          plot.margin = margin(20, 20, 20, 20),
          axis.title = element_text(size = 12),
          plot.title = element_text(size = 10))

  p2 <- ggplot(data = stats_data, aes_string(x = group_col, y = "Mean_aliphaticS_prop", fill = group_col)) +
    geom_col(alpha = 0.8) +
    geom_errorbar(aes_string(ymin = "Mean_aliphaticS_prop - SE_aliphaticS_prop", 
                            ymax = "Mean_aliphaticS_prop + SE_aliphaticS_prop"),
                  width = 0.2) +
    theme_classic() +
    scale_fill_manual(values = colors_to_use) +
    labs(title = paste0(title_prefix, "Aliphatic Suberin/Total Suberin"),
         x = str_to_title(group_col),
         y = "Aliphatic Suberin Proportion") +
    theme(legend.position = "none",
          axis.text.x = element_text(angle = 45, hjust = 1),
          plot.margin = margin(20, 20, 20, 20),
          axis.title = element_text(size = 12),
          plot.title = element_text(size = 10))

  p3 <- ggplot(data = stats_data, aes_string(x = group_col, y = "Mean_esterS_prop", fill = group_col)) +
    geom_col(alpha = 0.8) +
    geom_errorbar(aes_string(ymin = "Mean_esterS_prop - SE_esterS_prop", 
                            ymax = "Mean_esterS_prop + SE_esterS_prop"),
                  width = 0.2) +
    theme_classic() +
    scale_fill_manual(values = colors_to_use) +
    labs(title = paste0(title_prefix, "Esterified Suberin/Total Suberin"),
         x = str_to_title(group_col),
         y = "Esterified Suberin Proportion") +
    theme(legend.position = "none",
          axis.text.x = element_text(angle = 45, hjust = 1),
          plot.margin = margin(20, 20, 20, 20),
          axis.title = element_text(size = 12),
          plot.title = element_text(size = 10))

  p4 <- ggplot(data = stats_data, aes_string(x = group_col, y = "Mean_fingerprintS_prop", fill = group_col)) +
    geom_col(alpha = 0.8) +
    geom_errorbar(aes_string(ymin = "Mean_fingerprintS_prop - SE_fingerprintS_prop", 
                            ymax = "Mean_fingerprintS_prop + SE_fingerprintS_prop"),
                  width = 0.2) +
    theme_classic() +
    scale_fill_manual(values = colors_to_use) +
    labs(title = paste0(title_prefix, "Fingerprint Suberin/Total Suberin"),
         x = str_to_title(group_col),
         y = "Fingerprint Suberin Proportion") +
    theme(legend.position = "none",
          axis.text.x = element_text(angle = 45, hjust = 1),
          plot.margin = margin(20, 20, 20, 20),
          axis.title = element_text(size = 12),
          plot.title = element_text(size = 10))

  p5 <- ggplot(data = stats_data, aes_string(x = group_col, y = "Mean_fingerprintS_no723_prop", fill = group_col)) +
    geom_col(alpha = 0.8) +
    geom_errorbar(aes_string(ymin = "Mean_fingerprintS_no723_prop - SE_fingerprintS_no723_prop", 
                            ymax = "Mean_fingerprintS_no723_prop + SE_fingerprintS_no723_prop"),
                  width = 0.2) +
    theme_classic() +
    scale_fill_manual(values = colors_to_use) +
    labs(title = paste0(title_prefix, "Fingerprint Suberin/Total Suberin"),
         x = str_to_title(group_col),
         y = "Fingerprint Suberin Proportion") +
    theme(legend.position = "none",
          axis.text.x = element_text(angle = 45, hjust = 1),
          plot.margin = margin(20, 20, 20, 20),
          axis.title = element_text(size = 12),
          plot.title = element_text(size = 10))

  list(p1 = p1, p2 = p2, p3 = p3, p4 = p4, p5 = p5)
}

# Create EXACT plots by crop (from Leila_code_modified.Rmd)
crop_suber_plots <- suber_proportion_plots(crop_suber, "crop", "")
crop_suber_combined <- plot_grid(crop_suber_plots$p1, crop_suber_plots$p2, crop_suber_plots$p3, crop_suber_plots$p4, crop_suber_plots$p5, nrow = 1, labels = "auto")
print(crop_suber_combined)

# Create EXACT plots by timepoint (from Leila_code_modified.Rmd)
timepoint_suber_plots <- suber_proportion_plots(timepoint_suber, "timepoint", "")
timepoint_suber_combined <- plot_grid(timepoint_suber_plots$p1, timepoint_suber_plots$p2, timepoint_suber_plots$p3, timepoint_suber_plots$p4, timepoint_suber_plots$p5, nrow = 1, labels = "auto")
print(timepoint_suber_combined)


# SUBERIN INTERACTION PLOT
# Recreate simple plant proportion interaction plot (crop x timepoint) from Leila_code_modified.Rmd
suber_interaction_plot <- ggplot(crop_timepoint_suber) +
  geom_col(aes(x = crop, y = Mean_total_suberin, fill = timepoint),
           position = "dodge", alpha = 0.8) +
  geom_errorbar(aes(x = crop,
                    ymin = Mean_total_suberin - SE_total_suberin,
                    ymax = Mean_total_suberin + SE_total_suberin,
                    group = timepoint),
                position = position_dodge(0.9), width = 0.2) +
  theme_classic() +
  scale_fill_manual("Timepoint", values = timepoint_colors) +
  labs(title = "Total Suberin by Crop and Timepoint",
       x = "Crop Type",
       y = "Total Suberin Proportion") +
  theme(legend.position = "top",
        plot.margin = margin(20, 20, 20, 20),
        axis.text.x = element_text(angle = 45, hjust = 1))

print(suber_interaction_plot)

# Esterified PROPORTION INTERACTION PLOT
esterS_interaction_plot <- ggplot(crop_timepoint_suber) +
  geom_col(aes(x = crop, y = Mean_esterS_prop, fill = timepoint),
           position = "dodge", alpha = 0.8) +
  geom_errorbar(aes(x = crop,
                    ymin = Mean_esterS_prop - SE_esterS_prop,
                    ymax = Mean_esterS_prop + SE_esterS_prop,
                    group = timepoint),
                position = position_dodge(0.9), width = 0.2) +
  theme_classic() +
  scale_fill_manual("Timepoint", values = timepoint_colors) +
  labs(title = "Esterified Suberin by Crop and Timepoint",
       x = "Crop Type",
       y = "Esterified Suberin Proportion") +
  theme(legend.position = "top",
        plot.margin = margin(20, 20, 20, 20),
        axis.text.x = element_text(angle = 45, hjust = 1))

print(esterS_interaction_plot)

# FINGERPRINT PROPORTION INTERACTION PLOT
fingpr_interaction_plot <- ggplot(crop_timepoint_suber) +
  geom_col(aes(x = crop, y = Mean_fingerprintS_prop, fill = timepoint),
           position = "dodge", alpha = 0.8) +
  geom_errorbar(aes(x = crop,
                    ymin = Mean_fingerprintS_prop - SE_fingerprintS_prop,
                    ymax = Mean_fingerprintS_prop + SE_fingerprintS_prop,
                    group = timepoint),
                position = position_dodge(0.9), width = 0.2) +
  theme_classic() +
  scale_fill_manual("Timepoint", values = timepoint_colors) +
  labs(title = "Fingerprint Suberin by Crop and Timepoint",
       x = "Crop Type",
       y = "Fingerprint Suberin Proportion") +
  theme(legend.position = "top",
        plot.margin = margin(20, 20, 20, 20),
        axis.text.x = element_text(angle = 45, hjust = 1))

print(fingpr_interaction_plot)

# STACKED BAR PLOTS
# Recreate stacked bar plots from Leila_code_modified.Rmd
suber_stacked_data <- function(stats_data, group_col) {
  # Reshape data for stacking (exact reproduction)
  long_data <- stats_data %>%
    select(all_of(group_col), Mean_aliphaticS_prop, Mean_esterS_prop, Mean_fingerprintS_prop) %>%
    pivot_longer(cols = starts_with("Mean_"),
                 names_to = "func_type",
                 values_to = "proportion") %>%
    mutate(func_type = case_when(
      func_type == "Mean_aliphaticS_prop" ~ "Aliphatic",
      func_type == "Mean_esterS_prop" ~ "Esterified",
      func_type == "Mean_fingerprintS_prop" ~ "Fingerprint"
    )) %>%
    mutate(func_type = factor(func_type, levels = c("Fingerprint", "Esterified", "Aliphatic")))

  long_data
}

# Create stacked plots
crop_stacked_suber <- suber_stacked_data(crop_suber, "crop")
crop_stacked_suber$crop <- factor(crop_stacked_suber$crop, levels = c("noPlant", "wheat", "rice", "soy"))
timepoint_stacked_suber <- suber_stacked_data(timepoint_suber, "timepoint")

s_crop_stacked <- ggplot(crop_stacked_suber, aes(x = crop, y = proportion * 100, fill = func_type)) +
  geom_col(position = "stack") +
  scale_fill_manual(values = c("#93deed", "#d2f0f4", "#1ca5cf"),
                    breaks = c("Fingerprint", "Esterified", "Aliphatic")) +
  theme_classic() +
  labs(x = "Crop Type",
       y = "Suberin Peak Proportion (%)",
       fill = "") +
  theme(legend.position = "top",
        plot.margin = margin(20, 27, 20, 13),
        axis.text.x = element_text(angle = 45, hjust = 1),
        legend.margin = margin(10, 16, 10, 8))

s_timepoint_stacked <- ggplot(timepoint_stacked_suber, aes(x = timepoint, y = proportion * 100, fill = func_type)) +
  geom_col(position = "stack") +
  scale_fill_manual(values = c("#e8aa9c", "#f5d8d1", "#c54e30"),
                    breaks = c("Fingerprint", "Esterified", "Aliphatic")) +
  theme_classic() +
  labs(x = "Timepoint",
       y = "Suberin Peak Proportion (%)",
       fill = "") +
  theme(legend.position = "top",
        plot.margin = margin(20, 27, 20, 13),
        axis.text.x = element_text(angle = 45, hjust = 1),
        legend.margin = margin(10, 16, 10, 8))

s_combined_stacked <- plot_grid(
  s_crop_stacked,
  s_timepoint_stacked,
  nrow = 1,
  labels = "auto"
)
print(s_combined_stacked)
```


## Stacked interaction plots (crop x timepoint)

```{r suber-stacked-interaction-plots}
timepoint_suber_colors <- list(
  "wk0" = c("Fingerprint" = "#8a82c0", "Esterified" = "#bdb8e0", "Aliphatic" = "#50478A"),
  "wk10" = c("Fingerprint" = "#7ba7c6", "Esterified" = "#b8d0e0", "Aliphatic" = "#3D6988"),
  "wk20" = c("Fingerprint" = "#c5aa7c", "Esterified" = "#e0d1b8", "Aliphatic" = "#876B3D"),
  "wk30" = c("Fingerprint" = "#7cc5af", "Esterified" = "#b8e0d4", "Aliphatic" = "#3D8770"),
  "wk40" = c("Fingerprint" = "#b4c57c", "Esterified" = "#d6e0b8", "Aliphatic" = "#75873D")
)

# Stacked interaction plot - crop x timepoint with all three proportions
# Create stacked data for interaction plot
interaction_stacked_suber <- crop_timepoint_suber %>%
  select(crop, timepoint, Mean_aliphaticS_prop, Mean_esterS_prop, Mean_fingerprintS_prop) %>%
  pivot_longer(cols = starts_with("Mean_"),
               names_to = "func_type",
               values_to = "proportion") %>%
  mutate(func_type = case_when(
    func_type == "Mean_aliphaticS_prop" ~ "Aliphatic",
    func_type == "Mean_esterS_prop" ~ "Esterified",
    func_type == "Mean_fingerprintS_prop" ~ "Fingerprint"
  )) %>%
  mutate(func_type = factor(func_type, levels = c("Fingerprint", "Esterified", "Aliphatic")))

# Create a combined group for positioning (crop:timepoint)
interaction_stacked_suber <- interaction_stacked_suber %>%
  mutate(crop_time = interaction(crop, timepoint, sep = "_"))

# Apply colors - using average of timepoint colors for each functional group
# Or better - use timepoint-specific colors from timepoint_prop_colors
# Create fill based on timepoint:func_type combination
interaction_stacked_suber <- interaction_stacked_suber %>%
  mutate(fill_group = paste(timepoint, func_type, sep = "_"))

interaction_suber_stacked <- ggplot(interaction_stacked_suber, 
                                   aes(x = interaction(crop, timepoint), 
                                       y = proportion * 100, 
                                       fill = fill_group)) +
  geom_col(position = "stack") +
  facet_grid(. ~ crop, scales = "free_x", space = "free_x") +
  scale_x_discrete(labels = function(x) {
    # Extract just the timepoint part (after the dot)
    sapply(strsplit(as.character(x), "\\."), function(parts) parts[2])
  }) +
  scale_y_continuous(expand = expansion(mult = c(0.01, 0.02))) +
  theme_classic() +
  labs(title = "",
       x = "",
       y = "Suberin Peak Proportion (%)",
       fill = "") +
  theme(legend.position = "right",
        plot.margin = margin(-2, 76, 0, 12), # (top, right, bottom, left)
        axis.text.x = element_text(angle = 45, hjust = .9, size = 12.5, face = "bold"),
        axis.title.y = element_text(size = 12),
        axis.text.y = element_text(size = 11),
        strip.background = element_blank(),
        strip.text = element_text(size = 14.5, face = "bold")) +
  coord_cartesian(clip = "off")

# Create manual color scale using timepoint_prop_colors
color_values <- c()
color_names <- c()
for (tp in c("wk0", "wk10", "wk20", "wk30", "wk40")) {
  for (ft in c("Fingerprint", "Esterified", "Aliphatic")) {
    color_names <- c(color_names, paste(tp, ft, sep = "_"))
    color_values <- c(color_values, timepoint_suber_colors[[tp]][ft])
  }
}
names(color_values) <- color_names

interaction_suber_stacked <- interaction_suber_stacked +
  scale_fill_manual(values = color_values,
                    labels = function(x) {
                      parts <- strsplit(x, "_")
                      sapply(parts, function(p) paste(p[1], p[2], sep = " - "))
                    }) +
  theme(legend.position = "none")

# Calculate label positions (midpoint of each segment in the rightmost bar)
# Get the rightmost crop-timepoint combination for labeling
label_data <- interaction_stacked_suber %>%
  filter(crop == "soy" & timepoint == "wk40") %>%
  arrange(func_type) %>%
  mutate(
    # Calculate cumulative sum for positioning
    cum_prop = cumsum(proportion * 100),
    # Calculate midpoint of each segment
    label_y = cum_prop - (proportion * 100) / 2
  )

# Add labels on the right side
interaction_suber_stacked <- interaction_suber_stacked +
  geom_text(data = label_data,
            aes(x = interaction(crop, timepoint), 
                y = label_y, 
                label = func_type),
            hjust = 0, 
            nudge_x = 0.5,
            size = 3.8,
            angle = 10,
            fontface = "bold",
            inherit.aes = FALSE)

print(interaction_suber_stacked)
```

```{r suber-stacked-interaction-plots-no-noPlant}
# Stacked interaction plot - crop x timepoint (without noPlant)
# Create stacked data for interaction plot
interaction_stacked_suber_no_noPlant <- crop_timepoint_suber %>%
  filter(crop != "noPlant") %>%
  select(crop, timepoint, Mean_aliphaticS_prop, Mean_esterS_prop, Mean_fingerprintS_prop) %>%
  pivot_longer(cols = starts_with("Mean_"),
               names_to = "func_type",
               values_to = "proportion") %>%
  mutate(func_type = case_when(
    func_type == "Mean_aliphaticS_prop" ~ "Aliphatic",
    func_type == "Mean_esterS_prop" ~ "Esterified",
    func_type == "Mean_fingerprintS_prop" ~ "Fingerprint"
  )) %>%
  mutate(func_type = factor(func_type, levels = c("Fingerprint", "Esterified", "Aliphatic")))

# Create a combined group for positioning (crop:timepoint)
interaction_stacked_suber_no_noPlant <- interaction_stacked_suber_no_noPlant %>%
  mutate(crop_time = interaction(crop, timepoint, sep = "_"))

# Create fill based on timepoint:func_type combination
interaction_stacked_suber_no_noPlant <- interaction_stacked_suber_no_noPlant %>%
  mutate(fill_group = paste(timepoint, func_type, sep = "_"))

interaction_suber_stacked_no_noPlant <- ggplot(interaction_stacked_suber_no_noPlant, 
                                   aes(x = interaction(crop, timepoint), 
                                       y = proportion * 100, 
                                       fill = fill_group)) +
  geom_col(position = "stack") +
  facet_grid(. ~ crop, scales = "free_x", space = "free_x") +
  scale_x_discrete(labels = function(x) {
    # Extract just the timepoint part (after the dot)
    sapply(strsplit(as.character(x), "\\."), function(parts) parts[2])
  }) +
  scale_y_continuous(expand = expansion(mult = c(0.01, 0.02))) +
  theme_classic() +
  labs(title = "",
       x = "",
       y = "Suberin Peak Proportion (%)",
       fill = "") +
  theme(legend.position = "right",
        plot.margin = margin(-2, 76, 0, 12), # (top, right, bottom, left)
        axis.text.x = element_text(angle = 45, hjust = .9, size = 12.5, face = "bold"),
        axis.title.y = element_text(size = 12),
        axis.text.y = element_text(size = 11),
        strip.background = element_blank(),
        strip.text = element_text(size = 14.5, face = "bold")) +
  coord_cartesian(clip = "off")

# Create manual color scale using timepoint_prop_colors
interaction_suber_stacked_no_noPlant <- interaction_suber_stacked_no_noPlant +
  scale_fill_manual(values = color_values,
                    labels = function(x) {
                      parts <- strsplit(x, "_")
                      sapply(parts, function(p) paste(p[1], p[2], sep = " - "))
                    }) +
  theme(legend.position = "none")

# Calculate label positions (midpoint of each segment for ALL bars)
# Calculate cumulative proportions for positioning percentage labels
label_data_no_noPlant <- interaction_stacked_suber_no_noPlant %>%
  group_by(crop, timepoint) %>%
  arrange(func_type) %>%
  mutate(
    # Calculate cumulative sum for positioning
    cum_prop = cumsum(proportion * 100),
    # Calculate midpoint of each segment
    label_y = cum_prop - (proportion * 100) / 2,
    # Create percentage label
    pct_label = paste0(round(proportion * 100, 1), "%"),
    # Assign label color: black for Microbial (light), white for others (darker)
    # label_color = ifelse(func_type == "Microbial", "black", "white")
    label_color = ifelse(func_type == "Aliphatic", "white", "black")
  ) %>%
  ungroup()

# Create label data for func_type labels (rightmost bar only)
functype_label_data <- label_data_no_noPlant %>%
  filter(crop == "soy" & timepoint == "wk40")

# Add percentage labels to all bars
interaction_suber_stacked_no_noPlant <- interaction_suber_stacked_no_noPlant +
  geom_text(data = label_data_no_noPlant,
            aes(x = interaction(crop, timepoint), 
                y = label_y, 
                label = pct_label,
                color = label_color),
            size = 3.2,
            fontface = "plain",
            inherit.aes = FALSE) +
  scale_color_identity() +  # Use the actual color values from label_color
  # Add func_type labels on the right side
  geom_text(data = functype_label_data,
            aes(x = interaction(crop, timepoint), 
                y = label_y, 
                label = func_type),
            hjust = 0, 
            nudge_x = 0.5,
            size = 3.8,
            angle = 10,
            fontface = "bold",
            inherit.aes = FALSE)

print(interaction_plot_stacked_no_noPlant)
```