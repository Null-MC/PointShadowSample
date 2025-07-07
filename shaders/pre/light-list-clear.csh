#version 430 core

layout (local_size_x = 8, local_size_y = 8, local_size_z = 8) in;

#include "/lib/common.glsl"

#include "/lib/light-list/buffer.glsl"
#include "/lib/light-list/common.glsl"


void main() {
    ivec3 binPos = ivec3(gl_GlobalInvocationID);

    if (all(lessThan(binPos, ivec3(LightBinGridSize)))) {
        int binIndex = lightList_getBinIndex(binPos);

        // reset bin count to zero
        LightBinMap[binIndex].lightCount = 0u;
    }

    #ifdef POINT_SHADOW_DEBUG
        if (binPos == ivec3(0)) {
            Scene_LightCount = 0u;
        }
    #endif
}
