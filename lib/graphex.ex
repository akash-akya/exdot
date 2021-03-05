defmodule Graphex do
  def do_block_to_list({:__block__, _meta, block}), do: block
  def do_block_to_list(ast), do: [ast]

  defp indent_str(body, indentation) do
    String.trim(body)
    |> String.split("\n")
    |> Enum.join("\n" <> indentation)
  end

  defp indent(lines, joiner, indentation \\ "  ") when is_list(lines) do
    Enum.join(lines, joiner) |> indent_str(indentation)
  end

  defp fmt_html_attrs(attrs) do
    for {k, v} <- attrs do
      k = String.upcase(to_string(k))
      "#{k}=#{inspect(v)} "
    end
  end

  defp fmt_html_node(name, attrs, body) do
    name = String.upcase(to_string(name))
    indent_str("<#{name} #{fmt_html_attrs(attrs)}>#{body}</#{name}>", "  ")
  end

  defp fmt_html(node) when is_binary(node), do: node

  defp fmt_html(nodes) when is_list(nodes), do: Enum.map(nodes, &fmt_html/1) |> indent("\n")

  defp fmt_html(node) when is_map(node) do
    [{key, {attrs, body}}] = Map.to_list(node)
    fmt_html_node(key, attrs, fmt_html(body))
  end

  def html_label(body), do: "<#{fmt_html(body)}>"

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

  def fmt_block(type, name, stmts) do
    body = Enum.map(stmts, &fmt_body/1) |> indent("\n")

    """
    #{type} #{name} {
      #{body}
    }
    """
  end

  for {tag_name, tag} <- [
        {:table, :table},
        {:table_row, :tr},
        {:table_data, :td},
        {:bold, :b},
        {:underline, :u},
        {:italic, :i},
        {:table_header, :th},
        {:font, :font},
        {:break, :br},
        {:horizontal_rule, :hr},
        {:sub, :sub},
        {:sup, :sup},
        {:vertical_rule, :vr},
        {:img, :img},
        {:overline, :o},
        {:strike_through, :s}
      ] do
    defmacro unquote(tag_name)(attrs \\ [], do: body) do
      tag = unquote(tag)

      quote do
        %{unquote(tag) => {unquote(attrs), do_block_to_list(unquote(body))}}
      end
    end
  end

  for {name} <- [:digraph, :subgraph, :graph] do
    defmacro unquote(name)(label \\ "", do: body) do
      name = unquote(name)

      quote do
        fmt_block(unquote(name), unquote(label), unquote(do_block_to_list(body)))
      end
    end
  end
end
