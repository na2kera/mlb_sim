# README

## ローカルセットアップ

1. Ruby/Bundler、Node、Yarn などの依存関係を通常どおりインストールします。
2. `.env.example` があれば `.env` にコピーし、もしくは必要に応じて以下の環境変数を設定します。
   - `DB_HOST`（既定: `localhost`）
   - `DB_PORT`（既定: `5432`）
   - `DB_USERNAME`（既定: `postgres`）
   - `DB_PASSWORD`（既定: `postgres`）
3. Docker で PostgreSQL を起動します。
   ```bash
   docker compose up -d db
   ```
   `docker-compose.yml` を利用して、永続ボリューム付きの Postgres 16 コンテナを立ち上げます。
4. データベースを作成し、マイグレーションを実行します。
   ```bash
   bundle exec rails db:create db:migrate
   ```
5. アプリケーションを起動します。
   ```bash
   bin/dev
   ```
