static const float lmCoordMin = ( 0.5/16.0);
static const float lmCoordMax = (15.5/16.0);
static const float lmCoordRange = lmCoordMax - lmCoordMin;


float2 LightMapNorm(float2 lightCoord) {
    return (lightCoord - lmCoordMin) / lmCoordRange;
}

float2 LightMapTex(float2 lightNorm) {
    return saturate(lightNorm) * lmCoordRange + lmCoordMin;
}
