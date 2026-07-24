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
#   - Each PROCESSING METHOD gets a lightness ("shade") within that hue --
#     used for plots faceted/colored by plant (get_plant_palette()).
#   - Each METHOD *also* gets its own fixed hue (method_colors) -- used for
#     plots that only distinguish methods (get_method_colors()), and for
#     method x functional-group-region stacked bars, where region is the
#     lightness dimension within a method's hue (get_method_region_palette()).
#   - Lightness steps are spread across a fixed range, so a small number of
#     categories automatically get MORE contrast between shades, and a larger
#     number get proportionally smaller (but still even) steps. For stacked
#     bars specifically, region_lightness_ranks() reorders those steps so
#     ADJACENT stack segments are never two similar shades (see section 4).
#   - Colors are built in HCL space (perceptually uniform lightness across
#     all hues) rather than HSL, and the 6 base plant hues are seeded from the
#     Okabe-Ito colorblind-safe palette rather than a mechanical 360/6 split,
#     so plants stay visually distinct under protanopia/deuteranopia/tritanopia.
#
# WHAT TO EDIT
#   - plant names below (currently: miscanthus, sorghum, sugarcane, rice, maize, soy)
#     -- reorder/rename freely, the hue VALUES are fixed.
#   - method_levels below (section 4) -- your full canonical list of methods.
#   - L_range / chroma_fraction if you want lighter/darker or more/less
#     saturated overall look. Do this once; leave it alone after that so
#     colors stay consistent across every document that sources this file.
# ============================================================================

library(colorspace)

# ---- 1. Base hues (one per plant), seeded from Okabe-Ito -------------------
# Okabe-Ito hex swatches (colorblind-safe qualitative set). We drop "#0072B2"
# because its hue is only ~10 degrees from the sky-blue swatch below, and
# 6 plants only need 6 hues.
.base_swatches <- c("#18bbca", "#FFAA48", "#A36ED3", "#E24182", "#5157FF", "#87AF00")

# Extract each swatch's true HCL hue angle -- computed here, not hard-coded,
# so it matches exactly what `colorspace` uses internally on your machine.
.base_hues <- as(hex2RGB(.base_swatches), "polarLUV")@coords[, "H"]

# Map hues to plant names -- EDIT the names, keep the hue values as-is.
plant_hues <- setNames(
  .base_hues,
  c("miscanthus", "sorghum", "sugarcane", "rice", "maize", "switchgrass")  # EDIT plant names here
)

# ---- 2. Global lightness range + chroma for method ("shade") encoding -----
L_range         <- c(22, 84)  # min/max HCL luminance used across ALL plants
chroma_fraction <- 0.83       # fraction of max in-gamut chroma (keeps colors
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
# ---- 4. Method colors + method x region shading ----------------------------
# Used for plots where METHOD (not plant) is the thing getting a fixed hue:
#   (a) method_colors  -- one fixed color per method. Use this whenever a plot
#       is only distinguishing methods (e.g. one plant, several prep methods),
#       so a given method is always the same color everywhere, regardless of
#       which plant it's shown for or which other methods are present.
#   (b) get_method_region_palette() -- method x functional-group-region colors,
#       for stacked-bar plots comparing methods. Method fixes the hue (from
#       the same anchors as method_colors); region fixes the lightness.
#
# The 8 anchor hexes below were hand-picked (not derived from Okabe-Ito like
# the plant hues), so we extract their hue angles the same way .base_hues does
# above, and reuse the existing L_range / chroma_fraction for everything built
# on top of them -- one set of anchors, one lightness scheme, used everywhere.
#
# WHAT TO EDIT
#   - method_levels: ALL methods you might ever want to compare, in a fixed
#     order. The Nth name always gets the Nth swatch, so a method's color
#     never changes no matter which subset of methods is shown in a plot.
#     (Currently a placeholder of 3 -- extend to your full list, up to 8.)

