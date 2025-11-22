import type { TeamDetail } from "../types/mlb";

interface TeamSelectPanelProps {
  teams: TeamDetail[];
  selectedTeamId?: number;
  onTeamChange: (teamId: number) => void;
  selectedDate: string;
  onDateChange: (date: string) => void;
  onFetchSchedule: () => void;
  isLoading: boolean;
}

export function TeamSelectPanel({
  teams,
  selectedTeamId,
  onTeamChange,
  selectedDate,
  onDateChange,
  onFetchSchedule,
  isLoading,
}: TeamSelectPanelProps) {
  return (
    <section className="panel">
      <header className="panel__header">
        <h2>スケジュール検索</h2>
        <button
          type="button"
          onClick={onFetchSchedule}
          disabled={isLoading || !selectedTeamId}
        >
          {isLoading ? "取得中…" : "スケジュール取得"}
        </button>
      </header>
      <div className="panel__body panel__grid">
        <label className="form-control">
          <span>チーム</span>
          <select
            value={selectedTeamId ?? ""}
            onChange={(e) => onTeamChange(Number(e.target.value))}
          >
            <option value="" disabled>
              選択してください
            </option>
            {teams.map((team) => (
              <option key={team.id} value={team.id}>
                {team.abbreviation} - {team.name}
              </option>
            ))}
          </select>
        </label>
        <label className="form-control">
          <span>日付</span>
          <input
            type="date"
            value={selectedDate}
            onChange={(e) => onDateChange(e.target.value)}
          />
        </label>
      </div>
    </section>
  );
}
