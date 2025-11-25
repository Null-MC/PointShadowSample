public module common;

import aperture;

static const int3 pointBoundsMax = int2(4, 3).xyx;


// returns true if a position is within the section-aligned bounds of the point-light renderer.
bool pointShadow_isInBounds(const in float3 localPos) {
	float3 sectionOffset = fract(ap.camera.position / 16.0) * 16.0;
    float3 sectionPos_abs = abs(floor((sectionOffset + localPos) / 16.0));
    const float3 _max = pointBoundsMax + 0.08;

    return all(sectionPos_abs <= _max);
}
