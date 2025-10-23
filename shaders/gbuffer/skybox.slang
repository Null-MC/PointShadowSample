import aperture;
import lib.common;


[[shader("vertex")]]
float4 vertexMain(Vertex input) : SV_Position {
    float4 viewPos = mul(input.viewMatrix(), input.pos());
    return mul(input.projectionMatrix(), viewPos);
}


[[shader("fragment")]]
float4 fragmentMain() : SV_Target0 {
    float3 fogColor = RgbToLinear(ap.world.fogColor.rgb);
    return float4(fogColor, 1.0);
}
