# ATR Spectroscopy Data Similarity Analysis Report

**Analysis Date:** October 7, 2025  
**Dataset:** all_ATR_data_wide.csv  
**Total Samples:** 39  
**Duplicate Groups Analyzed:** 12  
**Pairwise Comparisons:** 14  

## Executive Summary

This analysis examined the reproducibility of ATR spectroscopy measurements by comparing samples with identical ID, timepoint, and sample type. The results reveal significant variability in measurement reproducibility, with 35.7% of comparisons showing poor similarity (r<0.80) that require investigation.

## Overall Statistics

- **Mean Correlation:** 0.756
- **Median Correlation:** 0.852  
- **Standard Deviation:** 0.278
- **Range:** 0.235 to 1.000
- **Mean RMSE:** 0.025

## Similarity Categories

| Category | Correlation Range | Count | Percentage | Status |
|----------|------------------|-------|------------|---------|
| Excellent | r ≥ 0.99 | 3 | 21.4% | ✅ Good |
| Very Good | 0.95 ≤ r < 0.99 | 2 | 14.3% | ✅ Good |
| Good | 0.90 ≤ r < 0.95 | 0 | 0.0% | ✅ Good |
| Moderate | 0.80 ≤ r < 0.90 | 4 | 28.6% | ⚠️ Monitor |
| Poor | r < 0.80 | 5 | 35.7% | ❌ Investigate |

## High Priority Issues Requiring Investigation

### 1. Root Sample Reproducibility Problems
- **ID 62, wk0, root:** r = 0.241 (Poor)
- **ID 94, wk10, root:** r = 0.235 (Poor)

**Issue:** Root samples show extremely poor reproducibility between measurement runs.  
**Recommendation:** Review root sample preparation protocol, check for sample heterogeneity, and consider homogenization improvements.

### 2. Crop Type Mismatches
- **ID 28, wk0, soil:** Wheat vs Soybean samples (r = 0.984)
- **ID 80, wk10, soil:** Wheat vs Soybean samples (r = 0.274)

**Issue:** Samples with the same ID but different crop types suggest labeling errors.  
**Recommendation:** Verify sample labels and correct database entries. The high correlation (0.984) for ID 28 is particularly concerning as it suggests these may be the same sample mislabeled.

### 3. Poor Soil Sample Reproducibility
- **ID 79, wk0, soil:** r = 0.745 (Poor)
- **ID 94, wk10, soil:** r = 0.726 (Poor)

**Issue:** Some soil samples show poor reproducibility between runs.  
**Recommendation:** Check sample storage conditions and homogenization procedures.

## Medium Priority Issues

### Sample Variability Concerns
- **ID 62, wk0, soil:** r = 0.835 (Moderate)
- **ID 87, wk10, soil:** r = 0.871 (Moderate)
- **ID 119, wk10, soil:** r = 0.852 (Moderate, but with one perfect match)

**Recommendation:** Monitor these samples and investigate if patterns emerge with similar IDs or conditions.

## Excellent Reproducibility (Low Priority)

### Perfect Matches - Possible Duplicate Files
- **ID 103, wk0, soil:** r = 1.000, RMSE = 0.000
- **ID 72, wk0, soil:** r = 1.000, RMSE = 0.000
- **ID 119, wk10, soil:** One pair with r = 1.000, RMSE = 0.000

**Recommendation:** Verify these are truly independent measurements and not duplicate file entries.

### Good Technical Replicates
- **ID 28, wk0, soil:** r = 0.984 (Very Good)
- **ID 50, wk0, soil:** r = 0.972 (Very Good)

## Detailed Investigation List

### IMMEDIATE ACTION REQUIRED

1. **ID 62 Root Samples** - Correlation 0.241
   - Files: `13C_root_soybean_pot62_0wk.dpt` (12/5/24) vs `13C_root_soybean_pot62_0wk.dpt` (12/9/24)
   - Action: Re-examine sample prep, check for contamination

2. **ID 94 Root Samples** - Correlation 0.235  
   - Files: `13C_root_soybean_pot94_10wk.dpt` (12/5/24) vs `13C_root_soybean_pot94_10wk.dpt` (12/9/24)
   - Action: Re-examine sample prep, check for contamination

3. **ID 28 Crop Mismatch** - Correlation 0.984
   - Files: `13C_soil_wheat_pot28_0wk.dpt` vs `13C_soil_soybean_pot28_0wk.dpt`
   - Action: Verify sample labels - high correlation suggests possible mislabeling

4. **ID 80 Soil Samples** - Correlation 0.274
   - Files: `13C_soil_wheat_pot80_10wk.dpt` vs `13C_soil_soybean_pot80_10wk.dpt`  
   - Action: Verify sample labels and experimental conditions

### SECONDARY REVIEW

5. **ID 79 Soil Samples** - Correlation 0.745
6. **ID 94 Soil Samples** - Correlation 0.726
7. **ID 62 Soil Samples** - Correlation 0.835

## Recommendations

### Immediate Actions
1. **Verify Sample Labels:** Check all samples with crop type mismatches
2. **Root Sample Protocol Review:** Investigate why root samples show poor reproducibility
3. **File Verification:** Confirm perfect matches are not duplicate file entries

### Quality Control Improvements
1. **Daily Standards:** Implement daily calibration standards to monitor instrument drift
2. **Sample Homogenization:** Review protocols for root sample preparation
3. **Storage Conditions:** Verify sample storage between runs
4. **Documentation:** Improve sample tracking and labeling procedures

### Data Management
1. **Flag Questionable Data:** Mark samples with poor reproducibility in the database
2. **Implement QC Thresholds:** Set minimum correlation thresholds for accepting duplicate measurements
3. **Regular Monitoring:** Establish routine similarity analysis for ongoing quality control

## Files Generated

- **Detailed Results:** `ATR/atr_similarity_analysis_results.csv`
- **This Report:** `ATR/ATR_Similarity_Analysis_Report.md`

---

*Analysis performed using Pearson correlation coefficients and RMSE calculations across 5,599 wavelength measurements from 399.87 to 3998.74 wavenumbers.*