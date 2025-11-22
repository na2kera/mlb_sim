export type TeamDetail = {
  id: number;
  mlbId?: number;
  recordId?: number;
  name: string;
  abbreviation: string;
  locationName?: string;
  venue?: { name?: string };
};

export type TeamsResponse = {
  teams: TeamDetail[];
};

export type GameStatus = {
  detailedState: string;
  abstractGameState: string;
};

export type ScheduleGame = {
  gamePk: number;
  gameDate: string;
  status: GameStatus;
  teams: {
    home: { team: TeamDetail };
    away: { team: TeamDetail };
  };
};

export type ScheduleDate = {
  date: string;
  games: ScheduleGame[];
};

export type ScheduleResponse = {
  dates: ScheduleDate[];
};

export type TeamScore = {
  runs: number | null;
  hits: number | null;
  errors: number | null;
};

export type Linescore = {
  currentInning?: number;
  currentInningOrdinal?: string;
  inningState?: string;
  teams: {
    home: TeamScore;
    away: TeamScore;
  };
  innings?: Array<{
    num: number;
    ordinalNum?: string;
    home: TeamScore;
    away: TeamScore;
  }>;
};

export type PlaySummary = {
  about: { atBatIndex: number; result?: string; isScoringPlay?: boolean };
  result?: { description?: string; event?: string; rbi?: number };
  matchup?: { batter?: { fullName?: string } };
};

export type LiveFeedResponse = {
  gameData: {
    teams: {
      home: TeamDetail;
      away: TeamDetail;
    };
  };
  liveData: {
    linescore?: Linescore;
    plays?: {
      allPlays?: PlaySummary[];
      scoringPlays?: number[];
    };
  };
};

export type GameResponse = {
  gamePk: number;
  gameDate: string;
  status: GameStatus;
  teams: {
    home: { team: TeamDetail };
    away: { team: TeamDetail };
  };
};

export type GameStartResponse = {
  gamePk: number;
  status: GameStatus;
  liveData: { linescore: Linescore };
};

export type GameFinishResponse = {
  gamePk: number;
  status: GameStatus;
  liveData: { linescore: Linescore };
};

export type CreateGamePayload = {
  homeTeamId: number;
  awayTeamId: number;
  gameDate: string;
};

export type UpdateInningPayload = {
  half: "top" | "bottom";
  runs: number;
  hits: number;
  errors: number;
};
