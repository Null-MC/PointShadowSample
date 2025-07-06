#version 430 core

layout(location = 0) out vec4 outColor;

uniform sampler2D texFinal;

#include "/lib/common.glsl"

#include "/lib/utility/text.glsl"


void main() {
    ivec2 iuv = ivec2(gl_FragCoord.xy);
    vec3 color = texelFetch(texFinal, iuv, 0).rgb;

    #if defined(POINT_SHADOW_ENABLED) && defined(POINT_SHADOW_DEBUG)
        if (!ap.game.guiHidden) {
            beginText(ivec2(gl_FragCoord.xy * 0.5), ivec2(4, ap.game.screenSize.y/2 - 8));
            text.bgCol = vec4(0.0, 0.0, 0.0, 0.6);
            text.fgCol = vec4(1.0, 1.0, 1.0, 1.0);

            printString((_P, _o, _i, _n, _t, _space, _L, _i, _g, _h, _t, _s, _colon, _space));
            printUnsignedInt(ap.point.total);
            printLine();

            endText(color);
        }
    #endif

    color = LinearToRgb(color);
    outColor = vec4(color, 1.0);
}
