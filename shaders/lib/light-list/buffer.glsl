// size= 4 * (2 + Y)
struct LightBin {
    uint lightCount;
    uint lightCountFinal;
    uint lightList[POINT_SHADOW_BIN_COUNT];
};

// size= 4 + X*(4 * (2 + Y))
layout(binding = 0) buffer lightListBuffer {
    uint Scene_LightCount;
    LightBin LightBinMap[];
};
