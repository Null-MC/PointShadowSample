float getLightAttenuation(const in float lightDist, const in float lightRange) {
    float lightDistF = lightDist / lightRange;
    lightDistF = 1.0 - saturate(lightDistF);
    return lightDistF*lightDistF;
}

// returns a hardware-filtered point-light shadow map sample
float shadowPoint_sampleShadow(const in vec3 sampleDir, const in float sampleDist, const in uint index) {
    float depth = (sampleDist - ap.point.nearPlane) / (ap.point.farPlane - ap.point.nearPlane);
    return texture(pointLightFiltered, vec4(sampleDir, index), depth).r;
}

vec3 shadowPoint_sampleAll(const in vec3 localPos, const in vec3 localNormal) {
    vec3 localViewDir = -normalize(localPos);

    const float offsetBias = 0.02;
    const float normalBias = 0.16;
    vec3 localSamplePos = normalBias * localNormal + localPos;

    vec3 lighting = vec3(0.0);
    for (uint i = 0u; i < POINT_SHADOW_MAX_COUNT; i++) {
        uint lightIndex = i;

        ap_PointLight light = iris_getPointLight(i);
        if (light.block == -1) continue;

        float lightRange = iris_getEmission(light.block);

        vec3 fragToLight = light.pos - localSamplePos;
        float sampleDist = length(fragToLight);
        vec3 sampleDir = fragToLight / sampleDist;

        if (sampleDist >= lightRange) continue;

        vec3 lightColor = iris_getLightColor(light.block).rgb;
        lightColor = RgbToLinear(lightColor);

        float NoLm = max(dot(localNormal, sampleDir), 0.0);

        float lightShadow = shadowPoint_sampleShadow(-sampleDir, sampleDist - offsetBias, i);

        lightShadow *= getLightAttenuation(sampleDist, lightRange);

        lighting += NoLm * lightShadow * lightColor;
    }

    return lighting;
}
