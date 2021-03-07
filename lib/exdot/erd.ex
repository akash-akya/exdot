defmodule Exdot.ERD do
  require Exdot
  import Exdot

  require Exdot.Html
  import Exdot.Html

  @type field_name :: String.t()
  @type fields :: [{field_name, attributes :: [atom()]}]

  @moduledoc """
  Simple DSL-*ish* template or creating Entity-Replationship Diagram. Inspired by [ERD](https://github.com/BurntSushi/erd). It produces the dot-file which looks similar to ERD.

  ```
  er_diagram do
    entity(
      "Students",
      [
        {"id", [:varchar, :not_null, :pk]},
        {"name", [:varchar, :not_null]},
        {"DOB", [:date_time, :not_null]},
        {"phone", [:varchar]},
        {"address", [:text]},
        {"college_id", [:varchar, :not_null, :fk]}
      ],
      "#d0e0d0"
    )

    entity(
      "Colleges",
      [
        {"id", [:varchar, :not_null, :pk]},
        {"name", [:text, :not_null]},
        {"address", [:text]}
      ],
      "#ececfc"
    )

    relation("Students:id", "Colleges:id", "1..N", "1")
  end
  ```
  """

  @template [
    [graph: [rankdir: "LR", labeljust: "jleft", splines: "spline", labelloc: "vtop"]],
    [node: [rankdir: "TB", shape: "plaintext", fontname: "Helvetica"]],
    [edge: [fontname: "Helvetica"]],
    [ranksep: "0"]
  ]

  @doc """
  Creates Graphviz digraph block similar to `Exdot.digraph` but with a predefined template.
  """
  @spec er_diagram(String.t(), do_block :: [Exdot.expr()]) :: String.t()
  defmacro er_diagram(name \\ "", do: body) do
    body = do_block_to_list(body)

    quote do
      body = unquote(@template ++ body)
      fmt_block("digraph", unquote(name), body)
    end
  end

  @doc """
  Creates graphviz node for Entity.

  ```
    entity(
      "Colleges",
      [
        {"id", [:varchar, :not_null, :pk]},
        {"name", [:text, :not_null]},
        {"address", [:text]}
      ],
      "#ececfc"
    )
  ```
  """
  @spec entity(String.t(), fields(), String.t()) :: Exdot.expr()
  def entity(name, items, color \\ "#d0e0d0") do
    table =
      table bgcolor: color, border: "0", cellborder: "1", cellpadding: "4", cellspacing: "0" do
        table_header do
          table_data do
            bold do
              font "point-size": "16", face: "Helvetica" do
                name
              end
            end
          end
        end

        for item <- items, do: row(item)
      end

    [name, [label: html_label(table), shape: "none"]]
  end

  @edge_attrs [arrowhead: "none", style: "dashed", color: "Gray50", minlen: "10"]

  @doc """
  Creates graphviz edge for the relationship between entities.

  ```
  relation("Students:id", "Colleges:id", "1..N", "1")
  ```
  """
  @spec relation(String.t(), String.t(), String.t(), String.t()) :: Exdot.expr()
  def relation(from, to, from_relationship, to_relationship) do
    [
      "#{from} -> #{to}",
      Keyword.merge(@edge_attrs,
        headlabel: "   #{from_relationship}",
        taillabel: " #{to_relationship}"
      )
    ]
  end

  defp tr_td(port, value) do
    table_row do
      table_data port: port, align: "LEFT" do
        value
      end
    end
  end

  defp fmt_field(field, attrs) do
    str = Enum.join(attrs, ", ")

    font do
      "#{field} [#{str}]"
    end
  end

  defp row({field, attrs}) do
    label =
      cond do
        :pk in attrs ->
          underline do
            fmt_field(field, List.delete(attrs, :pk))
          end

        :fk in attrs ->
          italic do
            underline do
              fmt_field(field, List.delete(attrs, :fk))
            end
          end

        true ->
          fmt_field(field, attrs)
      end

    tr_td(field, label)
  end
end
