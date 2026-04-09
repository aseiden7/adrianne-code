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
    plot.background = element_rect(fill = "black", color = NA),
    plot.title = element_text(color = "white", size = 13, face = "bold", margin = margin(b = 10)),
    axis.title = element_text(color = "white", size = 12),
    axis.text = element_text(color = "white", size = 11),
    axis.line = element_line(color = "#ebebeb", linewidth = 0.5),
    panel.grid.major.y = element_line(color = "#333333", linewidth = 0.25, linetype = "dashed"),
    panel.grid.minor.y = element_line(color = "#272727", linewidth = 0.15, linetype = "dashed"),
    panel.grid.major.x = element_line(color = "#333333", linewidth = 0.25, linetype = "dashed"),
    panel.grid.minor.x = element_line(color = "#272727", linewidth = 0.15, linetype = "dashed"),
    legend.background = element_rect(fill = "black"),
    legend.text = element_text(color = "white", size = 11),
    legend.title = element_text(color = "white", size = 12),
    # strip.background = element_rect(fill = "121212"),
    strip.background = element_blank(),
    strip.text = element_text(color = "white", size = 11, face = "bold")
  )
}

# LIGHT THEME [Optional - for switching between themes]
theme_light_custom <- function() {
  theme_classic() +
  theme(
    plot.background = element_rect(fill = "white", color = NA),
    panel.background = element_rect(fill = "white", color = "black"),
    plot.title = element_text(color = "black", size = 13, face = "bold", margin = margin(b = 10)),
    axis.title = element_text(color = "black", size = 12),
    axis.text = element_text(color = "black", size = 11),
    axis.line = element_line(color = "black", linewidth = 0.5),
    legend.background = element_rect(fill = "white", color = "black"),
    legend.text = element_text(color = "black", size = 11),
    legend.title = element_text(color = "black", size = 12),
  )
}

# THEME SETTINGS ============================================================
# Control which theme is active and associated text colors

# Set default theme for all plots
theme_set(theme_dark_custom())

# Theme suffix for file naming: "-dark" or "-light"
theme_suffix <- "-dark"

# Text color for annotations based on theme
# Use "white" when theme_suffix == "-dark", "black" when theme_suffix == "-light"
annotation_text_color <- ifelse(theme_suffix == "-dark", "white", "black")
annotation_line_color <- ifelse(theme_suffix == "-dark", "#707070", "#555555")
# Fill color for annotations based on theme
# Use "black" when theme_suffix == "-dark", "white" when theme_suffix == "-light"
annotation_fill_color <- ifelse(theme_suffix == "-dark", "black", "white")


# COLOR PALETTES ============================================================
# Crop-specific colors for consistent visualization across analyses

# ===== Basic Crop Colors =====
# Used for simple crop differentiation (e.g., scatter plots, line plots)
# Color scheme: noPlant=aqua, wheat=purple, rice=orange, soy=pink
crop_colors <- c(
  "noPlant" = "#27B4C1",   # Aqua - control samples
  "wheat"   = "#8c4dc3",   # Purple - wheat
  "rice"    = "#FC9D33",   # Orange - rice
  "soy"     = "#FE318E"    # Pink/Magenta - soy
)

# ===== Crop-Timepoint Color Palettes =====
# Used for distinguishing timepoints within each crop type
# Organized by crop, with colors progressing from light to dark across timepoints
# 
# Wheat: light purple (#C381FD) → medium (#AB50FB) → dark purple (#510594)
# Rice: light orange (#FEB057) → medium (#F6962A) → dark brown (#B56203)
# Soy: light pink (#FE67AB) → medium (#FD358F) → dark magenta (#950445)
# noPlant: light green (#27B4C1) → medium (#177982) → dark green (#374B1B)
#
# Note: Includes both 3-point (wk0, wk10, wk40) and 5-point (wk0, wk10, wk20, wk30, wk40) timepoints
# Analyses using only wk0/wk10/wk40 will ignore the intermediate timepoints
crop_timepoint_colors <- list(
  wheat = c(
    "wk0" = "#C381FD",    # Light purple
    "wk10" = "#AB50FB",   # Medium purple
    "wk20" = "#941FF9",   # Medium-dark purple
    "wk30" = "#7307D2",   # Dark purple
    "wk40" = "#510594"    # Very dark purple
  ),
  rice = c(
    "wk0" = "#FEB057",    # Light orange
    "wk10" = "#F6962A",   # Medium orange
    "wk29" = "#F18204",   # Medium-dark orange
    "wk40" = "#B56203"    # Dark brown
  ),
  soy = c(
    "wk0" = "#FE67AB",    # Light pink
    "wk10" = "#FD358F",   # Medium pink/magenta
    "wk20" = "#FB0473",   # Dark pink
    "wk30" = "#C8045C",   # Dark magenta
    "wk40" = "#950445"    # Very dark magenta
  ),
  noPlant = c(
    "wk30" = "#27B4C1",   # teal
    "wk40" = "#177982"    # dark teal (noPlant only has wk30 and wk40 timepoints)
  )
)

# ===== Full Crop-Timepoint Color Map =====
# Named vector with all crop-timepoint combinations for direct lookup
# Used when filtering to specific timepoints (e.g., NMR analysis with wk0/wk10/wk40 only)
color_map <- c(
  # Soy: light to dark magenta
  "soy_wk0" = "#FE67AB",
  "soy_wk10" = "#FD358F",
  "soy_wk40" = "#950445",
  # Rice: light to dark orange
  "rice_wk0" = "#FEB057",
  "rice_wk10" = "#F6962A",
  "rice_wk40" = "#B56203",
  # Wheat: light to dark purple
  "wheat_wk0" = "#C381FD",
  "wheat_wk10" = "#AB50FB",
  "wheat_wk40" = "#510594"
)

# Alternative simplified crop colors for quick reference
crop_color_simple <- c(
  "soy" = "#FE318E",
  "rice" = "#FC9D33",
  "wheat" = "#884EBB"
)

# Alias for compatibility with existing .Rmd files
crop_color <- crop_color_simple


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
