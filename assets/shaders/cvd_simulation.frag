#version 460 core
#include <flutter/runtime_effect.glsl>

uniform vec2 uResolution;   // Canvas dimensions
uniform float uDpr;          // Device pixel ratio
uniform float uType;         // 0.0=Protan, 1.0=Deutan, 2.0=Tritan, 3.0=Normal
uniform float uIntensity;    // Simulation intensity / calibration (0.0 to 1.0)
uniform sampler2D uTexture;  // Image sampler

out vec4 fragColor;

// ----------------------------------------------------------------------------
// Machado (2009) Dichromacy Simulation Matrices (Column-Major)
// Pure CVD simulation without daltonization shifts or edge filtering.
// ----------------------------------------------------------------------------

const mat3 MACHADO_PROTAN = mat3(
    0.152286,  0.114503, -0.003882,
    1.052583,  0.786281, -0.004616,
   -0.204868,  0.099216,  1.008498
);

const mat3 MACHADO_DEUTAN = mat3(
    0.366474,  0.282279, -0.013580,
    0.747833,  0.677767,  0.016335,
   -0.114307,  0.039954,  0.997245
);

const mat3 MACHADO_TRITAN = mat3(
    1.255528, -0.078411,  0.004733,
   -0.076749,  0.930809,  0.691367,
   -0.178779,  0.147602,  0.303900
);

// Fast sRGB <-> Linear RGB approximations for mobile GPUs
vec3 srgbToLinear(vec3 c) {
    return c * c;
}

vec3 linearToSrgb(vec3 c) {
    return sqrt(c);
}

void main() {
    vec2 uv = FlutterFragCoord().xy / uResolution;
    vec4 rawColor = texture(uTexture, uv);

    // Early exit for Normal Vision (3.0) or zero intensity
    if (uType >= 2.5 || uIntensity <= 0.01) {
        fragColor = rawColor;
        return;
    }

    float intensity = clamp(uIntensity, 0.0, 1.0);
    vec3 rgbLinear = srgbToLinear(rawColor.rgb);

    mat3 simMatrix;
    if (uType < 0.5) {
        simMatrix = MACHADO_PROTAN;
    } else if (uType < 1.5) {
        simMatrix = MACHADO_DEUTAN;
    } else {
        simMatrix = MACHADO_TRITAN;
    }

    vec3 simRgbLinear = simMatrix * rgbLinear;
    vec3 finalLinear = mix(rgbLinear, simRgbLinear, intensity);
    vec3 finalSrgb = linearToSrgb(clamp(finalLinear, 0.0, 1.0));

    fragColor = vec4(finalSrgb, rawColor.a);
}
