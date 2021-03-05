defmodule Graphex.ERD do
  require Graphex
  import Graphex

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

  def entity(name, items, color) do
    row =
      table_header do
        table_data do
          bold do
            font "point-size": "16", face: "Helvetica" do
              name
            end
          end
        end
      end

    rows = [row] ++ for item <- items, do: row(item)

    table =
      table bgcolor: color, border: "0", cellborder: "1", cellpadding: "4", cellspacing: "0" do
        rows
      end

    [name, [label: html_label(table), shape: "none"]]
  end

  @edge_attrs [arrowhead: "none", style: "dashed"]

  def relation(from, to, from_relationship, to_relationship) do
    [
      "#{from} -> #{to}",
      Keyword.merge(@edge_attrs,
        headlabel: "   #{from_relationship}",
        taillabel: " #{to_relationship}"
      )
    ]
  end

  @template [
    [graph: [rankdir: "LR", labeljust: "jleft", splines: "spline", labelloc: "vtop"]],
    [node: [rankdir: "TB", shape: "plaintext", fontname: "Helvetica"]],
    [edge: [fontname: "Helvetica"]],
    [ranksep: "2"]
  ]

  defmacro er_diagram(name \\ "", do: body) do
    body = do_block_to_list(body)

    quote do
      body = unquote(@template ++ body)
      fmt_block("digraph", unquote(name), body)
    end
  end
end
