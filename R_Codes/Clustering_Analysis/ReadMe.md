# K-means Clustering Analysis (R)

This example demonstrates a complete **k-means clustering workflow in R**, including
data preprocessing, cluster-number evaluation, model fitting, and visualization of results.

The script is designed as a **general-purpose clustering pipeline** that can be adapted
to different tabular datasets.

---

## Contents

- `kmeans_clustering.R`  
  Full R script for data cleaning, scaling, k-means clustering, and evaluation.

- `Visualizations/`  
  Output figures generated during clustering analysis:
  - Elbow plot
  - Silhouette plot
  - Cluster visualization
  - Comparison plot

---

## Requirements

The following R packages are required:

```r
tidyverse
factoextra
cluster
data.table
```
## Example Outputs

### Elbow Method (WSS)

![Elbow Plot](/R_Codes/Clustering_Analysis/Visualizations/Elbow_Plot.png)

---

### Silhouette Analysis

![Silhouette Plot](/R_Codes/Clustering_Analysis/Visualizations/silhouette_plot.png)

---

### Cluster Visualization

![Cluster Visualization](/R_Codes/Clustering_Analysis/Visualizations/Visual_Plot.png)

---

### Method Comparison

![Comparison Plot](/R_Codes/Clustering_Analysis/Visualizations/Comparison_Plot.png)

---

## Notes

- This example demonstrates unsupervised clustering with numeric variables.
- Input data are not included.
- Users should provide their own tab-delimited dataset.

---

## Author

**Elle Wang**

