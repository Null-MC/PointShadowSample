import aperture;
import buffers.SceneBuffer;
import buffers.LightBinBuffer;
import lib.lightList.common;


extern static const bool POINT_SHADOW_DEBUG;

RWStructuredBuffer<SceneBuffer> scene;
RWStructuredBuffer<LightBinBuffer> lightBin;


[[shader("compute")]]
[numthreads(4, 4, 4)]
void clearLightLists(uint3 globalPos : SV_DispatchThreadID) {
    int3 binPos = int3(globalPos);

    if (all(binPos < int3(LightBinGridSize))) {
        int binIndex = lightList_getBinIndex(binPos);

        // reset bin count to zero
        lightBin[binIndex].lightCount = 0u;
    }

    if (POINT_SHADOW_DEBUG) {
        if (all(binPos == int3(0))) {
            // reset bin debug counter to zero
            scene[0].PointLightCount = 0u;
        }
    }
}
