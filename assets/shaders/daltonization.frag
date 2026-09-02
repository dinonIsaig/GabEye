#version 460 core
#include <flutter/runtime_effect.glsl>

uniform vec2 uResolution;   // Canvas dimensions
uniform float uDpr;          // Device pixel ratio
uniform float uType;         // 0.0=Protan, 1.0=Deutan, 2.0=Tritan, 3.0=Normal
uniform float uIntensity;    // Shift intensity (0.0 to 1.0)
uniform sampler2D uTexture;  // Live camera feed / frame sampler

out vec4 fragColor;

// ----------------------------------------------------------------------------
// Machado (2009) Dichromacy Simulation Matrices (Column-Major)
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
    return c * c; // Gamma ~2.0 approximation
}

vec3 linearToSrgb(vec3 c) {
    return sqrt(c);
}

// Perceived relative luminance
float getLuminance(vec3 c) {
    return dot(c, vec3(0.2126, 0.7152, 0.0722));
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

    // ========================================================================
    // 1. DICHROMACY SIMULATION & SHIFT COEFFICIENT SETUP
    // ========================================================================
    mat3 simMatrix;
    vec3 shiftWeights;
    float errChannel;

    if (uType < 0.5) {
        // Protanopia (L-cone): Shift lost red into Green (0.7x) & Blue (0.5x)
        simMatrix = MACHADO_PROTAN;
        shiftWeights = vec3(0.0, 0.7, 1.0);
    } else if (uType < 1.5) {
        // Deuteranopia (M-cone): Shift lost green into Red (0.7x) & Blue (0.5x)
        simMatrix = MACHADO_DEUTAN;
        shiftWeights = vec3(0.2, 0.0, 1.7);
    } else {
        // Tritanopia (S-cone): Shift lost blue into Red (0.8x) & Green (0.5x)
        simMatrix = MACHADO_TRITAN;
        shiftWeights = vec3(0.8, 0.7, 0.0);
    }

    vec3 simRgbLinear = simMatrix * rgbLinear;
    vec3 err = rgbLinear - simRgbLinear;

    // Isolate error based on deficiency type
    if (uType < 0.5) {
        errChannel = max(0.0, err.r);
    } else if (uType < 1.5) {
        errChannel = max(0.0, err.g);
    } else {
        errChannel = max(0.0, err.b);
    }

    vec3 shift = shiftWeights * errChannel;
    vec3 baseDaltonizedLinear = clamp(rgbLinear + (shift * intensity), 0.0, 1.0);

    // ========================================================================
    // 2. SKSL-COMPATIBLE 4-TAP LAPLACIAN EDGE ENHANCEMENT (5 TEXTURE FETCHES)
    // ========================================================================
    vec2 texelSize = 1.0 / uResolution;
    float centerLum = getLuminance(rgbLinear);

    // 4-tap cross sampling (Top, Bottom, Left, Right)
    float lumL = getLuminance(srgbToLinear(texture(uTexture, uv + vec2(-texelSize.x, 0.0)).rgb));
    float lumR = getLuminance(srgbToLinear(texture(uTexture, uv + vec2( texelSize.x, 0.0)).rgb));
    float lumT = getLuminance(srgbToLinear(texture(uTexture, uv + vec2(0.0, -texelSize.y)).rgb));
    float lumB = getLuminance(srgbToLinear(texture(uTexture, uv + vec2(0.0,  texelSize.y)).rgb));

    float laplacian = max(0.0, 4.0 * centerLum - (lumL + lumR + lumT + lumB));

    // Mask edge darkening on bright pixels to maintain vibrant colors
    float daltonizedLum = getLuminance(baseDaltonizedLinear);
    float brightPixelMask = 1.0 - smoothstep(0.65, 0.95, daltonizedLum);

    float finalEdgeDarkening = laplacian * 0.35 * intensity * brightPixelMask;
    vec3 finalLinear = clamp(baseDaltonizedLinear - vec3(finalEdgeDarkening), 0.0, 1.0);

    // ========================================================================
    // 3. CONVERT BACK TO sRGB
    // ========================================================================
    vec3 finalSrgb = linearToSrgb(finalLinear);

    fragColor = vec4(finalSrgb, rawColor.a);
}
