#version 430 core

layout (local_size_x = 8, local_size_y = 8, local_size_z = 8) in;

#include "/lib/common.glsl"

#include "/lib/light-list/buffer.glsl"
#include "/lib/light-list/common.glsl"


void main() {
	ivec3 lightBinPos = ivec3(gl_GlobalInvocationID);
	if (any(greaterThanEqual(lightBinPos, ivec3(LightBinGridSize)))) return;

	int lightBinIndex = lightList_getBinIndex(lightBinPos);
	uint lightCount = LightBinMap[lightBinIndex].lightCount;

	for (uint i = 0u; i < min(lightCount, POINT_SHADOW_BIN_COUNT); i++) {
		uint lightIndex = LightBinMap[lightBinIndex].lightList[i];

		ap_PointLight light = iris_getPointLight(lightIndex);

		float lightRange = iris_getEmission(light.block);
		float lightRangeSq = lightRange*lightRange;

		//uint voxelIndex = LightBinMap[lightBinIndex].lightList[i].voxelIndex;
		//ivec3 lightVoxelPos = GetLightVoxelPos(voxelIndex);
		// TODO: get voxelPos from light.pos
		vec3 lightBinPos = lightList_getBinPos(light.pos);
		ivec3 lightVoxelPos = ivec3(lightBinPos * POINT_SHADOW_BIN_SIZE);

		for (int _z = -2; _z <= 2; _z++) {
			for (int _y = -2; _y <= 2; _y++) {
				for (int _x = -2; _x <= 2; _x++) {
					if (_x == 0 && _y == 0 && _z == 0) continue;

					ivec3 neighborBinPos = ivec3(lightBinPos) + ivec3(_x, _y, _z);

					// check light range
					ivec3 boxMin = neighborBinPos * POINT_SHADOW_BIN_SIZE;
					ivec3 boxMax = (neighborBinPos+1) * POINT_SHADOW_BIN_SIZE;
					ivec3 boxPosNearest = clamp(lightVoxelPos, boxMin, boxMax);

					vec3 lightOffset = boxPosNearest - lightVoxelPos;
					bool isInRange = dot(lightOffset, lightOffset) < lightRangeSq;

					if (isInRange && all(greaterThanEqual(neighborBinPos, ivec3(0))) && all(lessThan(neighborBinPos, ivec3(LightBinGridSize)))) {
						int neighborBinIndex = lightList_getBinIndex(neighborBinPos);
						uint neighborLightIndex = atomicAdd(LightBinMap[neighborBinIndex].lightCount, 1u);

						if (neighborLightIndex < POINT_SHADOW_BIN_COUNT) {
							LightBinMap[neighborBinIndex].lightList[neighborLightIndex] = lightIndex;
						}
					}
				}
			}
		}

		// TODO: redo this with a linear loop that skips center without continue
	}
}
