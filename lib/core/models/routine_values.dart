enum ExerciseMode { time, reps }

enum Sides { single, leftRight }

const defaultSeconds = 60;
const secondsStep = 5;
const minSeconds = 5;
const maxSeconds = 600;
const defaultReps = 10;
const repsStep = 1;
const minReps = 1;
const maxReps = 600;

/// Value for a new item, and after switching to [mode].
int defaultValue(ExerciseMode mode) =>
    mode == ExerciseMode.time ? defaultSeconds : defaultReps;

int clampValue(ExerciseMode mode, int value) => mode == ExerciseMode.time
    ? value.clamp(minSeconds, maxSeconds)
    : value.clamp(minReps, maxReps);
