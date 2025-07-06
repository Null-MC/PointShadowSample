#version 430 core

//#include "/settings.glsl"

layout(location = 0) out vec4 outColor;

#include "/lib/common.glsl"


void iris_emitFragment() {
    vec3 fogColor = RgbToLinear(ap.world.fogColor.rgb);
    outColor = vec4(fogColor, 1.0);
}
