import type {} from './iris'

export function setupOptions() {
    return new Page('MAIN')
        .add(asIntRange('POINT_SHADOW_MAX_COUNT', 32, 0, 256, 2, true))
        .add(asInt('POINT_SHADOW_RESOLUTION', 16, 32, 64, 128, 256, 512, 1024).needsReload(true).build(256))
        .add(EMPTY)
        .add(asIntRange('POINT_SHADOW_REALTIME_COUNT', 4, 0, 32, 1, false))
        .add(asIntRange('POINT_SHADOW_MAX_UPDATES', 4, 1, 16, 1, false))
        .add(asIntRange('POINT_SHADOW_THRESHOLD', 8, 2, 50, 2, false))
        .add(EMPTY)
        .add(asBool('POINT_SHADOW_BIN_ENABLED', false, true))
        .add(asIntRange('POINT_SHADOW_BIN_COUNT', 32, 2, 64, 2, true))
        .add(EMPTY)
        .add(asBool('DISTANCE_AS_DEPTH', true, true))
        .add(asBool('POINT_SHADOW_DEBUG', false, true))
        .build();
}

function asIntRange(keyName: String, defaultValue: Number, valueMin: Number, valueMax: Number, interval: Number, reload: Boolean = true) {
    const values = getValueRange(valueMin, valueMax, interval);
    return asInt(keyName, ...values).needsReload(reload).build(defaultValue);
}

function getValueRange(valueMin, valueMax, interval) {
    const values = [];

    let value = valueMin;
    while (value <= valueMax) {
        values.push(value);
        value += interval;
    }

    return values;
}
