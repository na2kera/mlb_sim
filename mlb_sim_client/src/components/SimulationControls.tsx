import { useState } from "react";
import type { UpdateInningPayload } from "../types/mlb";

interface SimulationControlsProps {
  activeGamePk?: number;
  onStartGame: (gamePk: number) => void | Promise<void>;
  onUpdateInning: (
    gamePk: number,
    inningNumber: number,
    payload: UpdateInningPayload
  ) => void | Promise<void>;
  onFinishGame: (gamePk: number) => void | Promise<void>;
  actionLoading: "create" | "start" | "update" | "finish" | null;
}

export function SimulationControls({
  activeGamePk,
  onStartGame,
  onUpdateInning,
  onFinishGame,
  actionLoading,
}: SimulationControlsProps) {
  const [inningNumber, setInningNumber] = useState(1);
  const [inningPayload, setInningPayload] = useState<UpdateInningPayload>({
    half: "top",
    runs: 0,
    hits: 0,
    errors: 0,
  });

  const isActionDisabled = (type: "start" | "update" | "finish") =>
    !activeGamePk || actionLoading === type;

  const handleUpdateSubmit = (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    if (!activeGamePk) return;
    onUpdateInning(activeGamePk, inningNumber, inningPayload);
  };

  return (
    <section className="panel">
      <header className="panel__header">
        <h2>シミュレーション操作</h2>
      </header>

      <div className="panel__body stack">
        <div className="form-grid">
          <h3>進行操作</h3>
          <button
            type="button"
            onClick={() => activeGamePk && onStartGame(activeGamePk)}
            disabled={isActionDisabled("start")}
          >
            {actionLoading === "start" ? "開始処理中…" : "試合開始"}
          </button>

          <form onSubmit={handleUpdateSubmit} className="form-grid">
            <label className="form-control">
              <span>イニング</span>
              <input
                type="number"
                min={1}
                value={inningNumber}
                onChange={(e) => setInningNumber(Number(e.target.value))}
              />
            </label>
            <label className="form-control">
              <span>表/裏</span>
              <select
                value={inningPayload.half}
                onChange={(e) =>
                  setInningPayload((prev) => ({
                    ...prev,
                    half: e.target.value as "top" | "bottom",
                  }))
                }
              >
                <option value="top">表 (top)</option>
                <option value="bottom">裏 (bottom)</option>
              </select>
            </label>
            <div className="form-grid form-grid--split">
              {(["runs", "hits", "errors"] as const).map((field) => (
                <label key={field} className="form-control">
                  <span>{field.toUpperCase()}</span>
                  <input
                    type="number"
                    min={0}
                    value={inningPayload[field]}
                    onChange={(e) =>
                      setInningPayload((prev) => ({
                        ...prev,
                        [field]: Number(e.target.value),
                      }))
                    }
                  />
                </label>
              ))}
            </div>
            <button type="submit" disabled={isActionDisabled("update")}>
              {actionLoading === "update" ? "更新中…" : "イニング更新"}
            </button>
          </form>

          <button
            type="button"
            onClick={() => activeGamePk && onFinishGame(activeGamePk)}
            disabled={isActionDisabled("finish")}
          >
            {actionLoading === "finish" ? "終了処理中…" : "試合終了"}
          </button>
        </div>
      </div>
    </section>
  );
}
