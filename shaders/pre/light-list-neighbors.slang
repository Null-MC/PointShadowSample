import aperture;
import buffers.LightBinBuffer;
import lib.lightList.common;

static const int groupSize = 4;

RWStructuredBuffer<LightBinBuffer> lightBin;


void tryAddNeighborLights(inout uint lightCount, const in int binIndex, const in int3 neighborBinPos) {
	int neighborBinIndex = lightList_getBinIndex(neighborBinPos);
	uint neighborLightCount = clamp(lightBin[neighborBinIndex].lightCount.load(), 0u, POINT_SHADOW_BIN_COUNT);

	for (uint i = 0u; i < neighborLightCount; i++) {
		uint lightRef = lightBin[neighborBinIndex].lightList[i];

		PointLight light = ap.lights[lightRef];

		float3 light_binPos = lightList_getBinPos(light.position);

		float lightRange = ap.blocks[light.block].emission / float(POINT_SHADOW_BIN_SIZE);
		float lightRangeSq = lightRange*lightRange;

		// check light range
		float3 boxPos = clamp(light_binPos, neighborBinPos, neighborBinPos+1);
		float3 offset = boxPos - light_binPos;
		if (dot(offset, offset) >= lightRangeSq) continue;

		uint lightIndex = lightCount;
		lightCount++;

		if (lightIndex < POINT_SHADOW_BIN_COUNT) {
			lightBin[binIndex].lightList[lightIndex] = lightRef;
		}
	}
}


struct ComputeInput {
    uint groupIndex : SV_GroupIndex;
    uint3 groupPos : SV_GroupID;
    uint3 localPos : SV_GroupThreadID;
    uint3 globalPos : SV_DispatchThreadID;
};

[[shader("compute")]]
[numthreads(groupSize, groupSize, groupSize)]
void populateBinsFromNeighbors(ComputeInput input) {
	if (any(input.globalPos >= int3(LightBinGridSize))) return;

	int binIndex = lightList_getBinIndex(input.globalPos);
	uint lightCount = lightBin[binIndex].lightCount.load();
	lightCount = clamp(lightCount, 0u, POINT_SHADOW_BIN_COUNT);

	// TODO: rearrange loop to prioritize nearer bins
	for (int _z = -2; _z <= 2; _z++) {
		for (int _y = -2; _y <= 2; _y++) {
			for (int _x = -2; _x <= 2; _x++) {
				if (_x == 0 && _y == 0 && _z == 0) continue;

				int3 neighborBinPos = input.globalPos + int3(_x, _y, _z);
				if (any(neighborBinPos < 0) || any(neighborBinPos >= LightBinGridSize)) continue;

				tryAddNeighborLights(lightCount, binIndex, neighborBinPos);
			}
		}
	}

	lightBin[binIndex].lightCountFinal = lightCount;
}
