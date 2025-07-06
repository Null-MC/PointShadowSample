#version 430 core


void iris_emitVertex(inout VertexData data) {
    vec4 viewPos = iris_modelViewMatrix * data.modelPos;
    data.clipPos = iris_projectionMatrix * viewPos;
}

void iris_sendParameters(VertexData data) {}
