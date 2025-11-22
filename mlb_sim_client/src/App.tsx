import axios from "axios";
import { useEffect, useMemo, useState } from "react";
import "./App.css";
import { CreatedGamesList } from "./components/CreatedGamesList";
import { LiveGamePanel } from "./components/LiveGamePanel";
import { NotificationBar } from "./components/NotificationBar";
import { QuickGameCreator } from "./components/QuickGameCreator";
import { SimulationControls } from "./components/SimulationControls";
import {
  createGame,
  finishGame,
  getLiveFeed,
  getSchedule,
  getTeams,
  startGame,
  updateInning,
} from "./lib/mlbApi";
import type {
  CreateGamePayload,
  GameResponse,
  LiveFeedResponse,
  ScheduleDate,
  TeamDetail,
  UpdateInningPayload,
} from "./types/mlb";

type Toast = { type: "success" | "error"; text: string };
type ActionLoading = "create" | "start" | "update" | "finish" | null;

function App() {
  const [teams, setTeams] = useState<TeamDetail[]>([]);
  const [teamsLoading, setTeamsLoading] = useState(true);
  const [toast, setToast] = useState<Toast | null>(null);
  const [actionLoading, setActionLoading] = useState<ActionLoading>(null);
  const [createdGames, setCreatedGames] = useState<GameResponse[]>([]);
  const [selectedGamePk, setSelectedGamePk] = useState<number | undefined>(
    undefined
  );
  const [scheduleDates, setScheduleDates] = useState<ScheduleDate[]>([]);
  const [scheduleLoading, setScheduleLoading] = useState(false);
  const [liveFeed, setLiveFeed] = useState<LiveFeedResponse | undefined>(
    undefined
  );
  const [liveLoading, setLiveLoading] = useState(false);

  useEffect(() => {
    async function fetchTeams() {
      try {
        const data = await getTeams();
        setTeams(data.teams);
      } catch (error) {
        showToast(
          "error",
          `チーム一覧取得に失敗しました: ${extractErrorMessage(error)}`
        );
      } finally {
        setTeamsLoading(false);
      }
    }

    fetchTeams();
  }, []);

  const scheduleGameCount = useMemo(
    () => scheduleDates.reduce((acc, date) => acc + date.games.length, 0),
    [scheduleDates]
  );

  const showToast = (type: Toast["type"], text: string) => {
    setToast({ type, text });
    setTimeout(() => setToast(null), 4000);
  };

  const extractErrorMessage = (err: unknown): string => {
    if (axios.isAxiosError(err)) {
      return (
        (err.response?.data as { message?: string })?.message ?? err.message
      );
    }
    if (err instanceof Error) return err.message;
    return "Unknown error";
  };

  const handleFetchSchedule = async (teamId: number, date: string) => {
    setScheduleLoading(true);
    try {
      const data = await getSchedule(teamId, date);
      setScheduleDates(data.dates ?? []);
    } catch (error) {
      showToast(
        "error",
        `スケジュール取得に失敗しました: ${extractErrorMessage(error)}`
      );
    } finally {
      setScheduleLoading(false);
    }
  };

  const fetchLiveData = async (gamePkParam?: number) => {
    const targetPk = gamePkParam ?? selectedGamePk;
    if (!targetPk) return;

    setLiveLoading(true);
    try {
      const data = await getLiveFeed(targetPk);
      setLiveFeed(data);
    } catch (error) {
      showToast(
        "error",
        `ライブ情報取得に失敗しました: ${extractErrorMessage(error)}`
      );
    } finally {
      setLiveLoading(false);
    }
  };

  const handleSelectGame = (gamePk: number) => {
    setSelectedGamePk(gamePk);
    fetchLiveData(gamePk);
  };

  const handleCreateGame = async (payload: CreateGamePayload) => {
    setActionLoading("create");
    try {
      const response = await createGame(payload);
      setCreatedGames((prev) => [
        response,
        ...prev.filter((game) => game.gamePk !== response.gamePk),
      ]);
      setSelectedGamePk(response.gamePk);
      showToast("success", "試合作成に成功しました");
      await fetchLiveData(response.gamePk);
    } catch (error) {
      showToast(
        "error",
        `試合作成に失敗しました: ${extractErrorMessage(error)}`
      );
    } finally {
      setActionLoading(null);
    }
  };

  const handleStartGame = async (gamePk: number) => {
    setActionLoading("start");
    try {
      await startGame(gamePk);
      showToast("success", "試合を開始しました");
      await fetchLiveData(gamePk);
    } catch (error) {
      showToast(
        "error",
        `試合開始に失敗しました: ${extractErrorMessage(error)}`
      );
    } finally {
      setActionLoading(null);
    }
  };

  const handleUpdateInning = async (
    gamePk: number,
    inningNumber: number,
    payload: UpdateInningPayload
  ) => {
    setActionLoading("update");
    try {
      await updateInning(gamePk, inningNumber, payload);
      showToast(
        "success",
        `${inningNumber}回${
          payload.half === "top" ? "表" : "裏"
        } を更新しました`
      );
      await fetchLiveData(gamePk);
    } catch (error) {
      showToast(
        "error",
        `イニング更新に失敗しました: ${extractErrorMessage(error)}`
      );
    } finally {
      setActionLoading(null);
    }
  };

  const handleFinishGame = async (gamePk: number) => {
    setActionLoading("finish");
    try {
      await finishGame(gamePk);
      showToast("success", "試合を終了しました");
      await fetchLiveData(gamePk);
    } catch (error) {
      showToast(
        "error",
        `試合終了処理に失敗しました: ${extractErrorMessage(error)}`
      );
    } finally {
      setActionLoading(null);
    }
  };

  return (
    <div className="app">
      <header className="app__header">
        <div>
          <p className="eyebrow">MLB Simulator</p>
          <h1>シミュレーション管理コンソール</h1>
        </div>
        <p className="app__meta">
          {teamsLoading ? "チーム情報取得中…" : `${teams.length} チーム`}
        </p>
      </header>

      {toast && (
        <NotificationBar message={toast} onClose={() => setToast(null)} />
      )}

      <div className="layout">
        <main className="layout__main">
          <QuickGameCreator
            teams={teams}
            onCreateGame={handleCreateGame}
            isCreating={actionLoading === "create"}
          />

          <CreatedGamesList
            games={createdGames}
            onSelectGame={handleSelectGame}
          />

          <section className="panel">
            <header className="panel__header">
              <h2>参考スケジュール</h2>
              <span className="app__meta app__meta--muted">
                {scheduleGameCount} 試合
              </span>
            </header>
            {scheduleLoading ? (
              <p className="panel__empty">取得中…</p>
            ) : scheduleDates.length === 0 ? (
              <p className="panel__empty">スケジュールがありません。</p>
            ) : (
              <ul className="team-list">
                {scheduleDates.flatMap((date) =>
                  date.games.map((game) => (
                    <li key={game.gamePk}>
                      <strong>{date.date}</strong>
                      <span>
                        {game.teams.home.team.abbreviation} vs{" "}
                        {game.teams.away.team.abbreviation}
                      </span>
                    </li>
                  ))
                )}
              </ul>
            )}
          </section>
        </main>

        <aside className="layout__side">
          <LiveGamePanel
            gamePk={selectedGamePk}
            isLoading={liveLoading}
            liveFeed={liveFeed}
            onRefresh={() => fetchLiveData(selectedGamePk)}
          />

          <SimulationControls
            activeGamePk={selectedGamePk}
            onStartGame={handleStartGame}
            onUpdateInning={handleUpdateInning}
            onFinishGame={handleFinishGame}
            actionLoading={actionLoading}
          />
        </aside>
      </div>
    </div>
  );
}

export default App;
