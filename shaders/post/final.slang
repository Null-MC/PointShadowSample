import aperture;
import buffers.SceneBuffer;
import lib.common;
import lib.text;

extern static const bool POINT_SHADOW_ENABLED;
extern static const bool POINT_SHADOW_DEBUG;
extern static const bool POINT_SHADOW_BIN_ENABLED;

RWStructuredBuffer<SceneBuffer> scene;

Sampler2D<float3> texSource;


[[shader("fragment")]]
float4 main(float2 pos : SV_Position) : SV_Target0 {
    float3 color = texSource[int2(pos)];

    if (POINT_SHADOW_ENABLED && POINT_SHADOW_DEBUG) {
        //if (!ap.game.guiHidden) {
            beginText(int2(pos * 0.5), int2(4, ap.game.screenSize.y/2 - 8));
            text.bgCol = float4(0.0, 0.0, 0.0, 0.6);
            text.fgCol = float4(1.0, 1.0, 1.0, 1.0);

            printString(uint[](_A, _c, _t, _i, _v, _e, _space, _L, _i, _g, _h, _t, _s, _colon, _space));
            printUnsignedInt(ap.lights.count);
            printLine();

            if (POINT_SHADOW_BIN_ENABLED) {
                printString(uint[](_B, _i, _n, _space, _L, _i, _g, _h, _t, _s, _colon, _space));
                printUnsignedInt(scene[0].PointLightCount.load());
                printLine();
            }

            endText(color);
        //}
    }

    color = LinearToRgb(color);
    return float4(color, 1.0);
}