# ---- 4 (revised). Method colors: generated, not hand-picked -----------------
# Golden-angle hue stepping. Each new hue is inserted into the emptiest gap
# left by prior hues -- unlimited, and stable under appending.
GOLDEN_ANGLE <- 137.50776  # degrees

golden_angle_hues <- function(n, start_hue = 15) {
  (start_hue + GOLDEN_ANGLE * (seq_len(n) - 1)) %% 360
}

# Full canonical method list. RULE: always ADD new methods at the END,
# never reorder or delete existing ones -- position in this vector is what
# determines a method's color, so reordering would repaint old figures.
method_levels <- c(
  "raw", "raw-milled", "h2oinsol-milled",
  "h2o20", "h2o30", "naoh20", "naoh30",
  "wsol", "wsol-1-2", "wsol-3-4", "wsol-5",
  "wsol-pour1", "wsol-pour2"
)

# One hue per method -- generated, no manual swatches, no cap.
method_hues <- setNames(golden_angle_hues(length(method_levels)), method_levels)

# Fixed color per method, built in HCL at one representative lightness
# (same approach as get_plant_colors() -- one swatch per category).
method_color_L <- mean(L_range)
method_colors <- setNames(
  sapply(method_hues, function(H) {
    hex(polarLUV(L = method_color_L,
                 C = max_chroma(H, method_color_L) * chroma_fraction,
                 H = H))
  }),
  names(method_hues)
)

get_method_colors <- function(methods) {
  stopifnot(all(methods %in% names(method_colors)))
  method_colors[methods]
}

#' Lightness-rank order that maximizes contrast between ADJACENT stack
#' positions, for any number of categories n. Works by stepping through the
#' sorted lightness values in increments of ceil(n/2) (mod n), so consecutive
#' stack positions land far apart in lightness instead of next to each other
#' on a simple ramp.
#' e.g. n = 5 -> c(1, 4, 2, 5, 3): position 1 gets the darkest of the 5 evenly
#' spaced lightness values, position 2 gets the 4th-darkest, etc.
region_lightness_ranks <- function(n) {
  step <- ceiling(n / 2)
  ((seq_len(n) - 1) * step) %% n + 1
}

#' Get the lightness (L) value assigned to each region -- the SAME values
#' used both to build method x region fill colors (get_method_region_palette())
#' and the grayscale key (build_region_key()). Pull this out separately
#' whenever you need to know how light/dark a region's fill will be -- e.g.
#' to decide black vs. white text on top of it (see text_color_L_threshold
#' below) -- without duplicating the ranking math.
#' @param regions character vector of region names, in stacking order.
#' @return named numeric vector, region -> L (0-100).
get_region_lightness <- function(regions, l_range = method_region_L_range) {
  n <- length(regions)
  l_sorted <- seq(l_range[1], l_range[2], length.out = n)
  setNames(l_sorted[region_lightness_ranks(n)], regions)
}

#' Threshold used everywhere we need to pick readable text color (black vs.
#' white) against a region's fill: L above this -> black text, at/below -> white.
#' Change this once here rather than in each place that draws text on a fill.
text_color_L_threshold <- 52  # lightness threshold for black vs. white text on top of a fill

