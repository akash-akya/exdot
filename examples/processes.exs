defmodule Examples.Processes do
  require Exdot
  import Exdot

  defp edge(a, b), do: "#{a} -> #{b}"

  # return dot-formatted string
  def generate do
    digraph do
      subgraph "cluster_0" do
        [style: "filled"]
        [color: "lightgrey"]
        [node: [style: "filled", color: "white"]]

        "a0 -> a1 -> a2 -> a3"
        [label: "process #1"]
      end

      # it can be any string
      """
      subgraph cluster_1 {
        node [style=filled];
        b0 -> b1 -> b2 -> b3;
        label = "process #2";
        color=blue
      }
      """

      # it can be funcation call
      edge(:start, :a0)
      edge(:start, :b0)
      edge(:a1, :b3)
      edge(:b2, :a3)
      edge(:a3, :a0)
      edge(:a3, :end)
      edge(:b3, :end)

      # it can two element list
      ["start", [shape: "Mdiamond"]]
      ["end", [shape: "Msquare"]]
    end
  end
end
