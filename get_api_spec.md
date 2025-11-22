# mlb_sim

## API 仕様書

### 1. 概要

- **目的**: MLB Stats API（https://statsapi.mlb.com）を利用して、チーム一覧・スケジュール・ライブゲーム情報を取得する内部APIを提供する。
- **ベース URL**
  - メイン API: `https://statsapi.mlb.com/api/v1`
  - ライブフィード API: `https://statsapi.mlb.com/api/v1.1`

### 2. 共通要件

| 項目             | 内容                                                                                 |
| ---------------- | ------------------------------------------------------------------------------------ |
| 認証             | 不要（公開 API）。必要に応じてアプリ側でレート制御を実装。                           |
| ヘッダー         | `User-Agent: MLB Score Notifier (Electron App)` （Stats API 利用規約順守のため固定） |
| タイムアウト     | 8000 ms                                                                              |
| リトライ         | ネットワークエラー・5xx 時に指数バックオフ（推奨）。                                 |
| エンコーディング | UTF-8                                                                                |
| レスポンス形式   | JSON                                                                                 |

#### エラーハンドリング

| HTTP ステータス | ケース                                   | エラーボディ例                                                           |
| --------------- | ---------------------------------------- | ------------------------------------------------------------------------ |
| 400             | 必須パラメータ欠落、フォーマット不正     | `{ "error": "INVALID_PARAMETER", "message": "date must be YYYY-MM-DD" }` |
| 404             | 対象データなし（存在しない gamePk など） | `{ "error": "NOT_FOUND", "message": "Game not found" }`                  |
| 408             | タイムアウト                             | `{ "error": "UPSTREAM_TIMEOUT" }`                                        |
| 5xx             | MLB API エラー                           | `{ "error": "UPSTREAM_ERROR", "detail": "502 Bad Gateway" }`             |

### 3. エンドポイント

#### 3.1 チーム一覧取得 API

- **HTTP**: `GET /teams`
- **ターゲット**: `GET https://statsapi.mlb.com/api/v1/teams`
- **クエリパラメータ**
  | 名前 | 型 | 必須 | デフォルト | 説明 |
  | --- | --- | --- | --- | --- |
  | `sportId` | number | ✅ | 1 | MLB 固定 |
- **レスポンス**

```json
{
  "teams": [
    {
      "id": 121,
      "name": "New York Mets",
      "abbreviation": "NYM",
      "locationName": "New York",
      "venue": { "name": "Citi Field" }
    }
  ]
}
```

- **バリデーション**: sportId は正の整数のみ許容。

#### 3.2 スケジュール取得 API

- **HTTP**: `GET /schedule`
- **ターゲット**: `GET https://statsapi.mlb.com/api/v1/schedule`
- **クエリパラメータ**
  | 名前 | 型 | 必須 | 説明 |
  | --- | --- | --- | --- |
  | `sportId` | number | ✅ | 1 固定 |
  | `teamId` | number | ✅ | MLB チーム ID |
  | `date` | string(YYYY-MM-DD) | ✅ | 取得対象日 |
- **レスポンス構造（抜粋）**

```json
{
  "dates": [
    {
      "date": "2025-04-01",
      "games": [
        {
          "gamePk": 123456789,
          "gameDate": "2025-04-01T23:05:00Z",
          "status": {
            "detailedState": "Live",
            "abstractGameState": "Live"
          },
          "teams": {
            "home": {
              "team": {
                "id": 133,
                "name": "Oakland Athletics",
                "abbreviation": "OAK"
              }
            },
            "away": {
              "team": {
                "id": 121,
                "name": "New York Mets",
                "abbreviation": "NYM"
              }
            }
          }
        }
      ]
    }
  ]
}
```

- **バリデーション**: 日付は ISO8601（YYYY-MM-DD）。teamId は正の整数。

#### 3.3 ライブゲーム情報取得 API

- **HTTP**: `GET /game/{gamePk}/feed/live`
- **ターゲット**: `GET https://statsapi.mlb.com/api/v1.1/game/{gamePk}/feed/live`
- **パスパラメータ**
  | 名前 | 型 | 必須 | 説明 |
  | --- | --- | --- | --- |
  | `gamePk` | number | ✅ | MLB ゲーム識別子 |
