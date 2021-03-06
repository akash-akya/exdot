defmodule Exdot do
  @moduledoc """
  Elixir abstraction generate Graphviz dot formatted string.

  ## Block Constructs

  Block constructs takes an optional name and set of *expressions* to return dot formatted string. Each expression inside the block is converted to dot format statement.

  ### Valid expressions within the block

  * Two element list. If second element is a list, it is treated as attr list

  ```
  [:graph, [rankdir: "LR", labeljust: "jleft"]]  # => graph [ rankdir = "LR" labeljust = "jleft" ]
  ["node", [shape: "plaintext"]]  # => node [ shape = "plaintext" ]
  [:ranksep, "2"]  # => raksep = "2"
  ```

  It can also be single pair keyword list. It is treated same as 2 element list

  ```
  [graph: [rankdir: "LR", labeljust: "jleft"]]  # => graph [ rankdir = "LR" labeljust = "jleft" ]
  ["node" => [shape: "plaintext"]]  # => graph [ rankdir = "LR" labeljust = "jleft" ]
  [ranksep: "2"]  # => ranksep = "2"
  ```

  * String. A String expression is emmitted as it is, this can used as an escape hatch to return any dot statements for which there is not special synatx, like edge.

  ```
  "Company:emp_name -> Employee:name [ style = \\"dashed\\" ]" # => Company:emp_name -> Employee:name [ style = "dashed" ]
  ```

  * Function call. Function must return any of the above valid values. This can be used as an abstraction to build high-level syntax or templates. See `Exdot.ERD`

  ```
  defmodule Graph do
    def edge(a, b), do: a <> " -> " <> b
  end

  digraph do
    ["Company" => [label: "Company"]]
    ["Employee" => [label: "Employee"]]

    Graph.edge("Company", "Employee")
  end
  ```
  """

  for name <- [:digraph, :subgraph, :graph] do
    @doc """
    Returns #{name} formatted string.

    See module documentation for more details
    """
    defmacro unquote(name)(label \\ "", do: body) do
      name = unquote(name)

      quote do
        fmt_block(unquote(name), unquote(label), unquote(do_block_to_list(body)))
      end
    end
  end

  @doc false
  def do_block_to_list({:__block__, _meta, block}), do: block
  def do_block_to_list(ast), do: [ast]

  @doc false
  def indent_str(body, indentation) do
    String.trim(body)
    |> String.split("\n")
    |> Enum.join("\n" <> indentation)
  end

  @doc false
  def indent(lines, joiner, indentation \\ "  ") when is_list(lines) do
    Enum.join(lines, joiner) |> indent_str(indentation)
  end

  defp fmt_value("<" <> _ = html_label), do: html_label
  defp fmt_value(v), do: inspect(v)

  defp fmt_kv(k, v), do: "#{k} = #{fmt_value(v)}"

  defp fmt_attrs(attrs) do
    attrs_str = Enum.map(attrs, fn {k, v} -> fmt_kv(k, v) end) |> indent(" ")
    "[ #{attrs_str} ]"
  end

  defp fmt_body(stmt) do
    case stmt do
      [{name, attrs}] -> fmt_body([name, attrs])
      [name, attrs] when is_list(attrs) -> to_string(name) <> " " <> fmt_attrs(attrs)
      [key, value] -> fmt_kv(key, value)
      [{func, _, args}] when is_atom(func) and is_list(args) -> stmt
      stmt when is_binary(stmt) -> stmt
    end
  end

  @doc false
  def fmt_block(type, name, stmts) do
    body = Enum.map(stmts, &fmt_body/1) |> indent("\n")

    """
    #{type} #{name} {
      #{body}
    }
    """
  end
end
