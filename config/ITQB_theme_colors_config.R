# ============================================================================
# CENTRALIZED THEME & COLOR CONFIGURATION
# Theme, Color Palettes, and Helper Functions for Salk Analysis Visualizations
# ============================================================================
# 
# This file consolidates all custom ggplot2 themes, crop/timepoint color
# assignments, and visualization helper functions used across analysis .Rmd files.
#
# Source this file in your .Rmd setup chunks:
#   source(file.path(dirname(rstudioapi::getActiveDocumentContext()$path), "../config/theme_colors_config.R"))
#
# Last updated: 2026-04-08
# ============================================================================

# THEME DEFINITIONS =========================================================

# Option 1: DARK THEME using theme_classic() [RECOMMENDED - Currently Active]
# Provides better control over panel backgrounds and clean axes
# theme_dark_custom <- function() {
#   theme_classic() +
#   theme(
#     plot.background = element_rect(fill = "black", color = "#0a0a0a"),
#     panel.background = element_blank(),
#     plot.title = element_text(color = "white", size = 13, face = "bold", margin = margin(b = 10)),
#     axis.title = element_text(color = "white", size = 12),
#     axis.text = element_text(color = "white", size = 11),
#     axis.line = element_line(color = "white", linewidth = 0.5),
#     legend.background = element_rect(fill = "black", color = NA),
#     legend.text = element_text(color = "white", size = 11),
#     legend.title = element_text(color = "white", size = 12)
#     strip.background = element_rect(fill = "#1a1a1a"),
#     strip.text = element_text(color = "white", size = 11, face = "bold")
#   )
# }

# Option 2: Dark Theme using theme_minimal() [Alternative - Minimalist axes]
# Commented out - uncomment below and comment out Option 1 to use
theme_dark_custom <- function() {
  theme_minimal() +
  theme(
    plot.background = element_rect(fill = "#000000", color = NA),
    plot.title = element_text(color = "white", size = 13, face = "bold", margin = margin(b = 10)),
    axis.title = element_text(color = "white", size = 12),
    axis.text = element_text(color = "white", size = 11),
    axis.line = element_line(color = "#ebebeb", linewidth = 0.5),
    panel.grid.major.y = element_line(color = "#484848", linewidth = 0.4, linetype = "dashed"),
    panel.grid.minor.y = element_line(color = "#404040", linewidth = 0.3, linetype = "dashed"),
    panel.grid.major.x = element_line(color = "#484848", linewidth = 0.4, linetype = "dashed"),
    panel.grid.minor.x = element_line(color = "#404040", linewidth = 0.3, linetype = "dashed"),
    legend.background = element_rect(fill = "#000000", color = NA),
    legend.text = element_text(color = "white", size = 11),
    legend.title = element_text(color = "white", size = 12),
    # strip.background = element_rect(fill = "121212"),
    strip.background = element_blank(),
    strip.text = element_text(color = "white", size = 11, face = "bold")
  )
}


# THEME SETTINGS ============================================================
# Control which theme is active and associated text colors

# Set default theme for all plots
theme_set(theme_dark_custom())
# theme_set(theme_minimal())

# Theme suffix for file naming: "-dark" or "-light"
theme_suffix <- "-dark"
# theme_suffix <- "-light"

# Text color for annotations based on theme
# Use "white" when theme_suffix == "-dark", "black" when theme_suffix == "-light"
annotation_text_color <- ifelse(theme_suffix == "-dark", "white", "black")
annotation_line_color <- ifelse(theme_suffix == "-dark", "#707070", "#555555")
# Fill color for annotations based on theme
# Use "black" when theme_suffix == "-dark", "white" when theme_suffix == "-light"
annotation_fill_color <- ifelse(theme_suffix == "-dark", "black", "white")
# shading_color <- ifelse(theme_suffix == "-dark", "#555555", "#bababa")


# COLOR PALETTES ============================================================
# Crop-specific colors for consistent visualization across analyses

# ===== Basic Crop Colors =====
# Used for simple crop differentiation (e.g., scatter plots, line plots)
# Color scheme: miscanthus=aqua, wheat=purple, rice=orange, soy=pink
plant_colors <- c(
  "miscanthus" = "#27B4C1",   # Aqua - control samples
  "sorghum"   = "#8c4dc3",   # Purple - wheat
  "rice"    = "#FC9D33",   # Orange - rice
  "sugarcane"     = "#FE318E"    # Pink/Magenta - soy
)

