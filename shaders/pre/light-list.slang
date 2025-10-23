import aperture;
import buffers.SceneBuffer;
import buffers.LightBinBuffer;
import lib.lightList.common;

static const int groupSize = 4;

extern static const int NumWorkGroups;
extern static const uint POINT_SHADOW_MAX_COUNT;
extern static const bool POINT_SHADOW_DEBUG;

RWStructuredBuffer<SceneBuffer> scene;
RWStructuredBuffer<LightBinBuffer> lightBin;


struct ComputeInput {
    uint groupIndex : SV_GroupIndex;
    uint3 groupPos : SV_GroupID;
    uint3 localPos : SV_GroupThreadID;
    uint3 globalPos : SV_DispatchThreadID;
};

[[shader("compute")]]
[numthreads(groupSize, groupSize, groupSize)]
void populateBinsFromList(ComputeInput input) {
	// compute a global thread index
	uint workGroupSize = groupSize*groupSize*groupSize;
	uint workGroupIndex = input.groupPos.z*(NumWorkGroups*NumWorkGroups) + input.groupPos.y*(NumWorkGroups) + input.groupPos.x;
	uint globalIndex = workGroupIndex * workGroupSize + input.groupIndex;

	// exit early if index is out-of-bounds
	if (globalIndex >= POINT_SHADOW_MAX_COUNT) return;

	// get light data from global list
	PointLight light = ap.lights[globalIndex];

	// get light position in "bin space"
	int3 lightBinPos = int3(lightList_getBinPos(light.position));

	if (light.block != -1 && lightList_isInBounds(lightBinPos)) {
		// get local bin index of light from global list
		int lightBinIndex = lightList_getBinIndex(lightBinPos);

		// get a unique list index for this light
		uint lightIndex = lightBin[lightBinIndex].lightCount.increment();

		// add light to bin if index does not exceed bin count
		if (lightIndex < POINT_SHADOW_BIN_COUNT) {
			lightBin[lightBinIndex].lightList[lightIndex] = globalIndex;

			if (POINT_SHADOW_DEBUG) {
				// increment global counter if debug view is active
				scene[0].PointLightCount.increment();
			}
		}
	}
}
