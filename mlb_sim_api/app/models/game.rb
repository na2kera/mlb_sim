class Game < ApplicationRecord
  belongs_to :home_team
  belongs_to :visitor_team
end
