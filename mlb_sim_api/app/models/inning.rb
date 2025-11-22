class Inning < ApplicationRecord
  belongs_to :game

  # バリデーション
  validates :inning_number, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :half, presence: true, inclusion: { in: %w[top bottom] }
  validates :runs, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :hits, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :error_count, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # 同じゲーム内で同じイニング番号と表裏の組み合わせが重複しないようにする
  validates :inning_number, uniqueness: { scope: [:game_id, :half] }

  # スコープ
  scope :top_innings, -> { where(half: "top") }
  scope :bottom_innings, -> { where(half: "bottom") }
  scope :ordered, -> { order(:inning_number, :half) }

  # イニングの序数表示（1st, 2nd, 3rd, etc.）
  def ordinal_number
    case inning_number
    when 1 then "1st"
    when 2 then "2nd"
    when 3 then "3rd"
    else "#{inning_number}th"
    end
  end
end
