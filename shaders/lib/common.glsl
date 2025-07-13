const float Gamma = 2.2;
const float PointLightBrightness = 8.0;


float saturate(const in float x) {
    return clamp(x, 0.0, 1.0);
}

vec2 saturate(const in vec2 x) {
    return clamp(x, 0.0, 1.0);
}

int sumOf(ivec3 vec) {
    return vec.x + vec.y + vec.z;
}

float maxOf(const in vec3 vec) {
    return max(max(vec[0], vec[1]), vec[2]);
}

vec3 LinearToRgb(const in vec3 color) {
    const float GammaInv = 1.0/Gamma;
    return pow(color, vec3(GammaInv));
}

vec3 RgbToLinear(const in vec3 color) {
    return pow(color, vec3(Gamma));
}
