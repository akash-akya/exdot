defmodule Examples.Game do
  require Exdot.ERD
  import Exdot.ERD

  def generate do
    er_diagram do
      entity(
        "player",
        [
          {"player_id", [:varchar, :not_null, :pk]},
          {"full_name", [:varchar, :not_null]},
          {"team", [:varchar, :not_null]},
          {"position", [:player_pos, :not_null]},
          {"status", [:player_status, :not_null]}
        ],
        "#d0e0d0"
      )

      entity(
        "team",
        [
          {"team_id", [:varchar, :not_null, :pk]},
          {"city", [:varchar, :not_null]},
          {"name", [:varchar, :not_null]}
        ],
        "#d0e0d0"
      )

      entity(
        "game",
        [
          {"gsis_id", [:gameid, :not_null, :pk]},
          {"start_time", [:utctime, :not_null]},
          {"week", [:usmallint, :not_null]},
          {"season_year", [:usmallint, :not_null]},
          {"season_type", [:season_phase, :not_null]},
          {"finished", [:boolean, :not_null]},
          {"home_team", [:varchar, :not_null]},
          {"home_score", [:usmallint, :not_null]},
          {"away_team", [:varchar, :not_null]},
          {"away_score", [:usmallint, :not_null]}
        ],
        "#ececfc"
      )

      entity(
        "drive",
        [
          {"gsis_id", [:gameid, :not_null, :fk]},
          {"drive_id", [:usmallint, :not_null, :pk]},
          {"start_field", [:field_pos, :null]},
          {"start_time", [:game_time, :not_null]},
          {"end_field", [:field_pos, :null]},
          {"end_time", [:game_time, :not_null]},
          {"pos_team", [:varchar, :not_null]},
          {"pos_time", [:pos_period, :null]}
        ],
        "#ececfc"
      )


      entity(
        "play_player",
        [
          {"gsis_id", [:gameid, :not_null, :fk]},
          {"drive_id", [:usmallint, :not_null, :fk]},
          {"play_id", [:usmallint, :not_null, :fk]},
          {"player_id", [:varchar, :not_null, :fk]},
          {"team", [:varchar, :not_null]}
        ],
        "#ececfc"
      )
      entity(
        "play",
        [
          {"gsis_id", [:gameid, :not_null, :fk]},
          {"drive_id", [:usmallint, :not_null, :fk]},
          {"play_id", [:usmallint, :not_null, :pk]},
          {"time", [:game_time, :not_null]},
          {"pos_team", [:varchar, :not_null]},
          {"yardline", [:field_pos, :null]},
          {"down", [:smallint, :null]},
          {"yards_to_go", [:smallint, :null]}
        ],
        "#ececfc"
      )

      entity(
        "meta",
        [
          {"version", [:smallint, :null]},
          {"season_type", [:hase, :null]},
          {"season_year", [:usmallint, :null]},
          {"week", [:usmallint, :null]}
        ],
        "#fcecec"
      )

      # Relationships

      relation("player", "team", "1", "0..N")
      relation("game", "team", "1", "0..N")
      relation("drive", "team", "1", "0..N")
      relation("play", "team", "1", "0..N")
      relation("play_player", "team", "1", "0..N")

      relation("game", "drive", "0..N", "1")
      relation("game", "play", "0..N", "1")
      relation("game", "play_player", "0..N", "1")

      relation("drive", "play", "0..N", "1")
      relation("drive", "play_player", "0..N", "1")
      relation("play", "play_player", "0..N", "1")
      relation("player", "play_player", "0..N", "1")
    end
  end
end