- **レスポンス構造（抜粋）**

```json
{
  "gameData": {
    "teams": {
      "home": { "id": 133, "name": "Oakland Athletics", "abbreviation": "OAK" },
      "away": { "id": 121, "name": "New York Mets", "abbreviation": "NYM" }
    }
  },
  "liveData": {
    "linescore": {
      "currentInning": 5,
      "inningState": "Top",
      "teams": {
        "home": { "runs": 2, "hits": 4, "errors": 0 },
        "away": { "runs": 3, "hits": 6, "errors": 1 }
      }
    },
    "plays": {
      "allPlays": [
        {
          "about": {
            "atBatIndex": 12,
            "result": "Single",
            "isScoringPlay": false
          },
          "result": {
            "description": "Player X singles on a line drive",
            "event": "Single",
            "rbi": 0
          },
          "matchup": { "batter": { "fullName": "Player X" } }
        }
      ],
      "scoringPlays": [5, 9]
    }
  }
}
```

- **バリデーション**: gamePk は正の整数。レスポンスの `linescore` や `plays` が欠落するケースに備え、存在チェック必須。

### 4. 実装メモ

- 実装ファイル: `mlbApi.ts`
  - `/teams`: L155 ～
  - `/schedule`: L195 ～
  - `/game/{gamePk}/feed/live`: L234 ～
- HTTP クライアント: axios を想定。`axios.create` でベース URL・ヘッダー・タイムアウトを共通設定すると保守性向上。
- テスト: Stats API は実データ依存のため、`nock` などでモックレスポンスを用意してスナップショットテストを実施。

#### 3.4 試合作成 API（シミュレーション用）

- **HTTP**: `POST /games`
- **用途**: 2チームで試合を作成
- **リクエストボディ**
```json
{
  "homeTeamId": 133,
  "awayTeamId": 121,
  "gameDate": "2025-04-01T23:05:00Z"
}
```
- **レスポンス**
```json
{
  "gamePk": 999000001,
  "gameDate": "2025-04-01T23:05:00Z",
  "status": {
    "detailedState": "Scheduled",
    "abstractGameState": "Preview"
  },
  "teams": {
    "home": {
      "team": {
        "id": 133,
        "name": "Oakland Athletics",
        "abbreviation": "OAK"
      }
    },
    "away": {
      "team": {
        "id": 121,
        "name": "New York Mets",
        "abbreviation": "NYM"
      }
    }
  }
}
```
- **バリデーション**:
  - `homeTeamId` と `awayTeamId` は正の整数かつ異なる値であること
  - `gameDate` は ISO8601 形式

#### 3.5 試合開始 API

- **HTTP**: `POST /games/{gamePk}/start`
- **用途**: 作成済み試合を開始状態に変更
- **パスパラメータ**
  | 名前 | 型 | 必須 | 説明 |
  | --- | --- | --- | --- |
  | `gamePk` | number | ✅ | ゲーム識別子 |
- **レスポンス**
```json
{
  "gamePk": 999000001,
  "status": {
    "detailedState": "In Progress",
    "abstractGameState": "Live"
  },
  "liveData": {
    "linescore": {
      "currentInning": 1,
      "currentInningOrdinal": "1st",
      "inningState": "Top",
      "teams": {
        "home": { "runs": 0, "hits": 0, "errors": 0 },
        "away": { "runs": 0, "hits": 0, "errors": 0 }
      },
      "innings": []
    }
  }
}
```
- **バリデーション**:
  - 試合が `Scheduled` 状態であること

#### 3.6 イニング別スコア更新 API

- **HTTP**: `PUT /games/{gamePk}/innings/{inningNumber}`
- **用途**: 指定イニングのスコアを手動設定
- **パスパラメータ**
  | 名前 | 型 | 必須 | 説明 |
  | --- | --- | --- | --- |
  | `gamePk` | number | ✅ | ゲーム識別子 |
  | `inningNumber` | number | ✅ | イニング番号（1～9+延長） |
