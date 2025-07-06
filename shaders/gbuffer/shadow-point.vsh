#version 430 core

//#include "/lib/constants.glsl"
#include "/settings.glsl"

out CustomVertexData {
    vec3 modelPos;
    flat bool isFull;
    vec2 uv;
} vOut;

#include "/lib/common.glsl"


void iris_emitVertex(inout VertexData data) {
    vOut.modelPos = data.modelPos.xyz;

    vec4 shadowViewPos = iris_modelViewMatrix * data.modelPos;
    data.clipPos = iris_projectionMatrix * shadowViewPos;
}

void iris_sendParameters(in VertexData data) {
    vOut.uv = data.uv;

    ap_PointLight light = iris_getPointLight(iris_currentPointLight);
    vOut.isFull = iris_isFullBlock(light.block);
}
