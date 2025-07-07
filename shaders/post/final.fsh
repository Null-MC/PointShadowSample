#version 430 core

layout(location = 0) out vec4 outColor;

uniform sampler2D texFinal;

#include "/lib/common.glsl"

#include "/lib/utility/text.glsl"

#ifdef POINT_SHADOW_BIN_ENABLED
    #include "/lib/light-list/buffer.glsl"
#endif


void main() {
    ivec2 iuv = ivec2(gl_FragCoord.xy);
    vec3 color = texelFetch(texFinal, iuv, 0).rgb;

    #if defined(POINT_SHADOW_ENABLED) && defined(POINT_SHADOW_DEBUG)
        if (!ap.game.guiHidden) {
            beginText(ivec2(gl_FragCoord.xy * 0.5), ivec2(4, ap.game.screenSize.y/2 - 8));
            text.bgCol = vec4(0.0, 0.0, 0.0, 0.6);
            text.fgCol = vec4(1.0, 1.0, 1.0, 1.0);

            printString((_A, _c, _t, _i, _v, _e, _space, _L, _i, _g, _h, _t, _s, _colon, _space));
            printUnsignedInt(ap.point.total);
            printLine();

            #ifdef POINT_SHADOW_BIN_ENABLED
                printString((_B, _i, _n, _space, _L, _i, _g, _h, _t, _s, _colon, _space));
                printUnsignedInt(Scene_LightCount);
                printLine();
            #endif

            endText(color);
        }
    #endif

    color = LinearToRgb(color);
    outColor = vec4(color, 1.0);
}
