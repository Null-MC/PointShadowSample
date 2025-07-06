const float PI = 3.14159265358;
const float TAU = PI * 2.0;
const float EPSILON = 1e-6;

const float GoldenAngle = PI * (3.0 - sqrt(5.0));
const float PHI = (1.0 + sqrt(5.0)) / 2.0;

const vec3 luma_factor = vec3(0.2126, 0.7152, 0.0722);


float maxOf(const in vec2 vec) {return max(vec[0], vec[1]);}
float maxOf(const in vec3 vec) {return max(max(vec[0], vec[1]), vec[2]);}

float minOf(const in vec2 vec) {return min(vec[0], vec[1]);}
float minOf(const in vec3 vec) {return min(min(vec[0], vec[1]), vec[2]);}

int sumOf(ivec3 vec) {return vec.x + vec.y + vec.z;}
float sumOf(vec3 vec) {return vec.x + vec.y + vec.z;}

vec3 LinearToRgb(const in vec3 color) {
    vec3 is_high = step(0.00313066844250063, color);
    vec3 higher = 1.055 * pow(color, vec3(1.0/2.4)) - 0.055;
    vec3 lower = color * 12.92;

    return mix(lower, higher, is_high);
}

vec3 RgbToLinear(const in vec3 color) {
    vec3 is_high = step(0.0404482362771082, color);
    vec3 higher = pow((color + 0.055) / 1.055, vec3(2.4));
    vec3 lower = color / 12.92;

    return mix(lower, higher, is_high);
}

float luminance(const in vec3 color) {
   return dot(color, luma_factor);
}

float saturate(const in float x) {return clamp(x, 0.0, 1.0);}
vec2 saturate(const in vec2 x) {return clamp(x, 0.0, 1.0);}
vec3 saturate(const in vec3 x) {return clamp(x, 0.0, 1.0);}
