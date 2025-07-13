#version 430 core

in CustomVertexData {
    vec3 modelPos;
    flat bool isFull;
    vec2 uv;
} vIn;

#include "/lib/common.glsl"


void iris_emitFragment() {
    vec2 mLight;
    vec4 mColor;
    vec2 mUV = vIn.uv;
    iris_modifyBase(mUV, mColor, mLight);

    float alpha = iris_sampleBaseTex(mUV).a;

    float near = vIn.isFull ? 0.5 : 0.49999;
    if (clamp(vIn.modelPos, -near, near) == vIn.modelPos) alpha = 0.0;

    const float alphaThreshold = 0.2;
    if (alpha < alphaThreshold) discard;
}