# ===== Crop-Timepoint Color Palettes =====
# Used for distinguishing timepoints within each crop type
# Organized by crop, with colors progressing from light to dark across timepoints
# 
# Sorghum: light purple (#C381FD) → medium (#AB50FB) → dark purple (#510594)
# Rice: light orange (#FEB057) → medium (#F6962A) → dark brown (#B56203)
# Sugarcane: light pink (#FE67AB) → medium (#FD358F) → dark magenta (#950445)
# Miscanthus: light green (#27B4C1) → medium (#177982) → dark green (#374B1B)
#
# Note: Includes both 3-point (raw, H2O20, NaOH20) and 5-point (raw, H2O20, wk20, H2O30, NaOH20) timepoints
# Analyses using only raw/H2O20/NaOH20 will ignore the intermediate timepoints

# ===== Light Theme Colors =====
crop_colors_light <- c(
  "miscanthus" = "#27B4C1",
  "sorghum"   = "#8C4DC3",
  "rice"    = "#FC9D33",
  "sugarcane"     = "#FF3385"
)

color_map_light <- c(
  "sugarcane_raw" = "#FE67AB",
  "sugarcane_H2O20" = "#FD358F",
  "sugarcane_NaOH20" = "#950445",
  "rice_raw" = "#FEB057",
  "rice_H2O20" = "#F6962A",
  "rice_NaOH20" = "#AF5F04",
  "sorghum_raw" = "#C381FD",
  "sorghum_H2O20" = "#AB50FB",
  "sorghum_NaOH20" = "#510594"
)

color_map_light_all_sep <- list(
  sugarcane = c("raw" = "#FE67AB", "H2O20" = "#FD358F", "NaOH20" = "#950445"),
  rice = c("raw" = "#FEB057", "H2O20" = "#F6962A", "NaOH20" = "#AF5F04"),
  sorghum = c("raw" = "#C381FD", "H2O20" = "#AB50FB", "NaOH20" = "#510594"),
  miscanthus = c("H2O30" = "#27B4C1", "NaOH20" = "#177982")
)

color_map_light_three_sep <- list(
  sugarcane = c("raw" = "#FE67AB", "H2O20" = "#FD358F", "NaOH20" = "#950445"),
  rice = c("raw" = "#FEB057", "H2O20" = "#F6962A", "NaOH20" = "#AF5F04"),
  sorghum = c("raw" = "#C381FD", "H2O20" = "#AB50FB", "NaOH20" = "#510594")
)

# ===== Dark Theme Colors =====
crop_colors_dark <- c(
  "miscanthus" = "#3DC5D2",
  "sorghum"   = "#A36ED3",
  "rice"    = "#FDB15B",
  "sugarcane"     = "#FF599C"
)

color_map_dark <- c(
  "sugarcane_raw" = "#FE9AC7",
  "sugarcane_H2O20" = "#FC368F",
  "sugarcane_NaOH20" = "#C7055C",
  "rice_raw" = "#FECF9A",
  "rice_H2O20" = "#FD9768",
  "rice_NaOH20" = "#E37A03",
  "sorghum_raw" = "#DBB4FE",
  "sorghum_H2O20" = "#C381FD",
  "sorghum_NaOH20" = "#7307D2"
)
color_map_dark_all_sep <- list(
  sorghum = c("raw" = "#dbb4fe", "H2O20" = "#C381FD", "NaOH20" = "#7307D2"),
  rice = c("raw" = "#FECF9A", "H2O20" = "#FD9768", "NaOH20" = "#E37A03"),
  sugarcane = c("raw" = "#FE9AC7", "H2O20" = "#FC368F", "NaOH20" = "#C7055C"),
  miscanthus = c("raw" = "#b3eaef", "H2O20"="#7bdbe4","H2O30" = "#43CCD8", "NaOH20" = "#27B4C1")
)

# ===== Dynamic Color Selection =====
# Select colors based on current theme
crop_colors <- if (theme_suffix == "-dark") crop_colors_dark else crop_colors_light
color_map <- if (theme_suffix == "-dark") color_map_dark else color_map_light
color_map_all_sep <- if (theme_suffix == "-dark") color_map_dark_all_sep else color_map_light_all_sep
color_map_three_sep <- if (theme_suffix == "-dark") color_map_dark_three_sep else color_map_light_three_sep

