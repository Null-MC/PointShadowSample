float sample_PointLightShadow(const in vec3 sampleDir, const in float sampleDist, const in uint index) {
    float depth = (sampleDist - ap.point.nearPlane) / (ap.point.farPlane - ap.point.nearPlane);
    return texture(pointLightFiltered, vec4(sampleDir, index), depth).r;
}

float sample_PointLight(const in vec3 fragToLight, const in float lightRange, const in float bias, const in uint index) {
    float sampleDist = length(fragToLight);
    vec3 sampleDir = fragToLight / sampleDist;

    float light_shadow = 0.0;
    if (sampleDist < lightRange) {
        light_shadow = sample_PointLightShadow(sampleDir, sampleDist - bias, index);
    }

    return light_shadow;
}
