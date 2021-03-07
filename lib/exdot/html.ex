defmodule Exdot.Html do
  require Exdot
  import Exdot

  @type html_tag :: map()

  @moduledoc """
  Convenience macros to create HTML string.

  It takes attributes and body as input and returns HTML a map which represent the html. `html_label/1` then converts it to correct string which can used as [HTML like label](https://graphviz.org/doc/info/shapes.html#html)

  It is of the form:

  ```
  html_tag attribute_list do
    body
  end
  ```

  Macros have more verbose name than the corresponding html tag to avoid unintentional name collision.

  Example:

  ```
  table bgcolor: "#D0E0D0", border: "0", cellborder: "1", cellspacing: "0" do
    table_row do
      table_data align: "LEFT" do
        "Foo"
      end
    end

    table_row do
      table_data align: "LEFT" do
        "Bar"
      end
    end
  end
  ```

  Produces

  ```html
  <TABLE BGCOLOR="#D0E0D0" BORDER="0" CELLBORDER="1" CELLSPACING="0" >
    <TR ><TD ALIGN="LEFT" >Foo</TD></TR>
    <TR ><TD ALIGN="LEFT" >Bar</TD></TR>
  </TABLE>
  ```

  See `Exdot.ERD` for example
  """

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

  @doc """
  Takes html map constructed using the macros and produces formatted string which can be used as html_label

  ```
  html_label(
    font "point-size": "16", face: "Helvetica" do
      "Foo "
    end
  )
  ```

  Produces

  ```
  "<<FONT POINT-SIZE=\\"16\\" FACE=\\"Helvetica\\" >Foo</FONT>>"
  ```
  """
  @spec html_label(html_tag()) :: String.t()
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
    @doc """
    takes attributes and do-block and returns **`<#{tag}>`** HTML tag
    """
    @spec unquote(tag_name)(keyword(), term()) :: html_tag()
    defmacro unquote(tag_name)(attrs \\ [], do: body) do
      tag = unquote(tag)

      quote do
        %{unquote(tag) => {unquote(attrs), unquote(do_block_to_list(body))}}
      end
    end
  end
end
