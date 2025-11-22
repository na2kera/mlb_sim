import axios from "axios";
import type {
  CreateGamePayload,
  GameFinishResponse,
  GameResponse,
  GameStartResponse,
  LiveFeedResponse,
  ScheduleResponse,
  TeamsResponse,
  UpdateInningPayload,
} from "../types/mlb";

const apiClient = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL ?? "http://localhost:3000/api/v1",
  timeout: 8000,
  headers: {
    "Content-Type": "application/json",
  },
});

export async function getTeams(): Promise<TeamsResponse> {
  const response = await apiClient.get<TeamsResponse>("/teams", {
    params: { sportId: 1 },
  });
  return response.data;
}

export async function getSchedule(
  teamId: number,
  date: string
): Promise<ScheduleResponse> {
  const response = await apiClient.get<ScheduleResponse>("/schedule", {
    params: { sportId: 1, teamId, date },
  });
  return response.data;
}

export async function getLiveFeed(gamePk: number): Promise<LiveFeedResponse> {
  const response = await apiClient.get<LiveFeedResponse>(
    `/game/${gamePk}/feed/live`
  );
  return response.data;
}

export async function createGame(
  payload: CreateGamePayload
): Promise<GameResponse> {
  const response = await apiClient.post<GameResponse>("/games", {
    game: payload,
  });
  return response.data;
}

export async function startGame(gamePk: number): Promise<GameStartResponse> {
  const response = await apiClient.post<GameStartResponse>(
    `/games/${gamePk}/start`
  );
  return response.data;
}

export async function updateInning(
  gamePk: number,
  inningNumber: number,
  payload: UpdateInningPayload
): Promise<LiveFeedResponse> {
  const response = await apiClient.put<LiveFeedResponse>(
    `/games/${gamePk}/innings/${inningNumber}`,
    { inning: payload }
  );
  return response.data;
}

export async function finishGame(gamePk: number): Promise<GameFinishResponse> {
  const response = await apiClient.post<GameFinishResponse>(
    `/games/${gamePk}/finish`
  );
  return response.data;
}
