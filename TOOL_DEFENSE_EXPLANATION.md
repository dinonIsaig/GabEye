# GabEye: Technical Tool Defense & Implementation Guide
## Architecture, Mathematical Foundations, Algorithmic Design, and Feature Explanations

---

### Executive Summary

**GabEye** is an advanced, real-time visual assistance and Color Vision Deficiency (CVD) diagnostic mobile application developed with **Flutter**. Designed specifically to empower individuals with Protanopia, Deuteranopia, or Tritanopia, GabEye combines GPU-accelerated GLSL shader image processing, clinical quantitative diagnostic algorithms, adaptive machine learning color classification, and on-device computer vision.

This document serves as the **authoritative defense guide** for technical panels, thesis examiners, and tool demonstrations. It details the exact mathematical formulas, software architecture, algorithm design choices, and code implementations across all key features in the codebase.

---

## 1. System Architecture & Design Philosophy

GabEye strictly follows an **Offline-First, Hardware-Accelerated, Accessible Architecture**:

```
+-----------------------------------------------------------------------------------+
|                                 USER INTERFACE                                    |
|   Vision Lens Screen | D-15 Assessment | Vision Profile | Interactive Reports      |
+-----------------------------------------------------------------------------------+
                                         |
                                         v
+-----------------------------------------------------------------------------------+
|                              REACTIVE CORE SERVICES                               |
|   VisionProfileService (Singleton ValueNotifier) <---> Local Diagnostic State     |
+-----------------------------------------------------------------------------------+
          |                                      |                               |
          v                                      v                               v
+-----------------------+              +-------------------+          +-------------------+
|  GPU Daltonization    |              |  Dart Isolates    |          |  On-Device ML Kit |
|  GLSL SkSL Shader     |              |  KNN Classifier   |          |  TFLite Detector  |
|  (Machado Matrices &  |              |  (Cylindrical HSV |          |  (Object Bounding |
|   Laplacian Edges)    |              |   ISCC-NBS 265)   |          |   Box & Labeler)  |
+-----------------------+              +-------------------+          +-------------------+
          |                                      |                               |
          +--------------------------------------+-------------------------------+
                                         |
                                         v
+-----------------------------------------------------------------------------------+
|                               HARDWARE & ENGINE                                   |
|   Flutter Impeller / Skia  |  Device Camera API  |  Flutter TTS & Haptic Engine   |
+-----------------------------------------------------------------------------------+
```

### Key Technical Strategies
1. **Zero-Latency GPU Pipeline**: Daltonization processing runs at 60 FPS directly on the mobile GPU using custom GLSL shaders compiled via Flutter’s SkSL / Impeller engine.
2. **Isolate Thread Isolation**: Heavy mathematical tasks (e.g., K-Nearest Neighbors color search across 265 ISCC-NBS color centroids) run off the main UI thread via **Dart Isolates**, eliminating UI micro-stutters.
3. **Closed-Loop Calibration**: Clinical D-15 diagnostic results automatically configure GLSL shader uniforms (`uType` and `uIntensity`), tailoring vision enhancement to the user's specific deficiency type and severity.

---

## 2. Feature 1: Real-Time GPU Daltonization Shader Engine

### 2.1 Technical Purpose
Standard color blindness filters often rely on naive RGB shifts that distort non-affected colors or reduce contrast. GabEye implements a **physically-motivated spectral shift algorithm** combined with **4-tap Laplacian edge enhancement**, operating in linear RGB space on the GPU.

