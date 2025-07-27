#version 430 core

layout (local_size_x = 4, local_size_y = 4, local_size_z = 4) in;

#include "/lib/common.glsl"

#include "/lib/light-list/buffer.glsl"
#include "/lib/light-list/common.glsl"


void tryAddNeighborLights(inout uint lightCount, const in int binIndex, const in ivec3 neighborBinPos) {
	int neighborBinIndex = lightList_getBinIndex(neighborBinPos);
	uint neighborLightCount = clamp(LightBinMap[neighborBinIndex].lightCount, 0u, POINT_SHADOW_BIN_COUNT);

	for (uint i = 0u; i < neighborLightCount; i++) {
		uint lightRef = LightBinMap[neighborBinIndex].lightList[i];

		ap_PointLight light = iris_getPointLight(lightRef);

		vec3 light_binPos = lightList_getBinPos(light.pos);

		float lightRange = iris_getEmission(light.block) / float(POINT_SHADOW_BIN_SIZE);
		float lightRangeSq = lightRange*lightRange;

		// check light range
		vec3 boxPos = clamp(light_binPos, neighborBinPos, neighborBinPos+1);
		vec3 offset = boxPos - light_binPos;
		if (dot(offset, offset) >= lightRangeSq) continue;

		uint lightIndex = lightCount;
		lightCount++;

		if (lightIndex < POINT_SHADOW_BIN_COUNT) {
			LightBinMap[binIndex].lightList[lightIndex] = lightRef;
		}
	}
}


void main() {
	ivec3 lightBinPos = ivec3(gl_GlobalInvocationID);
	if (any(greaterThanEqual(lightBinPos, ivec3(LightBinGridSize)))) return;

	int binIndex = lightList_getBinIndex(lightBinPos);
	uint lightCount = LightBinMap[binIndex].lightCount;
	lightCount = clamp(lightCount, 0u, POINT_SHADOW_BIN_COUNT);

	// TODO: rearrange loop to prioritize nearer bins
	for (int _z = -2; _z <= 2; _z++) {
		for (int _y = -2; _y <= 2; _y++) {
			for (int _x = -2; _x <= 2; _x++) {
				if (_x == 0 && _y == 0 && _z == 0) continue;

				ivec3 neighborBinPos = lightBinPos + ivec3(_x, _y, _z);
				if (any(lessThan(neighborBinPos, ivec3(0))) || any(greaterThanEqual(neighborBinPos, ivec3(LightBinGridSize)))) continue;

				tryAddNeighborLights(lightCount, binIndex, neighborBinPos);
			}
		}
	}

	LightBinMap[binIndex].lightCountFinal = lightCount;
}
