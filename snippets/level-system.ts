export const LEVEL_THRESHOLDS = [
  0, 200, 500, 900, 1400, 2000, 2700, 3500, 4400, 5400,
  6500, 7700, 9000, 10400, 11900, 13500, 15200, 17000, 18900, 20900,
];

export function getLevelInfo(xp: number) {
  const thresholds = LEVEL_THRESHOLDS;

  let level = 1;
  let currentLevelXp = thresholds[0];
  let nextLevelXp = thresholds[1];

  for (let i = 0; i < thresholds.length; i++) {
    if (xp >= thresholds[i]) {
      level = i + 1;
      currentLevelXp = thresholds[i];
      nextLevelXp =
        i + 1 < thresholds.length ? thresholds[i + 1] : thresholds[i] + (i * 1000);
    } else {
      break;
    }
  }

  const xpInLevel = xp - currentLevelXp;
  const denom = Math.max(nextLevelXp - currentLevelXp, 1);
  const progress = Math.min(Math.max(xpInLevel / denom, 0), 1);

  return { level, currentLevelXp, nextLevelXp, progress };
}