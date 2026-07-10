# ============================================================================
# ITQB_color_config.R
#
# Single source of truth for colors used across all DRIFTS/NMR figures.
# Source this file at the top of every script or .Rmd:
#
#     source("ITQB_color_config.R")
#     # or, if using an RStudio Project:  source(here::here("ITQB_color_config.R"))
#
# DESIGN
#   - Each plant gets a fixed hue (color family).
#   - Each PROCESSING METHOD gets a lightness ("shade") within that hue.
#   - Lightness steps are spread across a fixed range, so a small number of
#     methods automatically get MORE contrast between shades, and a larger
#     number of methods get proportionally smaller (but still even) steps.
#   - Colors are built in HCL space (perceptually uniform lightness across
#     all hues) rather than HSL, and the 6 base hues are seeded from the
#     Okabe-Ito colorblind-safe palette rather than a mechanical 360/6 split,
#     so plants stay visually distinct under protanopia/deuteranopia/tritanopia.
#
# WHAT TO EDIT
#   - plant names below (currently: miscanthus, sorghum, sugarcane, rice, maize, soy)
#     -- reorder/rename freely, the hue VALUES are fixed.
#   - L_range / chroma_fraction if you want lighter/darker or more/less
#     saturated overall look. Do this once; leave it alone after that so
#     colors stay consistent across every document that sources this file.
# ============================================================================

library(colorspace)

# ---- 1. Base hues (one per plant), seeded from Okabe-Ito -------------------
# Okabe-Ito hex swatches (colorblind-safe qualitative set). We drop "#0072B2"
# because its hue is only ~10 degrees from the sky-blue swatch below, and
# 6 plants only need 6 hues.
.base_swatches <- c("#dc267f", "#4f2bf2", "#009e28", "#ffb000","#2865ff","#fe6100")

# Extract each swatch's true HCL hue angle -- computed here, not hard-coded,
# so it matches exactly what `colorspace` uses internally on your machine.
.base_hues <- as(hex2RGB(.base_swatches), "polarLUV")@coords[, "H"]

# Map hues to plant names -- EDIT the names, keep the hue values as-is.
plant_hues <- setNames(
  .base_hues,
  c("miscanthus", "sorghum", "sugarcane", "rice", "maize", "switchgrass")  # EDIT plant names here
)

# ---- 2. Global lightness range + chroma for method ("shade") encoding -----
L_range         <- c(32, 88)  # min/max HCL luminance used across ALL plants
chroma_fraction <- 0.82       # fraction of max in-gamut chroma (keeps colors
                               # vivid without clipping near the L extremes)

# ---- 3. Build a plant x method color lookup ---------------------------------
#' Get a named hex color vector for every plant x method combination.
#'
#' @param methods character vector of processing methods currently in use.
#'   Passing a different number of methods automatically rescales the
#'   lightness contrast (fewer methods = bigger steps).
#' @param plants   character vector of plant names (default: all plants in
#'   plant_hues). Must be a subset of names(plant_hues).
#' @return named character vector of hex colors, names like "miscanthus_cryomill"
get_plant_palette <- function(methods, plants = names(plant_hues),
                              l_range = L_range, chroma_frac = chroma_fraction) {
  stopifnot(all(plants %in% names(plant_hues)))
  n <- length(methods)
  l_vals <- if (n == 1) mean(l_range) else seq(l_range[1], l_range[2], length.out = n)
  names(l_vals) <- methods

  grid <- expand.grid(plant = plants, method = methods,
                       stringsAsFactors = FALSE, KEEP.OUT.ATTRS = FALSE)
  grid$H <- plant_hues[grid$plant]
  grid$L <- l_vals[grid$method]
  grid$C <- mapply(function(h, l) max_chroma(h, l) * chroma_frac, grid$H, grid$L)
  grid$hex <- hex(polarLUV(L = grid$L, C = grid$C, H = grid$H))

  setNames(grid$hex, paste(grid$plant, grid$method, sep = "_"))
}

#' Get one color per plant (used when processing methods are faceted or separated)
get_plant_colors <- function(plants = names(plant_hues),
                             L = mean(L_range),
                             chroma_frac = chroma_fraction) {

  stopifnot(all(plants %in% names(plant_hues)))

  H <- plant_hues[plants]
  C <- mapply(function(h)
    max_chroma(h, L) * chroma_frac,
    H)

  hex_colors <- hex(polarLUV(L = L, C = C, H = H))
  setNames(hex_colors, plants)
}
# ---- 4. Preview helpers (run these interactively to sanity-check) ---------

#' Swatch grid of every plant x method color, for a visual sanity check.
preview_palette <- function(methods, plants = names(plant_hues)) {
  pal <- get_plant_palette(methods, plants)
  grid <- expand.grid(method = methods, plant = plants, stringsAsFactors = FALSE)
  grid$hex <- pal[paste(grid$plant, grid$method, sep = "_")]

  n_m <- length(methods); n_c <- length(plants)
  op <- par(mar = c(1, 6, 3, 1)); on.exit(par(op))
  plot(NA, xlim = c(0, n_m), ylim = c(0, n_c), axes = FALSE, xlab = "", ylab = "")
  for (i in seq_len(nrow(grid))) {
    ci <- match(grid$plant[i], plants); mi <- match(grid$method[i], methods)
    rect(mi - 1, n_c - ci, mi, n_c - ci + 1, col = grid$hex[i], border = "white")
  }
  axis(3, at = seq_len(n_m) - 0.5, labels = methods, tick = FALSE, las = 2)
  axis(2, at = seq_len(n_c) - 0.5, labels = rev(plants), tick = FALSE, las = 1)
}

#' Show the palette as-is next to simulated protanopia/deuteranopia/tritanopia.
check_cvd <- function(methods, plants = names(plant_hues)) {
  pal <- get_plant_palette(methods, plants)
  swatchplot(list(
    Original    = pal,
    Protanope   = protan(pal),
    Deuteranope = deutan(pal),
    Tritanope   = tritan(pal)
  ))
}

# ============================================================================
# EXAMPLE USAGE (not run automatically -- for reference)
# ============================================================================
# methods <- c("cryomill", "ionic_liquid")            # 2 methods -> big contrast
# pal <- get_plant_palette(methods)
# pal["miscanthus_cryomill"]
#
# methods4 <- c("cryomill", "ionic_liquid", "enzymatic", "alkali")  # 4 methods
# pal4 <- get_plant_palette(methods4)
#
# preview_palette(methods4)     # visual grid check
# check_cvd(methods4)           # colorblind simulation check
#
# In a ggplot (e.g. your ridge plots):
#   df$color_key <- paste(df$plant, df$method, sep = "_")
#   ggplot(df, aes(x = wavenumber, y = absorbance, color = color_key)) +
#     geom_line() +
#     scale_color_manual(values = pal4)
# ============================================================================
# THEME DEFINITIONS =========================================================

# Dark Theme using theme_minimal()
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

# HELPER FUNCTIONS ============================================================
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
