# Secure 5-Fold BERT Training Pipeline

## Overview
This repository provides a **5-fold stratified cross-validation** pipeline for
binary text classification using **BERT / BioBERT / ClinicalBERT**.

The pipeline is designed for **clinical and biomedical NLP**, with a focus on
reproducibility, class imbalance, and secure model loading.

---

## Key Features
- 5-fold stratified cross-validation
- Early stopping based on **AUPRC**
- Class-weighted loss for imbalanced labels
- AMP support when CUDA is available
- Safetensors-first model loading with CVE handling
- Out-of-fold predictions and ensemble inference

---

## Quick Start

### 1. Install dependencies
```bash
pip install torch transformers safetensors scikit-learn pandas numpy matplotlib packaging
```

### 2. Configure
Edit in `train_cv_bert.py`:
```python
TSV_PATH = "path/to/bert_inputs.tsv"
LABEL_NAME = "label_melanoma"
MODEL_CHOICE = "clinicalbert"
```

### 3. Run
```bash
python train_cv_bert.py
```

---

## Input
- Tab-separated `.tsv`
- Required columns:
  - `text`
  - binary label column (e.g. `label_melanoma`)

---

## Outputs
Generated under:
```
./cv_models_foldval_<model>/
```

Includes:
- Best model per fold
- Fold-level metrics
- Out-of-fold predictions
- Ensemble inference utilities

---

## Notes
- Primary metric: **AUPRC**
- Fallback metric: **AUROC**
- Safetensors are preferred for secure loading (CVE-2025-32434)

---

## License
Add an appropriate license before public release.

