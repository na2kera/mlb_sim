# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

mlb_teams = [
  {name: "Arizona Diamondbacks", abbreviation: "ARI", league: "NL", mlb_id: 109, location_name: "Arizona"},
  {name: "Atlanta Braves", abbreviation: "ATL", league: "NL", mlb_id: 144, location_name: "Atlanta"},
  {name: "Baltimore Orioles", abbreviation: "BAL", league: "AL", mlb_id: 110, location_name: "Baltimore"},
  {name: "Boston Red Sox", abbreviation: "BOS", league: "AL", mlb_id: 111, location_name: "Boston"},
  {name: "Chicago Cubs", abbreviation: "CHC", league: "NL", mlb_id: 112, location_name: "Chicago"},
  {name: "Chicago White Sox", abbreviation: "CWS", league: "AL", mlb_id: 145, location_name: "Chicago"},
  {name: "Cincinnati Reds", abbreviation: "CIN", league: "NL", mlb_id: 113, location_name: "Cincinnati"},
  {name: "Cleveland Guardians", abbreviation: "CLE", league: "AL", mlb_id: 114, location_name: "Cleveland"},
  {name: "Colorado Rockies", abbreviation: "COL", league: "NL", mlb_id: 115, location_name: "Colorado"},
  {name: "Detroit Tigers", abbreviation: "DET", league: "AL", mlb_id: 116, location_name: "Detroit"},
  {name: "Houston Astros", abbreviation: "HOU", league: "AL", mlb_id: 117, location_name: "Houston"},
  {name: "Kansas City Royals", abbreviation: "KC", league: "AL", mlb_id: 118, location_name: "Kansas City"},
  {name: "Los Angeles Angels", abbreviation: "LAA", league: "AL", mlb_id: 108, location_name: "Los Angeles"},
  {name: "Los Angeles Dodgers", abbreviation: "LAD", league: "NL", mlb_id: 119, location_name: "Los Angeles"},
  {name: "Miami Marlins", abbreviation: "MIA", league: "NL", mlb_id: 146, location_name: "Miami"},
  {name: "Milwaukee Brewers", abbreviation: "MIL", league: "NL", mlb_id: 158, location_name: "Milwaukee"},
  {name: "Minnesota Twins", abbreviation: "MIN", league: "AL", mlb_id: 142, location_name: "Minnesota"},
  {name: "New York Mets", abbreviation: "NYM", league: "NL", mlb_id: 121, location_name: "New York"},
  {name: "New York Yankees", abbreviation: "NYY", league: "AL", mlb_id: 147, location_name: "New York"},
  {name: "Oakland Athletics", abbreviation: "OAK", league: "AL", mlb_id: 133, location_name: "Oakland"},
  {name: "Philadelphia Phillies", abbreviation: "PHI", league: "NL", mlb_id: 143, location_name: "Philadelphia"},
  {name: "Pittsburgh Pirates", abbreviation: "PIT", league: "NL", mlb_id: 134, location_name: "Pittsburgh"},
  {name: "San Diego Padres", abbreviation: "SD", league: "NL", mlb_id: 135, location_name: "San Diego"},
  {name: "San Francisco Giants", abbreviation: "SF", league: "NL", mlb_id: 137, location_name: "San Francisco"},
  {name: "Seattle Mariners", abbreviation: "SEA", league: "AL", mlb_id: 136, location_name: "Seattle"},
  {name: "St. Louis Cardinals", abbreviation: "STL", league: "NL", mlb_id: 138, location_name: "St. Louis"},
  {name: "Tampa Bay Rays", abbreviation: "TB", league: "AL", mlb_id: 139, location_name: "Tampa Bay"},
  {name: "Texas Rangers", abbreviation: "TEX", league: "AL", mlb_id: 140, location_name: "Texas"},
  {name: "Toronto Blue Jays", abbreviation: "TOR", league: "AL", mlb_id: 141, location_name: "Toronto"},
  {name: "Washington Nationals", abbreviation: "WSH", league: "NL", mlb_id: 120, location_name: "Washington"}
]

ActiveRecord::Base.transaction do
  mlb_teams.each do |attrs|
    team = Team.find_or_initialize_by(abbreviation: attrs[:abbreviation])
    team.assign_attributes(attrs)
    team.save!
  end
end

puts "Seeded #{mlb_teams.count} MLB teams" if $stdout.tty?
