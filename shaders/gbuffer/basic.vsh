#version 430 core

out CustomVertexData {
    vec4 color;
    vec2 light;
    vec2 uv;
    vec3 localPos;
    vec3 localNormal;
    vec3 viewNormal;

    #ifdef RENDER_TERRAIN
        flat uint blockId;
    #endif
} vOut;

#include "/lib/common.glsl"


void iris_emitVertex(inout VertexData data) {
    vec4 viewPos = iris_modelViewMatrix * data.modelPos;
    data.clipPos = iris_projectionMatrix * viewPos;
}

void iris_sendParameters(VertexData data) {
    vOut.uv = data.uv;
    vOut.localPos = data.modelPos.xyz;
    vOut.localNormal = data.normal;
    vOut.viewNormal = iris_normalMatrix * data.normal;
    vOut.light = data.light;

    #ifdef RENDER_ENTITIES
        // This adds ambient occlusion and entity hit flash.
        vOut.color = vec4(mix(data.overlayColor.rgb, data.color.rgb, data.overlayColor.a), data.color.a);
    #else
        vOut.color = data.color;
        vOut.color.rgb *= data.ao;
    #endif

    #ifdef RENDER_TERRAIN
        vOut.blockId = data.blockId;
    #endif
}
