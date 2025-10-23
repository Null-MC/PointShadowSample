import aperture;


struct VertexOutput {
    float4 position : SV_Position;

    float3 modelPos;
    nointerpolation int blockId;
    float2 uv;
};

[[shader("vertex")]]
VertexOutput vertexMain(Vertex input) {
    VertexOutput output;

    output.modelPos = input.pos().xyz;

    float4 shadowViewPos = mul(input.viewMatrix(), input.pos());
    output.position = mul(input.projectionMatrix(), shadowViewPos);

    output.uv = input.uv();

    output.blockId = ap.lights[input.currentInstance()].block;

    return output;
}


[[shader("fragment")]]
void fragmentMain(VertexOutput input) {
    float2 mLight;
    float4 mColor;
    float2 mUV = input.uv;
    //iris_modifyBase(mUV, mColor, mLight);

    float alpha = albedoTex.Sample(mUV).a;

    bool isFull = ap.blocks[input.blockId].isFullBlock;
    float near = isFull ? 0.5 : 0.49999;
    if (all(clamp(input.modelPos, -near, near) == input.modelPos)) alpha = 0.0;

    const float alphaThreshold = 0.2;
    if (alpha < alphaThreshold) discard;
}
