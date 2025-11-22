import type { ScheduleDate } from "../types/mlb";

interface ScheduleTableProps {
  dates: ScheduleDate[];
  isLoading: boolean;
  selectedGamePk?: number;
  onSelectGame: (gamePk: number) => void;
}

export function ScheduleTable({
  dates,
  isLoading,
  selectedGamePk,
  onSelectGame,
}: ScheduleTableProps) {
  if (isLoading) {
    return (
      <section className="panel">
        <header className="panel__header">
          <h2>スケジュール</h2>
          <span>読み込み中…</span>
        </header>
      </section>
    );
  }

  const games = dates.flatMap((date) =>
    date.games.map((game) => ({ date: date.date, ...game }))
  );

  return (
    <section className="panel">
      <header className="panel__header">
        <h2>スケジュール</h2>
        <span>{games.length} 試合</span>
      </header>
      {games.length === 0 ? (
        <p className="panel__empty">試合が見つかりませんでした。</p>
      ) : (
        <div className="table-wrapper">
          <table className="schedule-table">
            <thead>
              <tr>
                <th>日付</th>
                <th>開始時刻</th>
                <th>ホーム</th>
                <th>アウェイ</th>
                <th>状態</th>
                <th></th>
              </tr>
            </thead>
            <tbody>
              {games.map((game) => {
                const isSelected = selectedGamePk === game.gamePk;
                return (
                  <tr
                    key={game.gamePk}
                    className={isSelected ? "is-selected" : ""}
                  >
                    <td>{game.date}</td>
                    <td>
                      {new Date(game.gameDate).toLocaleTimeString([], {
                        hour: "2-digit",
                        minute: "2-digit",
                      })}
                    </td>
                    <td>
                      <strong>{game.teams.home.team.abbreviation}</strong>{" "}
                      {game.teams.home.team.name}
                    </td>
                    <td>
                      <strong>{game.teams.away.team.abbreviation}</strong>{" "}
                      {game.teams.away.team.name}
                    </td>
                    <td>{game.status.detailedState}</td>
                    <td>
                      <button
                        type="button"
                        onClick={() => onSelectGame(game.gamePk)}
                      >
                        詳細
                      </button>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      )}
    </section>
  );
}
