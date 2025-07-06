#version 430 core

layout (local_size_x = 8, local_size_y = 8, local_size_z = 8) in;

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

	ap_PointLight light = iris_getPointLight(globalIndex);

	// get light bin index
	vec3 voxelPos = voxel_GetBufferPosition(light.pos);
	if (voxel_isInBounds(voxelPos) && light.block != -1) {
		ivec3 lightBinPos = ivec3(floor(voxelPos / LIGHT_BIN_SIZE));
		int lightBinIndex = GetLightBinIndex(lightBinPos);

		// get a unique list index for this light
		uint lightIndex = atomicAdd(LightBinMap[lightBinIndex].shadowLightCount, 1u);

		// add light to bin if index does not exceed bin count
		if (lightIndex < POINT_SHADOW_BIN_COUNT) {
			LightBinMap[lightBinIndex].lightList[lightIndex] = globalIndex;

			#ifdef POINT_SHADOW_DEBUG
				atomicAdd(Scene_LightCount, 1u);
			#endif
		}
	}
}
