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

### 4. 実装メモ

- 実装ファイル: `mlbApi.ts`
  - `/teams`: L155 ～
  - `/schedule`: L195 ～
  - `/game/{gamePk}/feed/live`:（現在は利用しない想定）
- HTTP クライアント: axios を想定。`axios.create` でベース URL・ヘッダー・タイムアウトを共通設定すると保守性向上。
- テスト: Stats API は実データ依存のため、`nock` などでモックレスポンスを用意してスナップショットテストを実施。

### 5. 実装チェックリスト

### 6. 今後の拡張案

1. キャッシュ層（例: Redis）を導入してレート制限やパフォーマンス対策を実施。
2. `/schedule` に `dateRange` オプションを追加して複数日の予定を一括取得。
