defmodule ExdotTest do
  use ExUnit.Case, async: true

  require Exdot
  import Exdot

  describe "block" do
    test "block attribute expr" do
      diag =
        digraph do
          [raksep: "2"]
        end

      assert """
             digraph  {
               raksep = "2"
             }
             """ == diag
    end

    test "node as keyword list expr" do
      diag =
        digraph do
          [node: [shape: "plaintext"]]
        end

      assert """
             digraph  {
               node [ shape = "plaintext" ]
             }
             """ == diag
    end

    test "node as 2 elem list expr" do
      diag =
        digraph do
          ["node", [shape: "plaintext"]]
        end

      assert """
             digraph  {
               node [ shape = "plaintext" ]
             }
             """ == diag
    end

    test "string expr" do
      diag =
        digraph do
          "Foo -> Bar"
        end

      assert """
             digraph  {
               Foo -> Bar
             }
             """ == diag
    end

    test "multiple expr" do
      diag =
        digraph do
          [node: [shape: "plaintext"]]

          ["Foo", []]
          ["Bar", []]

          "Foo -> Bar"
        end

      assert """
             digraph  {
               node [ shape = "plaintext" ]
               Foo [  ]
               Bar [  ]
               Foo -> Bar
             }
             """ == diag
    end

    test "function call expr" do
      diag =
        digraph do
          edge("Foo", "Bar")
        end

      assert """
             digraph  {
               Foo -> Bar
             }
             """ == diag
    end

    defp edge(a, b) do
      "#{a} -> #{b}"
    end
  end
end
