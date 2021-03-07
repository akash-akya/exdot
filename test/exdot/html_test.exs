defmodule Exdot.HtmlTest do
  use ExUnit.Case, async: true

  require Exdot.Html
  import Exdot.Html

  test "tag with attributes" do
    table =
      table bgcolor: "#D0E0D0", border: "0" do
        "body"
      end

    assert table == %{
             table: {[bgcolor: "#D0E0D0", border: "0"], ["body"]}
           }
  end

  test "tag without attributes" do
    table =
      table do
        "body"
      end

    assert table == %{
             table: {[], ["body"]}
           }
  end

  test "tag with nested tag" do
    table =
      table bgcolor: "#D0E0D0" do
        table_row do
          table_data align: "LEFT" do
            "Foo"
          end
        end

        table_row do
          table_data align: "LEFT" do
            "Bar"
          end
        end
      end

    assert table == %{
             table:
               {[bgcolor: "#D0E0D0"],
                [
                  %{tr: {[], [%{td: {[align: "LEFT"], ["Foo"]}}]}},
                  %{tr: {[], [%{td: {[align: "LEFT"], ["Bar"]}}]}}
                ]}
           }
  end

  test "tag with loop" do
    table =
      table bgcolor: "#D0E0D0" do
        for field <- ["name", "addr", "phone"] do
          table_row do
            table_data align: "LEFT" do
              field
            end
          end
        end
      end

    assert table == %{
             table:
               {[bgcolor: "#D0E0D0"],
                [
                  [
                    %{tr: {[], [%{td: {[align: "LEFT"], ["name"]}}]}},
                    %{tr: {[], [%{td: {[align: "LEFT"], ["addr"]}}]}},
                    %{tr: {[], [%{td: {[align: "LEFT"], ["phone"]}}]}}
                  ]
                ]}
           }
  end

  test "html_label" do
    label =
      html_label(
        font "point-size": "16", face: "Helvetica" do
          "Foo"
        end
      )

    assert label == "<<FONT POINT-SIZE=\"16\" FACE=\"Helvetica\" >Foo</FONT>>"
  end

  test "html_label without list block" do
    label =
      html_label(
        table bgcolor: "#D0E0D0" do
          for field <- ["name", "addr", "phone"] do
            table_row do
              table_data align: "LEFT" do
                field
              end
            end
          end
        end
      )

    assert label ==
             "<<TABLE BGCOLOR=\"#D0E0D0\" ><TR ><TD ALIGN=\"LEFT\" >name</TD></TR>\n      <TR ><TD ALIGN=\"LEFT\" >addr</TD></TR>\n      <TR ><TD ALIGN=\"LEFT\" >phone</TD></TR></TABLE>>"
  end
end
