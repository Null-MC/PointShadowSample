#version 430 core

#include "/settings.glsl"

layout(location = 0) out vec4 outColor;

#include "/lib/common.glsl"


void iris_emitFragment() {
    outColor = vec4(ap.world.fogColor.rgb, 1.0);
}
