# Image Denoising with Non-Local Means (NLM) and NLM-SAP

**MATLAB | Image Processing | Algorithm Implementation | Performance Evaluation**

A course project for **COMP 6771 – Image Processing** at Concordia University. This project implements the **Non-Local Means (NLM)** image denoising algorithm in MATLAB and compares its performance with Gaussian filtering, Wiener filtering, and **Non-Local Means with Shape-Adaptive Patches (NLM-SAP)**.

## Project Overview

Image denoising aims to suppress noise while preserving edges, textures, and other important image details. Unlike conventional local smoothing filters, NLM estimates pixel intensities using weighted averages of pixels whose surrounding image patches have similar patterns.

The project investigates the trade-off between noise removal, detail preservation, and computational cost across four test images.

## My Implementation

The custom MATLAB NLM implementation includes:

- Image normalization, additive Gaussian noise generation, and symmetric boundary padding.
- Extraction of square image patches for similarity comparison.
- Gaussian-weighted squared Euclidean distances between patches.
- Computation of NLM similarity weights and the normalization factor for each pixel.
- Reconstruction of the denoised image through weighted averaging.
- Quantitative and visual comparisons against other denoising methods.

**Implementation attribution:** The NLM algorithm was implemented for this project. The NLM-SAP comparison uses Joseph Salmon's publicly provided toolbox, including functions and parts of its demo scripts; it is **not** presented as an original NLM-SAP implementation.

## Experimental Setup

| Parameter | Value |
| --- | --- |
| Environment | MATLAB |
| Image resolution | 256 × 256 |
| Noise | Additive Gaussian noise, mean 0, variance 0.01 |
| NLM search window | 15 × 15 |
| NLM similarity patch | 5 × 5 |
| NLM filtering parameter (`h`) | 0.1 |
| Boundary handling | Symmetric padding |
| Evaluation metrics | MSE, RMSE, PSNR, SSIM |

Test images: **Cameraman**, **TileRoof**, **Walter Cronkite**, and **Chemical Plant**.

## Results

### PSNR comparison (dB)

| Method | Cameraman | TileRoof | Walter Cronkite | Chemical Plant |
| --- | ---: | ---: | ---: | ---: |
| Gaussian filter | 23.75 | 23.75 | 24.21 | 23.82 |
| Wiener filter | 26.12 | 25.70 | 29.53 | 26.33 |
| **NLM (implemented)** | **28.10** | **26.98** | **31.28** | **27.10** |
| NLM-SAP (toolbox) | 28.50 | 28.10 | 32.14 | 27.37 |

For the **Cameraman** image, the custom NLM implementation achieved **28.10 dB PSNR**, compared with **23.75 dB** for Gaussian filtering and **26.12 dB** for Wiener filtering. The NLM-SAP toolbox achieved **28.50 dB** on the same test.

The experiments indicate that NLM-based approaches can preserve edges and smooth regions while reducing noise more effectively than the tested baselines. Repetitive textures and highly detailed scenes remain challenging, and the NLM implementation has a substantial computational cost.

### Visual comparisons

Add a figure exported from your experiment here, for example:

```markdown
![Original, noisy, and denoised image comparisons](results/comparison.png)
```

> Only add the image reference after uploading `results/comparison.png` to this repository.

## How to Run

1. Install MATLAB and the toolboxes required by the functions used in the project (including Image Processing Toolbox functions).
2. Download or clone this repository.
3. Open the project folder in MATLAB.
4. Locate the main experiment script among the uploaded `.m` files, inspect its input-image paths and dependencies, and run it.
5. For the NLM-SAP comparison, obtain and configure the external NLM-SAP toolbox referenced below.

**Note:** The exact entry-point script and its invocation should be documented after checking the uploaded source files. This README is based on the project report, not a source-code audit.

## References and Acknowledgments

- A. Buades, B. Coll, and J.-M. Morel, *A Non-Local Algorithm for Image Denoising*, CVPR, 2005.
- C.-A. Deledalle, V. Duval, and J. Salmon, *Non-Local Methods with Shape-Adaptive Patches (NLM-SAP)*, Journal of Mathematical Imaging and Vision, 2011.
- Joseph Salmon, [NLM-SAP toolbox](https://josephsalmon.eu/code/index_codes.php?page=NLMSAP).
- [USC-SIPI Image Database](https://sipi.usc.edu/database/) (source of some test images).

## Project Report

A course report documents the methodology, experiments, and additional MSE, RMSE, and SSIM results. A public version should remove student ID and any other information you do not wish to disclose before being added to this repository.
