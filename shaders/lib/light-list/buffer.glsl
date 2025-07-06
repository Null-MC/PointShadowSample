// X: ?
// Y: POINT_SHADOW_BIN_COUNT

// size= 4 * (1 + Y)
struct LightBin {
    uint lightCount;
    uint lightList[POINT_SHADOW_BIN_COUNT];
};

// size= 4 + X*(4 * (1 + Y))
layout(binding = 0) buffer lightListBuffer {
    uint Scene_LightCount;
    LightBin LightBinMap[];
};