# For backward compatibility
crop_color <- c(
  "sugarcane" = crop_colors[["sugarcane"]],
  "rice" = crop_colors[["rice"]],
  "sorghum" = crop_colors[["sorghum"]]
)

# crop_timepoint_colors <- list(
#   sorghum = c(
#     "raw" = "#C381FD",    # Light purple
#     "H2O20" = "#AB50FB",   # Medium purple
#     "wk20" = "#941FF9",   # Medium-dark purple
#     "H2O30" = "#7307D2",   # Dark purple
#     "NaOH20" = "#510594"    # Very dark purple
#   ),
#   rice = c(
#     "raw" = "#FEB057",    # Light orange
#     "H2O20" = "#F6962A",   # Medium orange
#     "wk29" = "#F18204",   # Medium-dark orange
#     "NaOH20" = "#B56203"    # Dark brown
#   ),
#   sugarcane = c(
#     "raw" = "#FE67AB",    # Light pink
#     "H2O20" = "#FD358F",   # Medium pink/magenta
#     "wk20" = "#FB0473",   # Dark pink
#     "H2O30" = "#C8045C",   # Dark magenta
#     "NaOH20" = "#950445"    # Very dark magenta
#   ),
#   miscanthus = c(
#     "H2O30" = "#27B4C1",   # teal
#     "NaOH20" = "#177982"    # dark teal (miscanthus only has H2O30 and NaOH20 timepoints)
#   )
# )

# # ===== Full Crop-Timepoint Color Map =====
# # Named vector with all crop-timepoint combinations for direct lookup
# # Used when filtering to specific timepoints (e.g., NMR analysis with raw/H2O20/NaOH20 only)
# color_map <- c(
#   # Sugarcane: light to dark magenta
#   "sugarcane_raw" = "#FE67AB",
#   "sugarcane_H2O20" = "#FD358F",
#   "sugarcane_NaOH20" = "#950445",
#   # Rice: light to dark orange
#   "rice_raw" = "#FEB057",
#   "rice_H2O20" = "#F6962A",
#   "rice_NaOH20" = "#B56203",
#   # Sorghum: light to dark purple
#   "sorghum_raw" = "#DBB4FE",
#   "sorghum_H2O20" = "#C381FD",
#   "sorghum_NaOH20" = "#7307D2"
# )

# # Alternative simplified crop colors for quick reference
# crop_color_simple <- c(
#   "soy" = "#FE318E",
#   "rice" = "#FC9D33",
#   "wheat" = "#884EBB"
# )

# # Alias for compatibility with existing .Rmd files
# crop_color <- crop_color_simple


# HELPER FUNCTIONS ==========================================================

# ggsave_themed()
# Wrapper around ggplot2::ggsave() that automatically appends theme suffix to filenames
# 
# Usage:
#   ggsave_themed(
#     filename = "my_plot.png",
#     plot = my_plot_object,
#     width = 12,
#     height = 6,
#     dpi = 300
#   )
#
# Output: my_plot-dark.png (when using dark theme)
#         my_plot-light.png (when using light theme)
#
# Note: Requires 'outputs_folder' variable to be defined in calling .Rmd file
#
ggsave_themed <- function(filename, plot, width = NA, height = NA, dpi = 300, ...) {
  # Validate that outputs_folder is defined in parent environment
  if (!exists("outputs_folder", where = parent.frame())) {
    stop("Error: 'outputs_folder' variable not found. ",
         "Please define 'outputs_folder' in your .Rmd setup chunk before calling ggsave_themed().")
  }
  
  # Remove existing -light or -dark suffix if present, then add the current theme suffix
  base_filename <- gsub("-light\\.png$|-dark\\.png$", ".png", filename)
  themed_filename <- sub("\\.png$", paste0(theme_suffix, ".png"), base_filename)
  
  # Get outputs_folder from parent environment (the calling .Rmd file)
  outputs_folder <- get("outputs_folder", envir = parent.frame())
  output_path <- file.path(outputs_folder, themed_filename)
  
  # Save the plot
  ggsave(output_path, plot, width = width, height = height, dpi = dpi, ...)
}

# ============================================================================
# END CONFIG FILE
# ============================================================================
