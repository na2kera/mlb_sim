import type { LiveFeedResponse } from "../types/mlb";

interface LiveGamePanelProps {
  gamePk?: number;
  isLoading: boolean;
  liveFeed?: LiveFeedResponse;
  onRefresh: () => void;
}

export function LiveGamePanel({
  gamePk,
  isLoading,
  liveFeed,
  onRefresh,
}: LiveGamePanelProps) {
  return (
    <section className="panel">
      <header className="panel__header">
        <div>
          <h2>ライブゲーム情報</h2>
          {gamePk && <p className="panel__sub">GamePk: {gamePk}</p>}
        </div>
        <button
          type="button"
          onClick={onRefresh}
          disabled={!gamePk || isLoading}
        >
          {isLoading ? "更新中…" : "最新情報を取得"}
        </button>
      </header>

      {!gamePk ? (
        <p className="panel__empty">スケジュールから試合を選択してください。</p>
      ) : isLoading ? (
        <p className="panel__empty">読み込み中…</p>
      ) : !liveFeed ? (
        <p className="panel__empty">ライブ情報がまだありません。</p>
      ) : (
        <div className="live-grid">
          {liveFeed.liveData?.linescore ? (
            <div>
              <h3>スコアボード</h3>
              <table className="linescore-table">
                <thead>
                  <tr>
                    <th>チーム</th>
                    <th>R</th>
                    <th>H</th>
                    <th>E</th>
                  </tr>
                </thead>
                <tbody>
                  <tr>
                    <td>{liveFeed.gameData.teams.away.abbreviation}</td>
                    <td>
                      {liveFeed.liveData.linescore.teams.away.runs ?? "-"}
                    </td>
                    <td>
                      {liveFeed.liveData.linescore.teams.away.hits ?? "-"}
                    </td>
                    <td>
                      {liveFeed.liveData.linescore.teams.away.errors ?? "-"}
                    </td>
                  </tr>
                  <tr>
                    <td>{liveFeed.gameData.teams.home.abbreviation}</td>
                    <td>
                      {liveFeed.liveData.linescore.teams.home.runs ?? "-"}
                    </td>
                    <td>
                      {liveFeed.liveData.linescore.teams.home.hits ?? "-"}
                    </td>
                    <td>
                      {liveFeed.liveData.linescore.teams.home.errors ?? "-"}
                    </td>
                  </tr>
                </tbody>
              </table>
              {liveFeed.liveData.linescore.currentInning && (
                <p className="panel__note">
                  現在{" "}
                  {liveFeed.liveData.linescore.currentInningOrdinal ??
                    `${liveFeed.liveData.linescore.currentInning}回`}
                  {liveFeed.liveData.linescore.inningState
                    ? ` (${liveFeed.liveData.linescore.inningState})`
                    : ""}
                </p>
              )}
            </div>
          ) : (
            <p className="panel__empty">スコアボード情報なし</p>
          )}

          <div>
            <h3>プレー履歴</h3>
            {liveFeed.liveData?.plays?.allPlays &&
            liveFeed.liveData.plays.allPlays.length > 0 ? (
              <ol className="play-list">
                {liveFeed.liveData.plays.allPlays.map((play) => (
                  <li key={play.about.atBatIndex}>
                    <strong>
                      {play.matchup?.batter?.fullName ?? "Unknown Batter"}
                    </strong>
                    <span>
                      {play.result?.description ??
                        play.result?.event ??
                        "No description"}
                    </span>
                    {play.about.isScoringPlay && (
                      <span className="tag">SCORE</span>
                    )}
                  </li>
                ))}
              </ol>
            ) : (
              <p className="panel__empty">プレー情報がありません。</p>
            )}
          </div>
        </div>
      )}
    </section>
  );
}
