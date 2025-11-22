import type { GameResponse } from "../types/mlb";

interface CreatedGamesListProps {
  games: GameResponse[];
  onSelectGame: (gamePk: number) => void;
}

export function CreatedGamesList({
  games,
  onSelectGame,
}: CreatedGamesListProps) {
  return (
    <section className="panel">
      <header className="panel__header">
        <div>
          <h2>作成済みシミュレーション試合</h2>
          <p className="panel__note">最新の順に表示します。</p>
        </div>
        <span className="app__meta">{games.length} 件</span>
      </header>
      {games.length === 0 ? (
        <p className="panel__empty">まだシミュレーション試合がありません。</p>
      ) : (
        <ul className="created-list">
          {games.map((game) => (
            <li key={game.gamePk}>
              <div>
                <p className="created-list__teams">
                  <strong>{game.teams.home.team.abbreviation}</strong> vs{" "}
                  <strong>{game.teams.away.team.abbreviation}</strong>
                </p>
                <p className="created-list__meta">
                  #{game.gamePk} ・ {new Date(game.gameDate).toLocaleString()}{" "}
                  ・ {game.status.detailedState}
                </p>
              </div>
              <button type="button" onClick={() => onSelectGame(game.gamePk)}>
                詳細へ
              </button>
            </li>
          ))}
        </ul>
      )}
    </section>
  );
}
