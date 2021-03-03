defmodule Graphex.ERD do
  import Graphex

  defp tr_td(port, value), do: tr(td([port: port, align: "LEFT"], value))

  defp fmt_field(field, attrs) do
    str = Enum.join(attrs, ", ")
    font("#{field} [#{str}]")
  end

  defp row({field, attrs}) do
    label =
      cond do
        :pk in attrs -> u(fmt_field(field, List.delete(attrs, :pk)))
        :fk in attrs -> i(u(fmt_field(field, List.delete(attrs, :fk))))
        true -> fmt_field(field, attrs)
      end

    tr_td(field, label)
  end

  def record(name, items, color) do
    rows =
      [th(td(b(font(["point-size": "16", face: "Helvetica"], name))))] ++
        for item <- items, do: row(item)

    table =
      table(
        [
          bgcolor: color,
          border: "0",
          cellborder: "1",
          cellpadding: "4",
          cellspacing: "0"
        ],
        rows
      )

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

  defmacro erdiagram(name \\ "", do: body) do
    body = do_block_to_list(body)

    quote do
      body = unquote(@template ++ body)
      block("digraph", unquote(name), body)
    end
  end
end
