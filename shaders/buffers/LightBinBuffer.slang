extern static const uint POINT_SHADOW_BIN_COUNT;

// size= 4 * (2 + Y)
struct LightBinBuffer {
    Atomic<uint> lightCount;
    uint lightCountFinal;
    uint lightList[POINT_SHADOW_BIN_COUNT];
};
