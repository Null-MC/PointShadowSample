import aperture;
import lib.common;
import lib.lmcoord;
import lib.pointShadow.common;
import lib.pointShadow.sample;

extern static const bool POINT_SHADOW_ENABLED;
extern static const bool RENDER_TERRAIN = false;
extern static const bool RENDER_ENTITIES = false;

SamplerCubeArrayShadow pointLightFiltered;


struct VertexOutput {
    float4 position : SV_Position;

    float4 color;
    float2 light;
    float2 uv;
    float3 localPos;
    float3 localNormal;

    //if (RENDER_TERRAIN) {
        nointerpolation uint blockId;
    //}
};

[[shader("vertex")]]
VertexOutput vertexMain(Vertex input) {
    VertexOutput output;

    float4 modelPos = input.pos();
    float4 viewPos = mul(input.viewMatrix(), modelPos);
    output.position = mul(input.projectionMatrix(), viewPos);

    output.uv = input.uv();
    output.localPos = modelPos.xyz;
    output.localNormal = input.normal().value;
    output.light = input.light();

    if (RENDER_ENTITIES) {
        // This adds ambient occlusion and entity hit flash.
        var overlayColor = input.overlayColor();
        if (overlayColor.hasValue) {
            output.color = float4(lerp(overlayColor.value.rgb, input.color().rgb, overlayColor.value.a), input.color().a);
        }
    }
    else {
        output.color = input.color();
        output.color.rgb *= input.ao();
    }

    if (RENDER_TERRAIN) {
        output.blockId = input.blockId().value;
    }

    return output;
}

[[shader("fragment")]]
float4 fragmentMain(VertexOutput input) : SV_Target0 {
    float4 color = albedoTex.Sample(input.uv) * input.color;
    color.rgb = RgbToLinear(color.rgb);

    iris_discardIfNeeded(color);

    // normalize lightmap coordinate to 0-1
    float2 lmcoord = LightMapNorm(input.light);

    bool isInPointShadowBounds = pointShadow_isInBounds(input.localPos);

    if (POINT_SHADOW_ENABLED) {
        // remove lightmap block lighting when within point-light shadow bounds
        if (isInPointShadowBounds) lmcoord.x = 0.0;
    }

    // Add basic directional sky lighting
    float3 viewNormal = normalize(mul(float3x3(ap.camera.view), input.localNormal));
    float3 skyLightViewDir = normalize(ap.celestial.position);
    lmcoord.y *= max(0.2, dot(viewNormal, skyLightViewDir) * 0.5 + 0.5);

    // scale lightmap coord back to sampling range
    lmcoord = LightMapTex(lmcoord);
    float3 lightmap = lightmap.Sample(lmcoord).rgb;

    if (POINT_SHADOW_ENABLED) {
        if (isInPointShadowBounds) {
            float3 localNormal = normalize(input.localNormal);
            float3 pointLighting = shadowPoint_sampleAll(pointLightFiltered, input.localPos, localNormal);

            // apply a boost to make block lighting more visible
            pointLighting *= PointLightBrightness;

            if (RENDER_TERRAIN) {
                // for terrain only, apply self-emission to replace lightmap block light
                int emission = ap.blocks[input.blockId].emission;
                pointLighting += emission / 15.0;
            }

            // apply a simple tonemap to only point-lighting
            lightmap += pointLighting / (1.0 + pointLighting);
        }
    }

    float4 outColor = color * float4(lightmap, 1.0);

    float viewDist = length(input.localPos);

    // Basic fog. This takes care of "environmental" fog, which is the fog that is applied to the camera selectively.
    outColor = lerp(outColor, ap.world.fogColor, smoothstep(ap.world.fogStart, ap.world.fogEnd, viewDist));

    // This is the "border" fog, which is applied to the edges of the render distance.
    outColor = lerp(outColor, ap.world.fogColor, max(0.0, smoothstep(ap.world.renderDistance - 3, ap.world.renderDistance, viewDist)));

    return outColor;
}
