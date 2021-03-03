defmodule Graphex.ERDTest do
  use ExUnit.Case
  import Graphex.ERD

  test "erd" do
    diag =
      erdiagram do
        record(
          "Configs",
          [
            {"name", [:varchar, :not_null, :pk]},
            {"schema", [:varchar, :not_null]},
            {"namespace", [:varchar, :not_null]},
            {"cluster", [:varchar, :not_null]}
          ],
          "#d0e0d0"
        )

        record(
          "Revisions",
          [
            {"revision_id", [:varchar, :not_null, :pk]},
            {"value", [:text, :not_null]},
            {"metadata", [:text]},
            {"created_at", [:datetime, :not_null]},
            {"config_name", [:varchar, :not_null, :fk]}
          ],
          "#ececfc"
        )

        record(
          "Tags",
          [
            {"id", [:bigint, :not_null, :pk]},
            {"name", [:varchar, :not_null]},
            {"config_name", [:varchar, :not_null, :fk]}
          ],
          "#fcecec"
        )

        relation("Revisions:config_name", "Configs:name", "1", "0..N")
        relation("Tags:config_name", "Configs:name", "1", "0..N")
      end

    IO.puts(diag)
  end
end
