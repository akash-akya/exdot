defmodule Exdot.Html do
  require Exdot
  import Exdot

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

  defp fmt_html(nodes) when is_list(nodes) do
    Enum.map(nodes, &fmt_html/1)
    |> indent("\n")
  end

  defp fmt_html(node) when is_map(node) do
    [{key, {attrs, body}}] = Map.to_list(node)
    fmt_html_node(key, attrs, fmt_html(body))
  end

  def html_label(body), do: "<#{fmt_html(body)}>"

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
        %{unquote(tag) => {unquote(attrs), unquote(do_block_to_list(body))}}
      end
    end
  end
end
