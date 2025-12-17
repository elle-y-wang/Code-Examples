# Meta-analysis and Visualization (SMD-based)

## Overview
This repository contains code for performing **meta-analysis using standardized mean difference (SMD)**
as the effect size, and for generating **publication-quality visualizations**.

Statistical modeling is conducted using the **`metafor`** package, while forest plots and
related figures are generated using **`forestploter`** and base `metafor` diagnostic tools.

---

## Repository Structure

```
Code-Examples/
└── R_Codes/
    └── Meta-analysis/
        ├── analysis/
        ├── visualizations/
        │   ├── Cognitive_speed_only_with_full_follow_up.png
        │   ├── Funnel_plot_Cognitive_speed_reaction_time.png
        │   └── Influence_plot_Cognitive_speed_reaction_time.png
        └── README.md
```

---

## Visualizations

All figures below are generated programmatically from the meta-analysis pipeline
and saved under the `visualizations/` directory.

### Forest Plot (SMD)
![Forest plot showing SMD-based meta-analysis results](/R_Codes/Meta-analysis/Visualizations/Cognitive_speed_only_with_full_follow_up.png)

---

### Funnel Plot
![Funnel plot for assessing publication bias](/R_Codes/Meta-analysis/Visualizations/Funnel_plot_Cognitive_speed_reaction_time.png)

---

### Influence Plot
![Influence diagnostics for individual studies](/R_Codes/Meta-analysis/Visualizations/Influence_plot_Cognitive_speed_reaction_time.png)

---

## Methods (Brief)

- Effect sizes are calculated as **SMDs** using `metafor::escalc`.
- Meta-analytic models are fitted using `metafor::rma`.
- Heterogeneity statistics (Q, df, p-value, I²) are extracted from the fitted models.
- Forest plots are generated using **`forestploter`** to allow:
  - Flexible table layouts
  - Custom summary rows
  - Consistent, publication-ready styling

---

## Notes

- Forest plots are intentionally generated with `forestploter` rather than
  `metafor::forest()` to achieve better control over layout and aesthetics.
- Numeric columns (effect sizes and confidence intervals) are handled separately
  from display columns to avoid unintended type coercion.
- All figures are exported as high-resolution PNG files suitable for manuscripts
  and supplementary materials.

---

## Dependencies

Main R packages:
- `metafor`
- `forestploter`
- `dplyr`
- `grid`

---

## Intended Use

- SMD-based meta-analysis workflows
- Visualization templates for publication
- Supplementary figures for manuscripts
- Reproducible analytical demonstrations

---

## License
Specify an appropriate license before public release.

---

## Author

**Elle Wang**

