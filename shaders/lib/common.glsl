const float Gamma = 2.2;


float saturate(const in float x) {
    return clamp(x, 0.0, 1.0);
}

int sumOf(ivec3 vec) {
    return vec.x + vec.y + vec.z;
}

vec3 LinearToRgb(const in vec3 color) {
    const float GammaInv = 1.0/Gamma;
    return pow(color, vec3(GammaInv));
}

vec3 RgbToLinear(const in vec3 color) {
    return pow(color, vec3(Gamma));
}
