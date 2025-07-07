// the area in blocks covered by light bins
const ivec3 LightList_BufferBlockSize = ivec3(POINT_SHADOW_BIN_REGION);

const ivec3 LightList_BufferBlockCenter = LightList_BufferBlockSize / 2;

const int LightBinGridSize = int(ceil(LightList_BufferBlockSize / float(POINT_SHADOW_BIN_SIZE)));


vec3 lightList_getCenter(const in vec3 cameraPos) {
	return LightList_BufferBlockCenter + fract(cameraPos/POINT_SHADOW_BIN_SIZE)*POINT_SHADOW_BIN_SIZE;
}

vec3 lightList_getBinPos(const in vec3 localPos) {
	return (localPos + lightList_getCenter(ap.camera.pos)) / POINT_SHADOW_BIN_SIZE;
}

int lightList_getBinIndex(const in ivec3 binPos) {
	const ivec3 flatten = ivec3(1, LightBinGridSize, LightBinGridSize*LightBinGridSize);
	return sumOf(binPos * flatten);
}

bool lightList_isInBounds(const in ivec3 binPos) {
	return clamp(binPos, 0, LightBinGridSize-1) == binPos;
}
