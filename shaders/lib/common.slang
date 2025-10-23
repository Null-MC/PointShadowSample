static const float Gamma = 2.2;
static const float PointLightBrightness = 8.0;


// T sumOf<T>(const in T vec) where T:  {
//     return vec.x + vec.y + vec.z;
// }

int sumOf(const in int3 vec) {
    return vec.x + vec.y + vec.z;
}

float maxOf(const in float3 vec) {
    return max(max(vec[0], vec[1]), vec[2]);
}

float3 LinearToRgb(const in float3 color) {
    const float GammaInv = 1.0/Gamma;
    return pow(color, float3(GammaInv));
}

float3 RgbToLinear(const in float3 color) {
    return pow(color, float3(Gamma));
}