* **Primary Code Files**:
  * Shader Source: [`assets/shaders/daltonization.frag`](file:///c:/Users/DinonIsaig/Documents/GabEye/assets/shaders/daltonization.frag)
  * Flutter Widget Binding: [`lib/core/widgets/daltonization_shader_widget.dart`](file:///c:/Users/DinonIsaig/Documents/GabEye/lib/core/widgets/daltonization_shader_widget.dart)

### 2.2 Mathematical & Physical Model

#### Step 1: Linear RGB Conversion
Mobile camera textures are in non-linear sRGB space. To perform linear color space transformations without perceptual distortion, the shader converts sRGB to linear RGB using a mobile-optimized gamma approximation ($\gamma \approx 2.0$):
$$\vec{C}_{\text{linear}} = \vec{C}_{\text{sRGB}}^2$$

#### Step 2: Dichromacy Simulation via Machado et al. (2009)
The shader calculates how a color-blind eye perceives the pixel by applying scientifically validated dichromacy simulation matrices $M_{\text{dichromat}}$ (Machado et al., 2009):
$$\vec{C}_{\text{sim}} = M_{\text{dichromat}} \cdot \vec{C}_{\text{linear}}$$

The simulation matrices implemented in GLSL column-major format are:
* **Protanopia (L-cone loss)**:
  $$M_{\text{protan}} = \begin{bmatrix} 0.152286 & 1.052583 & -0.204868 \\ 0.114503 & 0.786281 & 0.099216 \\ -0.003882 & -0.004616 & 1.008498 \end{bmatrix}^T$$
* **Deuteranopia (M-cone loss)**:
  $$M_{\text{deutan}} = \begin{bmatrix} 0.366474 & 0.747833 & -0.114307 \\ 0.282279 & 0.677767 & 0.039954 \\ -0.013580 & 0.016335 & 0.997245 \end{bmatrix}^T$$
* **Tritanopia (S-cone loss)**:
  $$M_{\text{tritan}} = \begin{bmatrix} 1.255528 & -0.076749 & -0.178779 \\ -0.078411 & 0.930809 & 0.147602 \\ 0.004733 & 0.691367 & 0.303900 \end{bmatrix}^T$$

#### Step 3: Error Differential Vector Calculation
The spectral energy lost due to photopigment deficiency is isolated by calculating the difference vector:
$$\vec{E} = \vec{C}_{\text{linear}} - \vec{C}_{\text{sim}}$$

The target error channel ($E_{\text{channel}}$) is extracted depending on deficiency type:
$$E_{\text{channel}} = \begin{cases} \max(0, E_R), & \text{for Protanopia} \\ \max(0, E_G), & \text{for Deuteranopia} \\ \max(0, E_B), & \text{for Tritanopia} \end{cases}$$

#### Step 4: Tailored Spectral Shift Redistribution
The lost information is shifted into visible spectral channels using calibrated shift weight vectors $\vec{W}_{\text{shift}}$:
$$\vec{S} = \vec{W}_{\text{shift}} \cdot E_{\text{channel}}$$
$$\vec{C}_{\text{daltonized}} = \text{clamp}\left(\vec{C}_{\text{linear}} + \alpha \cdot \vec{S}, \, 0, \, 1\right)$$
where $\alpha \in [0.0, 1.0]$ is the calibrated shift intensity uniform (`uIntensity`).

* **Shift Weights**:
  * Protanopia ($\vec{W} = [0.0, 0.7, 1.0]^T$): Shifts lost red into Green and Blue.
  * Deuteranopia ($\vec{W} = [2.5, 0.0, 4.0]^T$): Shifts lost green into Red and Blue.
  * Tritanopia ($\vec{W} = [0.8, 1.7, 0.0]^T$): Shifts lost blue into Red and Green.

#### Step 5: SkSL-Compatible 4-Tap Laplacian Edge Enhancement
When colors are shifted, structural boundaries can lose luminance contrast. GabEye solves this on GPU by cross-sampling 5 texture taps (Center, Left, Right, Top, Bottom) to calculate the Laplacian luminance derivative:
$$Y = 0.2126 R_{\text{linear}} + 0.7152 G_{\text{linear}} + 0.0722 B_{\text{linear}}$$
$$\Delta_{\text{Laplacian}} = \max\left(0, \, 4 Y_{\text{center}} - (Y_{\text{left}} + Y_{\text{right}} + Y_{\text{top}} + Y_{\text{bottom}})\right)$$

To prevent edge darkening on bright pixels (which could wash out light hues), a smoothstep luminance mask is applied:
$$\text{Mask}_{\text{bright}} = 1.0 - \text{smoothstep}(0.65, \, 0.95, \, Y_{\text{daltonized}})$$
$$\text{EdgeDarkening} = \Delta_{\text{Laplacian}} \cdot 0.35 \cdot \alpha \cdot \text{Mask}_{\text{bright}}$$
$$\vec{C}_{\text{final\_linear}} = \text{clamp}\left(\vec{C}_{\text{daltonized}} - \text{EdgeDarkening}, \, 0, \, 1\right)$$

#### Step 6: Gamma Re-encoding to sRGB
$$\vec{C}_{\text{final\_sRGB}} = \sqrt{\vec{C}_{\text{final\_linear}}}$$

---

## 3. Feature 2: Quantitative Farnsworth D-15 Diagnostic Engine

### 3.1 Technical Purpose
Rather than relying on simple subjective screening, GabEye embeds a clinically validated diagnostic tool based on the **Farnsworth D-15 Dichotomous Test**. The app calculates quantitative error vectors using **Vingrys & King-Smith (1988) quantitative moment analysis**.

* **Primary Code Files**:
  * Scoring Engine: [`lib/features/assessment/services/scoring_service.dart`](file:///c:/Users/DinonIsaig/Documents/GabEye/lib/features/assessment/services/scoring_service.dart)
  * Assessment Screens: [`lib/features/assessment/screens/assessment_screen.dart`](file:///c:/Users/DinonIsaig/Documents/GabEye/lib/features/assessment/screens/assessment_screen.dart)

### 3.2 Mathematical Formulation & Moment Analysis

The test consists of a fixed Pilot Cap (Cap 0) and 15 moveable color caps arranged by chromaticity in CIE 1960 LUV ($u, v$) space.

```
                  Pilot Cap (0)
                   /          \
              Cap 1            Cap 15
             /                      \
         Cap 2                      Cap 14
           |                          |
         Cap 3                      Cap 13
             \                      /
              Cap 4 --- ... --- Cap 12
```

#### Step 1: Chromaticity Difference Vectors
For a user's arranged sequence $[c_0, c_1, c_2, \dots, c_{15}]$, difference vectors $(\Delta u_i, \Delta v_i)$ are computed:
$$\Delta u_i = u(c_{i+1}) - u(c_i), \quad \Delta v_i = v(c_{i+1}) - v(c_i) \quad \text{for } i = 0 \dots 14$$

#### Step 2: Total Error Score (TES)
$$\text{TES} = \sum_{i=0}^{14} \sqrt{(\Delta u_i)^2 + (\Delta v_i)^2}$$

#### Step 3: Major and Minor Moments ($S_{uu}, S_{vv}, S_{uv}$)
The distribution of error vectors in chromaticity space is evaluated using moment tensors:
$$S_{uu} = \sum_{i=0}^{14} (\Delta u_i)^2, \quad S_{vv} = \sum_{i=0}^{14} (\Delta v_i)^2, \quad S_{uv} = \sum_{i=0}^{14} (\Delta u_i \cdot \Delta v_i)$$

#### Step 4: Scatter Ellipse Metrics
* **Major Axis Radius ($R_{\text{major}}$)** and **Minor Axis Radius ($R_{\text{minor}}$)**:
  $$R_{\text{major}} = \sqrt{\frac{S_{uu} + S_{vv} + \sqrt{(S_{uu} - S_{vv})^2 + 4 S_{uv}^2}}{2}}$$
  $$R_{\text{minor}} = \sqrt{\frac{S_{uu} + S_{vv} - \sqrt{(S_{uu} - S_{vv})^2 + 4 S_{uv}^2}}{2}}$$

* **Confusion Index ($C$-Index)**:
  Quantifies overall severity relative to a perfect arrangement ($\text{TES}_{\text{perfect}} = 117.5$):
  $$C\text{-Index} = \frac{\text{TES}_{\text{user}}}{\text{TES}_{\text{perfect}}} = \frac{\text{TES}_{\text{user}}}{117.5}$$

* **Selectivity Index ($S$-Index)**:
  Quantifies how polarized or focused the confusion scatter is along a specific axis:
  $$S\text{-Index} = \frac{R_{\text{major}}}{R_{\text{minor}}}$$

* **Confusion Axis Angle ($\theta$)**:
  $$\theta = \frac{1}{2} \text{atan2}\left(2 S_{uv}, \, S_{uu} - S_{vv}\right)$$

#### Step 5: Clinical Classification
The resulting angle $\theta$ maps precisely to clinical deficiency axes:
* **Protan Axis**: Angle near $+0.7^\circ$
* **Deutan Axis**: Angle between $-65^\circ$ and $-70^\circ$
* **Tritan Axis**: Angle between $-80^\circ$ and $-90^\circ$
* **Severity Bands**:
  * Normal Vision: $C\text{-Index} \le 1.25$
  * Moderate Deficiency: $1.25 < C\text{-Index} \le 1.75$
  * Severe Deficiency: $C\text{-Index} > 1.75$

---

## 4. Feature 3: Dynamic Profile Calibration Pipeline

### 4.1 Technical Purpose
GabEye bridges clinical diagnostics directly with real-time UI rendering. The diagnostic outcome from the Farnsworth D-15 test dynamically configures the GLSL Daltonization shader uniforms (`uType` and `uIntensity`) via a reactive singleton service.

* **Primary Code File**: [`lib/core/services/vision_profile_service.dart`](file:///c:/Users/DinonIsaig/Documents/GabEye/lib/core/services/vision_profile_service.dart)

### 4.2 Uniform Mapping Pipeline

```
[D15ScoreResult] 
      │
      ├──> diagnosisType ---> uType (0.0=Protan, 1.0=Deutan, 2.0=Tritan, 3.0=Normal)
      │
      └──> severity & cIndex ---> recommendedIntensity ---> uIntensity (0.0 to 1.0)
```

#### Shader Type Uniform Mapping (`uType`)
$$\text{uType} = \begin{cases} 0.0 & \text{Protanopia / Protanomaly} \\ 1.0 & \text{Deuteranopia / Deuteranomaly} \\ 2.0 & \text{Tritanopia / Tritanomaly} \\ 3.0 & \text{Normal Vision / Unclassified} \end{cases}$$

#### Intensity Uniform Calibration (`uIntensity`)
$$\text{uIntensity} = \begin{cases} 
0.0 & \text{Severity = None (Normal)} \\
\text{clamp}\left(0.40 + \frac{C\text{-Index} - 1.0}{1.5} \times 0.25, \, 0.40, \, 0.65\right) & \text{Severity = Moderate} \\
\text{clamp}\left(0.70 + \frac{C\text{-Index} - 2.5}{1.5} \times 0.30, \, 0.70, \, 1.00\right) & \text{Severity = Severe}
\end{cases}$$

---

## 5. Feature 4: ISCC-NBS Cylindrical HSV K-Nearest Neighbors (KNN) Color Classifier

### 5.1 Technical Purpose
For color-blind individuals, identifying isolated colors (e.g., clothes, fruit maturity, wiring) is difficult. GabEye provides real-time color naming using a **K-Nearest Neighbors (KNN) classifier** trained on the standard **ISCC-NBS System of Color Designation** (265 color categories).

* **Primary Code Files**:
  * Classifier: [`lib/features/knn/services/knn_color_classifier.dart`](file:///c:/Users/DinonIsaig/Documents/GabEye/lib/features/knn/services/knn_color_classifier.dart)
  * Isolate Offloader: [`lib/features/knn/services/knn_isolate_worker.dart`](file:///c:/Users/DinonIsaig/Documents/GabEye/lib/features/knn/services/knn_isolate_worker.dart)
  * Dataset: [`lib/features/knn/models/iscc_nbs_color_dataset.dart`](file:///c:/Users/DinonIsaig/Documents/GabEye/lib/features/knn/models/iscc_nbs_color_dataset.dart)

### 5.2 Mathematical Model: Cylindrical HSV Distance with Adaptive Weights

Standard Euclidean distance in RGB or straight HSV fails because Hue ($H$) is circular ($0^\circ = 360^\circ$) and Saturation ($S$) compresses Hue distance near zero. GabEye solves this using **Cylindrical Polar Coordinates**.

#### Cylindrical Distance Formula
Given a target pixel $(H_1, S_1, V_1)$ and dataset entry $(H_2, S_2, V_2)$:

1. **Angular Difference**:
   $$\Delta H = |H_1 - H_2| \pmod{360^\circ}$$
   $$d_H = \begin{cases} \Delta H & \text{if } \Delta H \le 180^\circ \\ 360^\circ - \Delta H & \text{if } \Delta H > 180^\circ \end{cases}$$

2. **Chromatic Distance Squared ($d_{\text{chroma}}^2$)**:
   Using the polar law of cosines:
   $$d_{\text{chroma}}^2 = S_1^2 + S_2^2 - 2 S_1 S_2 \cos(d_H \cdot \frac{\pi}{180})$$

3. **Value/Luminance Distance Squared ($d_V^2$)**:
   $$d_V^2 = (V_1 - V_2)^2$$

4. **Weighted Cylindrical Distance ($d_{\text{total}}^2$)**:
   $$d_{\text{total}}^2 = w_C \cdot d_{\text{chroma}}^2 + w_V \cdot d_V^2$$

#### Chromaticity-Adaptive Dynamic Weighting ($w_C, w_V$)
Camera sensors experience shadow and highlight variations. GabEye dynamically adjusts weighting based on target chromaticity:

$$\text{If } S_1 > 0.12 \text{ and } V_1 > 0.15 \text{ (Chromatic Target):}$$
$$w_C = 3.0, \quad w_V = 1.2 \quad \implies \text{Prioritizes hue/saturation; suppresses shadow sensitivity}$$

$$\text{Else (Achromatic Target: White, Gray, Black):}$$
$$w_C = 1.0, \quad w_V = 3.0 \quad \implies \text{Prioritizes brightness; suppresses hue sensor noise}$$

#### Inverse-Distance Weighted KNN Voting ($K > 1$)
For $K > 1$, neighbor votes are weighted inversely by distance:
$$W_i = \frac{1}{\sqrt{d_{\text{total}, i}^2} + 0.0001}$$

The class label receiving the maximum sum of $W_i$ is selected. For $K=1$, an optimized $O(N)$ single-pass nearest centroid search is executed without array allocations.

---

## 6. Feature 5: On-Device Real-Time Object Detection Pipeline

### 6.1 Technical Purpose
To assist users in spatial navigation and contextual object recognition, GabEye incorporates real-time on-device object detection using **Google ML Kit** and custom fine-grained **TensorFlow Lite (`.tflite`)** models.

* **Primary Code Files**:
  * Service: [`lib/core/services/object_detection_service.dart`](file:///c:/Users/DinonIsaig/Documents/GabEye/lib/core/services/object_detection_service.dart)
  * Frame Ingestion: [`lib/core/services/camera_frame_ingestion_service.dart`](file:///c:/Users/DinonIsaig/Documents/GabEye/lib/core/services/camera_frame_ingestion_service.dart)

### 6.2 Implementation Highlights
1. **Dual Detection Modes**:
   * `DetectionMode.stream`: High-efficiency streaming pipeline for live camera overlays.
   * `DetectionMode.single`: Fine-grained single-frame scan for zoomed regions of interest (ROI).
2. **Confidence Thresholding**: Set to `0.35` with `maximumLabelsPerObject = 3`, balancing detection sensitivity with label accuracy.
3. **Format Ingestion**: Converts Android `YUV_420_888` and iOS `BGRA8888` live camera buffers into uncompressed plane streams for on-device inference without memory leaks.

---

## 7. Feature 6: Multi-Modal Accessibility (Auditory & Haptic Feedback)

### 7.1 Technical Purpose
To meet **WCAG 2.1 AA/AAA accessibility standards**, GabEye ensures that vision-impaired and color-blind users receive real-time non-visual feedback.

* **Primary Code File**: [`lib/core/services/auditory_feedback_service.dart`](file:///c:/Users/DinonIsaig/Documents/GabEye/lib/core/services/auditory_feedback_service.dart)

### 7.2 Core Capabilities
1. **Low-Latency Text-to-Speech (TTS)**: Spoken announcements for detected object labels and sampled ISCC-NBS color names.
2. **Throttle Protection**: Speech calls are throttled to prevent overlapping voice feedback during continuous frame sampling.
3. **Haptic Pulse Feedback**: Provides physical vibration cues when the camera crosshair locks onto a distinct color boundary.

---

## 8. Feature 7: Clinical PDF Diagnostic Report Generation

### 8.1 Technical Purpose
Users can export their quantitative Farnsworth D-15 assessment findings into a formal PDF report to share with optometrists or ophthalmologists.

* **Primary Code File**: [`lib/core/services/pdf_report_service.dart`](file:///c:/Users/DinonIsaig/Documents/GabEye/lib/core/services/pdf_report_service.dart)

### 8.2 PDF Elements
* **Vingrys Polar Scatter Plot**: Vector graphic rendering of the user's cap arrangement in $u, v$ chromaticity space.
* **Cap Sequence Progression Diagram**: Step-by-step visual line graph showing order crossings.
* **Quantitative Metrics Summary Table**: Displays TES, $C$-Index, $S$-Index, and Confusion Axis Angle ($\theta$).
* **Personalized Ergonomic Recommendations**: Clinical tips tailored to the diagnosed severity level.

---

## 9. Comprehensive Tool Defense Q&A Cheatsheet

Use this quick-reference matrix when defending the application in front of technical panels and evaluators:

| Panel Question | Technical & Mathematical Answer | Primary File Reference |
| :--- | :--- | :--- |
| **"Why process Daltonization on GPU instead of CPU?"** | CPU-based pixel manipulation in Flutter Dart produces heavy frame drops ($\approx 5\text{--}15 \text{ FPS}$). GLSL fragment shaders execute parallel matrix-vector ops per pixel directly on GPU texture hardware at **60 FPS**. | [`assets/shaders/daltonization.frag`](file:///c:/Users/Daltonization.frag) <br> [`daltonization_shader_widget.dart`](file:///c:/Users/DinonIsaig/Documents/GabEye/lib/core/widgets/daltonization_shader_widget.dart) |
| **"Which dichromacy model do you use?"** | We use **Machado et al. (2009)** dichromacy simulation matrices, which model L-, M-, and S-cone spectral loss in linear RGB space. | [`daltonization.frag:L16-L32`](file:///c:/Users/DinonIsaig/Documents/GabEye/assets/shaders/daltonization.frag#L16-L32) |
| **"How do you preserve edge details when shifting colors?"** | We implement a **SkSL-compatible 4-tap Laplacian cross-sampler** directly in the shader. It calculates high-frequency luminance gradients and applies structural edge sharpening masked by a bright-pixel luminance mask. | [`daltonization.frag:L98-L116`](file:///c:/Users/DinonIsaig/Documents/GabEye/assets/shaders/daltonization.frag#L98-L116) |
| **"How is the shader calibrated to the user's eyes?"** | The **Farnsworth D-15 diagnostic test** calculates the user's $C$-Index and deficiency axis. `VisionProfileService` maps these clinical metrics directly into the shader's `uType` and `uIntensity` uniforms. | [`vision_profile_service.dart:L37-L90`](file:///c:/Users/DinonIsaig/Documents/GabEye/lib/core/services/vision_profile_service.dart#L37-L90) |
| **"Why use Cylindrical HSV space for KNN color classification?"** | Euclidean distance in standard RGB or flat HSV distorts color relationships. Cylindrical polar space ($d_{\text{chroma}}^2 = S_1^2 + S_2^2 - 2 S_1 S_2 \cos \Delta H$) accurately models human color perception. | [`knn_color_classifier.dart:L102-L124`](file:///c:/Users/DinonIsaig/Documents/GabEye/lib/features/knn/services/knn_color_classifier.dart#L102-L124) |
| **"How do you handle shadow/lighting variations in live camera color detection?"** | We use **Chromaticity-Adaptive Dynamic Weighting**: for chromatic colors ($S > 0.12, V > 0.15$), $w_C = 3.0$ and $w_V = 1.2$, suppressing brightness sensitivity so shadows don't flip color labels. | [`knn_color_classifier.dart:L39-L41`](file:///c:/Users/DinonIsaig/Documents/GabEye/lib/features/knn/services/knn_color_classifier.dart#L39-L41) |
| **"How do you prevent UI freezing during KNN searches?"** | KNN centroid matching runs off the main UI thread using **Dart Isolates** (`knn_isolate_worker.dart`), leaving the main thread free to render at 60 FPS. | [`knn_isolate_worker.dart`](file:///c:/Users/DinonIsaig/Documents/GabEye/lib/features/knn/services/knn_isolate_worker.dart) |
| **"How is Farnsworth D-15 scored clinically?"** | We implement **Vingrys & King-Smith (1988) moment analysis**, calculating Total Error Score (TES), Confusion Index ($C$-Index), Selectivity Index ($S$-Index), and confusion axis angle ($\theta$) in CIE 1960 LUV space. | [`scoring_service.dart:L82-L260`](file:///c:/Users/DinonIsaig/Documents/GabEye/lib/features/assessment/services/scoring_service.dart#L82-L260) |

---

### Conclusion

GabEye represents a robust synthesis of **medical optics, high-performance GPU computer graphics, accessibility engineering, and machine learning**. By grounding Daltonization in Machado's simulation models, Farnsworth D-15 quantitative moment analysis, and ISCC-NBS cylindrical KNN classification, GabEye provides a scientifically defensible, real-time visual assistance platform.
