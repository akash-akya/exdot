defmodule Graphex.Utils do
  def block_to_list({:__block__, _meta, block}), do: block
  def block_to_list(ast), do: [ast]

  def indent_str(body, indentation) do
    String.trim(body)
    |> String.split("\n")
    |> Enum.join("\n" <> indentation)
  end

  def indent(lines, joiner, indentation \\ "  ") when is_list(lines) do
    Enum.join(lines, joiner) |> indent_str(indentation)
  end

  def dquote(str) when is_binary(str), do: inspect(str)

  # grammar

  defp fmt_value("<" <> _ = html_label), do: html_label
  defp fmt_value(v) when is_binary(v), do: inspect(v)
  defp fmt_value(v) when is_atom(v), do: inspect(v)
  defp fmt_value(v), do: to_string(v)

  defp fmt_kv({k, v}), do: "#{k} = #{fmt_value(v)}"

  def attr_list(attrs) do
    attrs_str = Enum.map(attrs, &fmt_kv/1) |> indent(" ")
    " [ #{attrs_str} ] "
  end

  def fmt_body([{name, attrs}]) when is_atom(name) and is_list(attrs) do
    to_string(name) <> attr_list(attrs)
  end

  def fmt_body([name, attrs]) when is_atom(name) and is_list(attrs) do
    to_string(name) <> attr_list(attrs)
  end

  def fmt_body([{name, value}]) when is_atom(name) and not is_list(value) do
    "#{name} = #{value}"
  end

  def fmt_body([name, value]) when is_atom(name) and not is_list(value) do
    "#{name} = #{value}"
  end

  def fmt_body([key, attrs]) when is_binary(key) and is_list(attrs) do
    key <> attr_list(attrs)
  end

  def fmt_body(stmt) when is_binary(stmt), do: stmt

  def fmt_body({func, _, args} = stmt) when is_atom(func) and is_list(args), do: stmt

  def normalize(v), do: v

  def block(type, name, stmts) do
    body =
      stmts
      |> Enum.map(&normalize/1)
      |> Enum.map(&fmt_body/1)
      |> indent("\n")

    """
    #{type} #{name} {
      #{body}
    }
    """
  end
end

defmodule Graphex.Html do
  import Graphex.Utils

  defp fmt_attrs(attrs) do
    for {k, v} <- attrs, do: "#{k}=#{inspect(v)} "
  end

  defp fmt_html_node(name, attrs, body) do
    name = String.upcase(to_string(name))

    """
    <#{name} #{fmt_attrs(attrs)}>#{body}</#{name}>
    """
    |> indent_str("  ")
  end

  def fmt_html(node) when is_binary(node), do: node
  def fmt_html(nodes) when is_list(nodes), do: Enum.map(nodes, &fmt_html/1) |> indent("\n")

  def fmt_html(node) when is_map(node) do
    [{key, {attrs, body}}] = Map.to_list(node)
    fmt_html_node(key, attrs, fmt_html(body))
  end
end

defmodule Graphex do
  import Graphex.Utils
  import Graphex.Html

  defp fmt_value("<" <> _ = html_label), do: html_label
  defp fmt_value(v) when is_binary(v), do: inspect(v)
  defp fmt_value(v) when is_atom(v), do: inspect(v)
  defp fmt_value(v), do: to_string(v)

  defp fmt_kv({k, v}), do: "#{k} = #{fmt_value(v)}"

  defp fmt_attrs(attrs) do
    Enum.map(attrs, &fmt_kv/1) |> indent(" ")
  end

  defp stmt(name, []), do: to_string(name)
  defp stmt(name, attrs), do: to_string(name) <> " [ " <> fmt_attrs(attrs) <> " ]"

  for keyword <- [:graph, :node, :edge] do
    def unquote(String.to_atom("#{keyword}_attr"))(attrs), do: stmt(unquote(keyword), attrs)
  end

  def defnode(name, attrs), do: stmt(inspect(name), attrs)

  def defedge({a, hp}, {b, tp}, attrs),
    do: stmt("#{dquote(a)}:#{dquote(hp)} -> #{dquote(b)}:#{dquote(tp)}", attrs)

  def html_lable(body), do: "<#{fmt_html(body)}>"

  for node <- [:table, :tr, :td, :b, :u, :i, :th, :font, :br, :hr] do
    def unquote(node)(body), do: %{unquote(node) => {[], body}}
    def unquote(node)(attrs, body), do: %{unquote(node) => {attrs, body}}
  end

  defmacro digraph(name \\ "", do: body) do
    quote do: block("digraph", unquote(name), unquote(block_to_list(body)))
  end

  defmacro subgraph(name \\ "", do: body) do
    quote do: block("subgraph", unquote(name), unquote(block_to_list(body)))
  end

  defmacro graph(name \\ "", do: body) do
    quote do: block("graph", unquote(name), unquote(block_to_list(body)))
  end
end
