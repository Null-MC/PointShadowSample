import aperture;
import lib.common;

extern static const uint POINT_SHADOW_BIN_REGION;
extern static const uint POINT_SHADOW_BIN_SIZE;


// the area in blocks covered by light bins
static const int3 LightList_BufferBlockSize = int3(POINT_SHADOW_BIN_REGION);

static const int3 LightList_BufferBlockCenter = LightList_BufferBlockSize / 2;

static const int LightBinGridSize = int(ceil(POINT_SHADOW_BIN_REGION / float(POINT_SHADOW_BIN_SIZE)));


float3 lightList_getCenter(const in float3 cameraPos) {
	return LightList_BufferBlockCenter + fract(cameraPos/POINT_SHADOW_BIN_SIZE)*POINT_SHADOW_BIN_SIZE;
}

float3 lightList_getBinPos(const in float3 localPos) {
	return (localPos + lightList_getCenter(ap.camera.position)) / POINT_SHADOW_BIN_SIZE;
}

int lightList_getBinIndex(const in int3 binPos) {
	const int3 flatten = int3(1, LightBinGridSize, LightBinGridSize*LightBinGridSize);
	return sumOf(binPos * flatten);
}

bool lightList_isInBounds(const in int3 binPos) {
	return all(clamp(binPos, 0, LightBinGridSize-1) == binPos);
}