#' Get a named hex color vector for every method x region combination.
#'
#' Region is the shade dimension: instead of a plain light-to-dark ramp,
#' lightness is assigned via region_lightness_ranks() so that regions sitting
#' next to each other in a stacked bar are never two similar shades -- this
#' holds regardless of how many regions you pass in.
#' NOTE on l_range: this deliberately does NOT default to the shared L_range
#' used for the plant palette. Near the very top of that range, the
#' sRGB gamut's max in-gamut chroma shrinks a lot and UNEVENLY across hues
#' (worse for blue/purple), so two colors at nominally the same L can look
#' like different lightness depending on hue, and adjacent ranks (e.g. the
#' 4th- and 5th-lightest) can collapse into looking almost the same color.
#' method_region_L_range pulls both ends in from those pinched extremes so
#' every method's hue keeps enough chroma to stay visually distinct at every
#' rank. Do this once; leave it alone after that, like L_range above.
#'
#' @param regions character vector of region names, in the order you want
#'   them stacked bottom-to-top (with position_stack(reverse = TRUE) -- see
#'   the .Rmd). This order determines the color assignment.
#' @param methods character vector of methods present (subset of names(method_hues)).
#' @return named character vector of hex colors, names like "raw_aliphatic"
method_region_L_range <- c(19, 82)  # lower than L_range -- see NOTE above
method_region_chroma_fraction <- 0.70  # higher value = more saturated, lower = more muted
get_method_region_palette <- function(regions, methods,
                                       l_range = method_region_L_range, chroma_frac = method_region_chroma_fraction) {
  stopifnot(all(methods %in% names(method_hues)))
  n <- length(regions)
  l_sorted <- seq(l_range[1], l_range[2], length.out = n)
  l_vals <- setNames(l_sorted[region_lightness_ranks(n)], regions)

  grid <- expand.grid(method = methods, region = regions,
                       stringsAsFactors = FALSE, KEEP.OUT.ATTRS = FALSE)
  grid$H <- method_hues[grid$method]
  grid$L <- l_vals[grid$region]
  grid$C <- mapply(function(h, l) max_chroma(h, l) * chroma_frac, grid$H, grid$L)
  grid$hex <- hex(polarLUV(L = grid$L, C = grid$C, H = grid$H))

  setNames(grid$hex, paste(grid$method, grid$region, sep = "_"))
}

#' Neutral (grayscale) key showing which region gets which relative lightness.
#' Because only lightness (not hue) encodes region, this single key is valid
#' for every method's color family -- you don't need one key per method.
#' @param regions character vector of region names, same order used for the plot.
#' @param labels  named character vector: display label for each region name.
build_region_key <- function(regions, labels, l_range = method_region_L_range) {
  n <- length(regions)
  l_sorted <- seq(l_range[1], l_range[2], length.out = n)
  l_vals <- l_sorted[region_lightness_ranks(n)]

  key_df <- data.frame(
    region = factor(regions, levels = regions),
    label  = unname(labels[regions]),
    L      = l_vals
  )
  key_df$fill <- gray(key_df$L / 100)
  key_df$text_color <- ifelse(key_df$L > text_color_L_threshold, "black", "white") # use dark text on light tiles, light text on dark tiles

  # NOTE: no scale_y_discrete(limits = rev(...)) here -- ggplot's default
  # discrete y-scale already puts the FIRST factor level (regions[1], e.g.
  # "aliphatic") at the bottom and the last (e.g. "sugar") at the top, which
  # is exactly the bottom-to-top order used in the bar plot's position_stack.
  ggplot(key_df, aes(x = 1, y = region, fill = fill)) +
    geom_tile(width = 1, height = 1) +
    geom_text(aes(label = label, color = text_color), size = 3.5, fontface = "bold") +
    scale_fill_identity() +
    scale_color_identity() +
    theme_void() +
    theme(
      plot.margin = margin(0, 0, 0, 0),
      panel.background = element_rect(fill = "black", color = NA)
    )
}

# ---- 4b. Preview helpers (run these interactively to sanity-check) --------

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
    rect(mi - 1, n_c - ci, mi, n_c - ci + 1, col = grid$hex[i])
  }
  axis(3, at = seq_len(n_m) - 0.5, labels = methods, tick = FALSE, las = 2)
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

