# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

mlb_teams = [
  {name: "Arizona Diamondbacks", abbreviation: "ARI", league: "NL"},
  {name: "Atlanta Braves", abbreviation: "ATL", league: "NL"},
  {name: "Baltimore Orioles", abbreviation: "BAL", league: "AL"},
  {name: "Boston Red Sox", abbreviation: "BOS", league: "AL"},
  {name: "Chicago Cubs", abbreviation: "CHC", league: "NL"},
  {name: "Chicago White Sox", abbreviation: "CWS", league: "AL"},
  {name: "Cincinnati Reds", abbreviation: "CIN", league: "NL"},
  {name: "Cleveland Guardians", abbreviation: "CLE", league: "AL"},
  {name: "Colorado Rockies", abbreviation: "COL", league: "NL"},
  {name: "Detroit Tigers", abbreviation: "DET", league: "AL"},
  {name: "Houston Astros", abbreviation: "HOU", league: "AL"},
  {name: "Kansas City Royals", abbreviation: "KC", league: "AL"},
  {name: "Los Angeles Angels", abbreviation: "LAA", league: "AL"},
  {name: "Los Angeles Dodgers", abbreviation: "LAD", league: "NL"},
  {name: "Miami Marlins", abbreviation: "MIA", league: "NL"},
  {name: "Milwaukee Brewers", abbreviation: "MIL", league: "NL"},
  {name: "Minnesota Twins", abbreviation: "MIN", league: "AL"},
  {name: "New York Mets", abbreviation: "NYM", league: "NL"},
  {name: "New York Yankees", abbreviation: "NYY", league: "AL"},
  {name: "Oakland Athletics", abbreviation: "OAK", league: "AL"},
  {name: "Philadelphia Phillies", abbreviation: "PHI", league: "NL"},
  {name: "Pittsburgh Pirates", abbreviation: "PIT", league: "NL"},
  {name: "San Diego Padres", abbreviation: "SD", league: "NL"},
  {name: "San Francisco Giants", abbreviation: "SF", league: "NL"},
  {name: "Seattle Mariners", abbreviation: "SEA", league: "AL"},
  {name: "St. Louis Cardinals", abbreviation: "STL", league: "NL"},
  {name: "Tampa Bay Rays", abbreviation: "TB", league: "AL"},
  {name: "Texas Rangers", abbreviation: "TEX", league: "AL"},
  {name: "Toronto Blue Jays", abbreviation: "TOR", league: "AL"},
  {name: "Washington Nationals", abbreviation: "WSH", league: "NL"}
]

ActiveRecord::Base.transaction do
  mlb_teams.each do |attrs|
    team = Team.find_or_initialize_by(abbreviation: attrs[:abbreviation])
    team.assign_attributes(attrs)
    team.save!
  end
end

puts "Seeded #{mlb_teams.count} MLB teams" if $stdout.tty?
