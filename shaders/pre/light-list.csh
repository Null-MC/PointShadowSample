#version 430 core

layout (local_size_x = 4, local_size_y = 4, local_size_z = 4) in;

#include "/lib/common.glsl"

#include "/lib/light-list/buffer.glsl"
#include "/lib/light-list/common.glsl"


void main() {
	// compute a global thread index
	uint workGroupSize = gl_WorkGroupSize.x*gl_WorkGroupSize.y*gl_WorkGroupSize.z;
	uint workGroupIndex = gl_WorkGroupID.z*(gl_NumWorkGroups.x*gl_NumWorkGroups.y) + gl_WorkGroupID.y*(gl_NumWorkGroups.x) + gl_WorkGroupID.x;
	uint globalIndex = workGroupIndex * workGroupSize + gl_LocalInvocationIndex;

	// exit early if index is out-of-bounds
	if (globalIndex >= POINT_SHADOW_MAX_COUNT) return;

	// get light data from global list
	ap_PointLight light = iris_getPointLight(globalIndex);

	// get light position in "bin space"
	ivec3 lightBinPos = ivec3(lightList_getBinPos(light.pos));

	if (light.block != -1 && lightList_isInBounds(lightBinPos)) {
		// get local bin index of light from global list
		int lightBinIndex = lightList_getBinIndex(lightBinPos);

		// get a unique list index for this light
		uint lightIndex = atomicAdd(LightBinMap[lightBinIndex].lightCount, 1u);

		// add light to bin if index does not exceed bin count
		if (lightIndex < POINT_SHADOW_BIN_COUNT) {
			LightBinMap[lightBinIndex].lightList[lightIndex] = globalIndex;

			#ifdef POINT_SHADOW_DEBUG
				// increment global counter if debug view is active
				atomicAdd(Scene_LightCount, 1u);
			#endif
		}
	}
}