#' Swatch grid of every method x region color, for a visual sanity check.
#' Rows = methods, columns = regions IN STACKING ORDER (left = bottom of bar).
preview_region_palette <- function(regions, methods = names(method_hues)) {
  pal <- get_method_region_palette(regions, methods)
  grid <- expand.grid(region = regions, method = methods, stringsAsFactors = FALSE)
  grid$hex <- pal[paste(grid$method, grid$region, sep = "_")]

  n_r <- length(regions); n_m <- length(methods)
  op <- par(mar = c(1, 6, 3, 1)); on.exit(par(op))
  plot(NA, xlim = c(0, n_r), ylim = c(0, n_m), axes = FALSE, xlab = "", ylab = "")
  for (i in seq_len(nrow(grid))) {
    mi <- match(grid$method[i], methods); ri <- match(grid$region[i], regions)
    rect(ri - 1, n_m - mi, ri, n_m - mi + 1, col = grid$hex[i])
  }
  axis(3, at = seq_len(n_r) - 0.5, labels = regions, tick = FALSE, las = 2)
  axis(2, at = seq_len(n_m) - 0.5, labels = rev(methods), tick = FALSE, las = 1)
}

# ---- 5. Material class + extraction-round grouping -------------------------
material_class_map <- c(
  "raw"             = "raw",
  "raw-milled"      = "raw",
  "h2oinsol-milled" = "insoluble",
  "h2o20"           = "other",   # ASSUMPTION: I couldn't tell from the data
  "h2o30"           = "other",   #  whether h2o20/30 & naoh20/30 belong to this
  "naoh20"          = "other",   #  series or a separate experiment -- flag
  "naoh30"          = "other",   #  and adjust if they should be elsewhere.
  "wsol"            = "soluble",
  "wsol-1-2"        = "soluble",
  "wsol-3-4"        = "soluble",
  "wsol-5"          = "soluble",
  "wsol-5-6"        = "soluble", # remaining sugarcane fraction not yet run
  "wsol-pour1"      = "soluble",
  "wsol-pour2"      = "soluble"
)

extraction_bin_map <- c(
  "wsol-1-2"   = "wsol-1-2",
  "wsol-3-4"   = "wsol-3-4",
  "wsol-5"     = "wsol-5+",
  "wsol-5-6"   = "wsol-5+",      # remaining sugarcane fraction not yet run
  "wsol"       = "wsol-pooled",      
  "wsol-pour1" = "wsol-pooled",  # pour fractions are a separate
  "wsol-pour2" = "wsol-pooled"   #  category, not part of the 1-2/3-4/5+ ladder
)


# ---- 6. Palette for material_class x extraction_bin -------------------------
material_hues <- c(raw = 25, insoluble = 145, soluble = 255)  # HCL degrees

# Lightness range used ONLY for the soluble extraction-round ramp.
# Pulled up from method_region_L_range (19-82) -- that range assumes solid
# bars with text on top; these are translucent lines/ribbons straight on a
# black background, so anything much below ~45 disappears.
soluble_L_range <- c(48, 90)

get_material_bin_palette <- function(bins = c("wsol-1-2", "wsol-3-4", "wsol-5+", "wsol-pooled"),
                                      l_range = soluble_L_range,
                                      chroma_frac = method_region_chroma_fraction) {
  flat_color <- function(H, L) hex(polarLUV(L = L, C = max_chroma(H, L) * chroma_frac, H = H))

  flat <- c(
    raw       = flat_color(material_hues[["raw"]], mean(L_range)),
    insoluble = flat_color(material_hues[["insoluble"]], mean(L_range))
  )

  n <- length(bins)
  # Straight ramp, NOT region_lightness_ranks() -- this is an ordered,
  # continuous series (extraction round), not a stacked bar needing
  # adjacent-segment contrast, so lightness should increase/decrease
  # monotonically to actually read as "progression" to a viewer.
  l_vals <- seq(l_range[1], l_range[2], length.out = n)
  soluble <- setNames(sapply(l_vals, flat_color, H = material_hues[["soluble"]]), bins)

  c(flat, soluble)
}

material_bin_palette <- get_material_bin_palette()
# ============================================================================

# ============================================================================
# THEME DEFINITIONS =========================================================

# Dark Theme using theme_minimal()
theme_dark_custom <- function() {
  theme_minimal() +
  theme(
    plot.background = element_rect(fill = "#000000", color = NA),
    panel.background = element_rect(fill = "#000000", color = NA),
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
