export type MarginType = 'CLOSE' | 'SOLID' | 'DOMINANT';

export function calculateRatingDelta(params: {
  playerRating: number;
  opponentRating: number;
  isWinner: boolean;
  playerMatchCount: number;
  marginType: MarginType;
}) {
  const expected =
    1 / (1 + Math.pow(10, (params.opponentRating - params.playerRating) / 400));

  const score = params.isWinner ? 1 : 0;

  const k =
    params.playerMatchCount <= 10 ? 32 : params.playerMatchCount <= 50 ? 24 : 16;

  const marginMultiplier: Record<MarginType, number> = {
    CLOSE: 1.0,
    SOLID: 1.05,
    DOMINANT: 1.1,
  };

  const delta = k * (score - expected) * marginMultiplier[params.marginType];

  return {
    delta: Math.round(delta),
    newRating: Math.round(params.playerRating + delta),
  };
}