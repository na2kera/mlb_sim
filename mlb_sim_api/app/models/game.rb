class Game < ApplicationRecord
  belongs_to :home_team, class_name: "Team"
  belongs_to :visitor_team, class_name: "Team"
  has_many :innings, dependent: :destroy

  # ステータスの列挙
  STATUSES = {
    scheduled: "Scheduled",
    in_progress: "In Progress",
    final: "Final"
  }.freeze

  # バリデーション
  validates :date, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES.values }
  validates :home_team_id, presence: true
  validates :visitor_team_id, presence: true
  validate :different_teams

  # コールバック
  before_create :generate_game_pk

  # スコープ
  scope :scheduled, -> { where(status: STATUSES[:scheduled]) }
  scope :in_progress, -> { where(status: STATUSES[:in_progress]) }
  scope :finished, -> { where(status: STATUSES[:final]) }

  # 試合開始
  def start!
    raise StandardError, "Game is not in scheduled state" unless status == STATUSES[:scheduled]

    update!(status: STATUSES[:in_progress])
  end

  # 試合終了
  def finish!
    raise StandardError, "Game is not in progress" unless status == STATUSES[:in_progress]
    raise StandardError, "Game must have at least 9 innings" if innings.count < 18 # 9イニング × 2半

    update!(status: STATUSES[:final])
  end

  # 現在のイニング取得
  def current_inning_number
    return 1 if innings.empty?

    last_inning = innings.order(:inning_number, :half).last
    last_inning.half == "bottom" ? last_inning.inning_number + 1 : last_inning.inning_number
  end

  # 現在のイニング状態（Top/Bottom）
  def current_inning_state
    return "Top" if innings.empty?

    last_inning = innings.order(:inning_number, :half).last
    last_inning.half == "top" ? "Bottom" : "Top"
  end

  # チームごとの合計スコア
  def total_score_for_team(team_type)
    return { runs: 0, hits: 0, errors: 0 } if innings.empty?

    half_value = team_type == :home ? "bottom" : "top"
    team_innings = innings.where(half: half_value)

    {
      runs: team_innings.sum(:runs),
      hits: team_innings.sum(:hits),
      errors: team_innings.sum(:error_count)
    }
  end

  private

  def different_teams
    if home_team_id == visitor_team_id
      errors.add(:base, "Home team and visitor team must be different")
    end
  end

  def generate_game_pk
    # gamePkの自動生成（999から始まる連番）
    max_game_pk = Game.maximum(:game_pk) || 999_000_000
    self.game_pk = max_game_pk + 1
  end
end
