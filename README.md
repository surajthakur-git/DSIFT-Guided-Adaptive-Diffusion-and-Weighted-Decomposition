# DSIFT-Guided-Adaptive-Diffusion-and-Weighted-Decomposition
Panchromatic–Multispectral Image Fusion Using DSIFT-Guided Adaptive Diffusion and Weighted Decomposition

# 🧠 Anisotropic PCA-Based Image Fusion

This repository presents an advanced image fusion framework based on **Anisotropic PCA (Principal Component Analysis)**. The method effectively combines complementary information from multiple input images to generate a high-quality fused output.

---

## 📌 Overview

Image fusion plays a crucial role in applications like:

* Remote sensing
*Pansharpening

This project focuses on enhancing fusion quality using **anisotropic diffusion + PCA**, improving:

* Edge preservation
* Structural details
* Contrast

---

## 🚀 Main File

The core implementation of this project is:

👉 **`anisotropic_PCA.m`**

This file performs:

* Feature extraction using anisotropic diffusion
* Dimensionality reduction using PCA
* Fusion of input images

---

## 📂 Repository Structure

```
├── anisotropic_PCA.m        # Main fusion algorithm
├── anisdiff2D.m             # Anisotropic diffusion
├── DSIFTNormalization.m     # Dense SIFT normalization
├── DenseSIFT.m              # Feature extraction
├── apply_CED.m              # Coherence-enhancing diffusion
├── img_extend.m             # Image preprocessing
├── Fusion_Contrast_Exposure.m
├── Fusion_Exposure_Luminance.m
├── dataset_zip/             # Input datasets (optional)
├── README.md                # Project documentation
```

---

## ⚙️ Methodology

The proposed method includes:

1. **Preprocessing**

   * Image resizing and normalization

2. **Anisotropic Diffusion**

   * Preserves edges while smoothing noise

3. **Feature Extraction**

   * Dense SIFT-based descriptors

4. **PCA-Based Fusion**

   * Combines features into a fused representation

5. **Post-processing**

   * Enhances contrast and luminance

---

## 📊 Features

✅ Edge-preserving fusion
✅ Improved structural similarity
✅ High-quality fused output

---

## ▶️ How to Run

1. Open MATLAB
2. Set the project folder as working directory
3. Run the main file:

```matlab
anisotropic_PCA
```

---

## 📷 Results

The algorithm produces:

* Enhanced fused images
* Better contrast and detail preservation

---

## 🧪 Applications

* Satellite Image Fusion (PAN + MS)
* Medical Image Fusion (MRI + CT)
* Multi-focus Image Fusion

---

## 📌 Notes

* Large datasets are not fully included in the repository.
* You can place your own images inside the dataset folder.

---

## 👨‍💻 Author

**Suraj Thakur**

---

## ⭐ If you like this project

Give it a ⭐ on GitHub and share it!
