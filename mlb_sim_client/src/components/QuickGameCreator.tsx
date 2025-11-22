import { useState } from "react";
import type { CreateGamePayload, TeamDetail } from "../types/mlb";

interface QuickGameCreatorProps {
  teams: TeamDetail[];
  onCreateGame: (payload: CreateGamePayload) => void | Promise<void>;
  isCreating: boolean;
}

const nowIso = () => new Date().toISOString();

export function QuickGameCreator({
  teams,
  onCreateGame,
  isCreating,
}: QuickGameCreatorProps) {
  const [homeTeamId, setHomeTeamId] = useState<number | undefined>(undefined);
  const [awayTeamId, setAwayTeamId] = useState<number | undefined>(undefined);

  const resolveId = (team?: TeamDetail) => team?.recordId ?? team?.id;

  const homeTeam =
    teams.find((team) => resolveId(team) === homeTeamId) ?? teams[0];
  const homeValue = resolveId(homeTeam);

  const awayFallbackCandidate = teams.find(
    (team) => resolveId(team) !== homeValue
  );
  const awayTeam =
    teams.find(
      (team) => resolveId(team) === awayTeamId && resolveId(team) !== homeValue
    ) ??
    awayFallbackCandidate ??
    teams[0];
  const awayValue = resolveId(awayTeam);

  const handleSubmit = (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    if (!homeValue || !awayValue || homeValue === awayValue) return;
    const payload: CreateGamePayload = {
      homeTeamId: homeValue,
      awayTeamId: awayValue,
      gameDate: nowIso(),
    };
    onCreateGame(payload);
  };

  return (
    <section className="panel panel--hero">
      <header className="panel__header">
        <div>
          <p className="eyebrow">Quick create</p>
          <h2>シミュレーション試合をすぐに生成</h2>
          <p className="panel__note">
            ホームとアウェイを選ぶだけで即座に試合作成できます。
          </p>
        </div>
        <span className="app__meta">{teams.length} Teams</span>
      </header>
      <form className="panel__grid" onSubmit={handleSubmit}>
        <label className="form-control">
          <span>ホームチーム</span>
          <select
            value={homeTeamId}
            onChange={(e) => setHomeTeamId(Number(e.target.value))}
          >
            {teams.map((team) => (
              <option key={team.id} value={resolveId(team)}>
                {team.abbreviation} - {team.name}
              </option>
            ))}
          </select>
        </label>
        <label className="form-control">
          <span>アウェイチーム</span>
          <select
            value={awayTeamId}
            onChange={(e) => setAwayTeamId(Number(e.target.value))}
          >
            {teams.map((team) => (
              <option key={team.id} value={resolveId(team)}>
                {team.abbreviation} - {team.name}
              </option>
            ))}
          </select>
        </label>
        <button
          type="submit"
          className="hero-button"
          disabled={
            isCreating ||
            !homeTeamId ||
            !awayTeamId ||
            homeTeamId === awayTeamId
          }
        >
          {isCreating ? "作成中…" : "試合作成"}
        </button>
      </form>
      {homeTeamId === awayTeamId && (
        <p className="panel__note panel__note--error">
          別々のチームを選択してください。
        </p>
      )}
    </section>
  );
}
