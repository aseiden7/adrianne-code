# DRIFTS Analysis — Setup Guide

This guide walks you through setting up your computer from scratch to run `DRIFTS_analysis_Camryn.Rmd`.

---

## 1. Install the software

1. **Install R**: go to [cran.r-project.org](https://cran.r-project.org/) and download/install the latest version for your OS.
2. **Install RStudio Desktop**: go to [posit.co/download/rstudio-desktop](https://posit.co/download/rstudio-desktop/) and install it.
3. **Install Git**: Macs often already have Git installed. Open **Terminal** (Applications → Utilities → Terminal) and type `git --version`. If it's not installed, a popup will offer to install the Xcode Command Line Tools — click **Install** and wait for it to finish. If that doesn't work, download Git directly from [git-scm.com/downloads](https://git-scm.com/downloads).

---

## 2. Set up your GitHub repository

The original file has a custom setting that saves the knitted HTML output to a folder called `../adrianne-code/` (Adrianne's GitHub repository). You'll want your own repository instead.

1. Go to [github.com](https://github.com/) and log in (or create an account if you don't have one).
2. Click the **+** icon (top right) → **New repository**.
3. Name it something like `camryn-drifts-code` (or whatever you'd like — just remember the name).
4. If you want to use [GitHub Pages](https://docs.github.com/en/pages/getting-started-with-github-pages/what-is-github-pages), you will need to set it to **Public**, otherwise, set it to **Private**. Then click **Create repository**.
5. On the new repo's page, copy the URL under **Quick setup** (it'll look like `https://github.com/yourusername/camryn-drifts-code.git`).
6. Open **RStudio**, then go to **File → New Project → Version Control → Git**, paste in the URL, choose where to save it locally, and click **Create Project**. This clones your empty repo and opens it as an RStudio Project.

This cloned folder is where your project will live going forward (see folder structure in Step 3).

### Update the `.Rmd` to point to your repo

At the top of `DRIFTS_analysis_Camryn.Rmd`, there's a custom knit setting:

```r
knit: (function(inputFile, encoding) {
    rmarkdown::render(inputFile, encoding = encoding,
                     output_dir = "../adrianne-code/") })
```

Change `"../adrianne-code/"` to match your repo's folder name, for example:

```r
knit: (function(inputFile, encoding) {
    rmarkdown::render(inputFile, encoding = encoding,
                     output_dir = "../camryn-drifts-code/") })
```

---

## 3. Set up your project folder structure

Inside the RStudio Project folder you just created (from Step 2), you need:

```r
your-repo-folder/
├── your-repo-folder.Rproj      (created automatically by RStudio)
├── DRIFTS_analysis_Camryn.Rmd
├── OPUS_QC_Camryn.Rmd
└── config/
    └── theme_colors_config.R
```

- Copy `DRIFTS_analysis_Camryn.Rmd` and `OPUS_QC_Camryn.Rmd` into the root of the repo folder.
- Copy the `config` folder (contains `theme_colors_config.R`) into the repo folder.

This matters because the `.Rmd` looks for the config file using this line:

```r
source(file.path(dirname(knitr::current_input()), "config/theme_colors_config.R"))
```

This means: "look in a `config` folder sitting right next to this `.Rmd` file." If the config file isn't in exactly that spot, the script will fail to find it.

---

## 4. Remove the Box-specific code (since you're not using Box)

The original script uses a Box-based environment variable (`BOX_BASE`) to build file paths so that the files can be accessed through Box on either a Mac or a PC. Since you're not using Box, you'll want to simplify this. In the setup chunk near the top of the `.Rmd`, find this:

```r
# Set Box path
box_base <- Sys.getenv("BOX_BASE") # Delete if not using Box
if (box_base == "") stop("BOX_BASE environment variable is not set!") # Delete if not using Box

# Set paths -- WILL NEED TO CHANGE THIS
dpt_folder <- file.path(box_base, "Salk Institute Project/AKS Salk files/Camryn_DRIFTSdata/DPT_files")
outputs_folder <- file.path(box_base, "Salk Institute Project/AKS Salk files/Camryn_DRIFTSdata/code_outputs")
```

Replace it with just direct paths to your own folders, for example:

```r
# Set paths -- CHANGE THESE TO MATCH YOUR SYSTEM
dpt_folder <- "/Users/Camryn/Documents/DRIFTS_data/DPT_files"      # path to your DPT files
outputs_folder <- "/Users/Camryn/Documents/DRIFTS_data/code_outputs" # path to save outputs
```

**Tips:**
- On a Mac, you can get the exact path of a folder by right-clicking it in Finder, holding **Option**, and selecting **Copy "[folder name]" as Pathname** — then paste it directly between the quotes.

- These can be anywhere on your computer — they don't need to be inside the RStudio Project/GitHub folder. In fact, it's often cleaner to keep raw data outside the Git repo (large data files don't belong in GitHub repos anyway).

---

## 5. Install the required R packages

Open the `.Rmd` in RStudio, then run this once in the R console (bottom-left pane) to install everything the script needs:

```r
install.packages(c("ggplot2", "ggridges", "readr", "stringr", "viridis",
                    "dplyr", "cowplot", "ggsignif", "tidyr",
                    "rmarkdown", "knitr", "pracma", "nc"))
```

(The packages will also auto-install if missing when you run the script, but installing everything up front avoids interruptions.)

---

## 6. Run it

1. Open `DRIFTS_analysis_Camryn.Rmd` in RStudio (double-click the `.Rproj` file first, then open the `.Rmd` from the Files pane — this ensures the working directory is set correctly).
2. Double-check the `dpt_folder` and `outputs_folder` paths in the setup chunk match your system.
3. Click **Knit** (or press Ctrl/Cmd+Shift+K).
4. The first time, RStudio may prompt you to install a few additional packages — click "Yes" if so.
5. If you want to switch to light theme figures, open theme_colors_config.R, comment out "theme_set(theme_dark_custom())" and uncomment "# theme_set(theme_minimal())". Then comment out "theme_suffix <- "-dark"" and uncomment "# theme_suffix <- "-light"" (lines 43–49; see screenshot below)

![theme-control](https://github.com/aseiden7/adrianne-code/raw/17edaca867fa2420084d23a86739e024616fc1c7/code-theme-control.png)
---

## 7. Push your work to GitHub

Once things are running, save your changes to GitHub so you have a backup and version history:

1. In RStudio, click the **Git** tab (top-right pane).
2. Check the boxes next to the files you want to save (e.g., the `.Rmd`, the `config` folder).
3. Click **Commit**, write a short message describing what you changed, click **Commit** again.
4. Click **Push** (green up-arrow icon) to upload it to GitHub.

---

## Troubleshooting

| Problem | Likely fix |
|---|---|
| `Error: 'config/theme_colors_config.R' does not exist` | Double-check the `config` folder is spelled exactly right and sits directly next to the `.Rmd`, not nested deeper. |
| `Directory does not exist: ...` | Double-check `dpt_folder` path — use the Finder "Copy as Pathname" trick above (Option + right-click) to avoid typos. |
| Packages fail to install | Make sure you have an internet connection and try running `install.packages("packagename")` one at a time to isolate which one is failing. |
| Knit button greyed out / errors about `rmarkdown` | Run `install.packages("rmarkdown")` then restart R (Session → Restart R). |
