defmodule GraphexTest do
  use ExUnit.Case
  require Graphex
  import Graphex

  defp row({:primary_key, item}, index) do
    tr(
      td(
        [port: "f#{index}", align: "LEFT"],
        u(font([face: "Helvetica"], item))
      )
    )
  end

  defp row({:foreign_key, item}, index) do
    tr(
      td(
        [port: "f#{index}", align: "LEFT"],
        i(u(font([face: "Helvetica"], item)))
      )
    )
  end

  defp row(item, index) when is_binary(item) do
    tr(
      td(
        [port: "f#{index}", align: "LEFT"],
        font([face: "Helvetica"], item)
      )
    )
  end

  defp rows(items) do
    for {item, i} <- Enum.with_index(items), do: row(item, i)
  end

  defp record(name, items, color, attrs) do
    rows = [
      th(
        td(
          b(
            font(
              ["point-size": "16", face: "Helvetica"],
              name
            )
          )
        )
      )
      | rows(items)
    ]

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

    defnode(name, Keyword.merge([label: html_lable(table), shape: "none"], attrs))
  end

  # test "digraph" do
  #   g =
  #     digraph do
  #       graph_attr(rankdir: "LR", labeljust: "jleft", splines: "spline", labelloc: "vtop")
  #       node_attr(rankdir: "TB", shape: "plaintext")
  #       edge_attr(fontname: "Helvetica")

  #       "ranksep=2"

  #       record(
  #         "Configs",
  #         [
  #           {:primary_key, "name [varchar, not null]"},
  #           "schema [text, not null]",
  #           "namespace [varchar, not null]",
  #           "cluster [varchar, not null]"
  #         ],
  #         "#d0e0d0",
  #         shape: "none"
  #       )

  #       record(
  #         "Revisions",
  #         [
  #           {:primary_key, "revision_id [varchar, not null]"},
  #           "value [text, not null]",
  #           "metadata [text]",
  #           "created_at [datetime, not null]",
  #           {:foreign_key, "config_name [varchar, not null]"}
  #         ],
  #         "#ececfc",
  #         shape: "none"
  #       )

  #       record(
  #         "Tags",
  #         [
  #           {:primary_key, "id [bigint, not null]"},
  #           "name [varchar, not null]",
  #           {:foreign_key, "config_name [varchar, not null]"}
  #         ],
  #         "#fcecec",
  #         shape: "none"
  #       )

  #       defedge({"Revisions", "f4"}, {"Configs", "f0"},
  #         arrowhead: "none",
  #         style: "dashed",
  #         headlabel: "   1",
  #         taillabel: "   0..N"
  #       )

  #       defedge({"Tags", "f2"}, {"Configs", "f0"},
  #         arrowhead: "none",
  #         style: "dashed",
  #         headlabel: "   1",
  #         taillabel: "   0..N"
  #       )
  #     end

  #   IO.puts("Ouput::")
  #   # IO.puts(Enum.join(String.split(g, "\n")))
  #   IO.puts(g)

  #   # assert """
  #   #        digraph ERD {
  #   #          node_attr [ randir = "TB" ]
  #   #          graph_attr [ randir = "TB" ]
  #   #          edge_attr [ randir = "LR" ]
  #   #          Dept [ label = <<table bgcolor="#d0e0d0" border="0">
  #   #            <tr >
  #   #              <td >
  #   #                dname
  #   #              </td>
  #   #            </tr>
  #   #            <tr >
  #   #              <td >
  #   #                deptno
  #   #              </td>
  #   #            </tr>
  #   #          </table>> shape = "none" ]
  #   #        }
  #   #        """ == g
  # end

  defp create_rec(name, items, color) do
    rows = [
      th(
        td(
          b(
            font(
              ["point-size": "16", face: "Helvetica"],
              name
            )
          )
        )
      )
      | rows(items)
    ]

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

    [name, [label: html_lable(table), shape: "none"]]
  end

  test "new graph" do
    g =
      digraph do
        [graph: [rankdir: "LR", labeljust: "jleft", splines: "spline", labelloc: "vtop"]]
        [node: [rankdir: "TB", shape: "plaintext"]]
        [edge: [fontname: "Helvetica"]]

        "ranksep=2"

        subgraph "cluster_0" do
          [style: "filled"]
          [color: "lightgrey"]
          [node: [style: "filled", color: "white"]]
          "a0 -> a1 -> a2 -> a3"
          [label: "Hello"]
        end

        """
        subgraph cluster_1 {
          node [style=filled];
          b0 -> b1 -> b2 -> b3;
          label = "World";
          color=blue
        }
        """

        create_rec(
          "Configs",
          [
            {:primary_key, "name [varchar, not null]"},
            "schema [text, not null]",
            "namespace [varchar, not null]",
            "cluster [varchar, not null]"
          ],
          "#d0e0d0"
        )

        create_rec(
          "Revisions",
          [
            {:primary_key, "revision_id [varchar, not null]"},
            "value [text, not null]",
            "metadata [text]",
            "created_at [datetime, not null]",
            {:foreign_key, "config_name [varchar, not null]"}
          ],
          "#ececfc"
        )

        create_rec(
          "Tags",
          [
            {:primary_key, "id [bigint, not null]"},
            "name [varchar, not null]",
            {:foreign_key, "config_name [varchar, not null]"}
          ],
          "#fcecec"
        )

        [
          "Revisions:f4 -> Configs:f0": [
            arrowhead: "none",
            style: "dashed",
            headlabel: "   1",
            taillabel: "   0..N"
          ]
        ]

        [
          "Tags:f2 -> Configs:f0": [
            arrowhead: "none",
            style: "dashed",
            headlabel: "   1",
            taillabel: "   0..N"
          ]
        ]
      end

    IO.puts("Ouput::")
    # IO.puts(Enum.join(String.split(g, "\n")))
    IO.puts(g)
  end
end