- **リクエストボディ**
```json
{
  "half": "top",
  "runs": 2,
  "hits": 3,
  "errors": 0
}
```
- **レスポンス**
```json
{
  "gamePk": 999000001,
  "liveData": {
    "linescore": {
      "currentInning": 5,
      "currentInningOrdinal": "5th",
      "inningState": "Top",
      "teams": {
        "home": { "runs": 2, "hits": 4, "errors": 0 },
        "away": { "runs": 3, "hits": 6, "errors": 1 }
      },
      "innings": [
        {
          "num": 1,
          "ordinalNum": "1st",
          "home": { "runs": 0, "hits": 1, "errors": 0 },
          "away": { "runs": 2, "hits": 3, "errors": 0 }
        }
      ]
    }
  }
}
```
- **バリデーション**:
  - `half` は `"top"` または `"bottom"` のみ
  - `runs`, `hits`, `errors` は 0 以上の整数
  - 試合が `In Progress` 状態であること

#### 3.7 試合終了 API

- **HTTP**: `POST /games/{gamePk}/finish`
- **用途**: 試合を終了状態に変更
- **パスパラメータ**
  | 名前 | 型 | 必須 | 説明 |
  | --- | --- | --- | --- |
  | `gamePk` | number | ✅ | ゲーム識別子 |
- **レスポンス**
```json
{
  "gamePk": 999000001,
  "status": {
    "detailedState": "Final",
    "abstractGameState": "Final"
  },
  "liveData": {
    "linescore": {
      "teams": {
        "home": { "runs": 5, "hits": 8, "errors": 1 },
        "away": { "runs": 3, "hits": 6, "errors": 2 }
      }
    }
  }
}
```
- **バリデーション**:
  - 試合が `In Progress` 状態であること
  - 最低9イニング完了していること（延長可）

### 5. 実装チェックリスト

#### シミュレーション機能実装

- [ ] **データベース設計**
  - [ ] Games テーブル作成（gamePk, home_team_id, away_team_id, game_date, status）
  - [ ] Innings テーブル作成（game_id, inning_number, half, runs, hits, errors）
  - [ ] マイグレーション実行

- [ ] **試合作成機能**
  - [ ] `POST /games` エンドポイント実装
  - [ ] リクエストバリデーション（homeTeamId ≠ awayTeamId）
  - [ ] gamePk 自動採番ロジック実装
  - [ ] レスポンス整形（MLB API 互換形式）

- [ ] **試合開始機能**
  - [ ] `POST /games/{gamePk}/start` エンドポイント実装
  - [ ] 状態遷移バリデーション（Scheduled → In Progress）
  - [ ] linescore 初期化処理
  - [ ] 1回表の初期状態設定

- [ ] **スコア更新機能**
  - [ ] `PUT /games/{gamePk}/innings/{inningNumber}` エンドポイント実装
  - [ ] half パラメータバリデーション（top/bottom）
  - [ ] スコア累計計算ロジック
  - [ ] currentInning, inningState 自動更新

- [ ] **試合終了機能**
  - [ ] `POST /games/{gamePk}/finish` エンドポイント実装
  - [ ] 9イニング完了チェック
  - [ ] 状態遷移バリデーション（In Progress → Final）
  - [ ] 最終スコア確定処理

- [ ] **テスト**
  - [ ] 試合作成APIのユニットテスト
  - [ ] 試合開始APIのユニットテスト
  - [ ] スコア更新APIのユニットテスト
  - [ ] 試合終了APIのユニットテスト
  - [ ] 統合テスト（試合フルフロー）

- [ ] **エラーハンドリング**
  - [ ] 400エラー：パラメータ不正
  - [ ] 404エラー：試合が存在しない
  - [ ] 409エラー：状態遷移エラー（例: 終了済み試合の更新）

### 6. 今後の拡張案

1. キャッシュ層（例: Redis）を導入してレート制限やパフォーマンス対策を実施。
2. `/schedule` に `dateRange` オプションを追加して複数日の予定を一括取得。
3. `/game/{gamePk}/feed/live` のプレー情報を要約するユーティリティを提供し、UI 層での整形を簡潔化。
4. シミュレーション試合の自動進行機能（AI による打席結果生成）。
