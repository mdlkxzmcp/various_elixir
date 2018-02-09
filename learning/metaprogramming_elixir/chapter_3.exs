# Advanced Compile-Time Code Generation

## Generating Functions from External Data
### Making Use of Existing Datasets

# -- http://www.iana.org/assignments/media-types/media-types.xhtml
defmodule Mime do
  @external_resource mimes_path = Path.join([__DIR__, "mimes.txt"])

  for line <- File.stream!(mimes_path, [], :line) do
    [type, rest] = line |> String.split("\t") |> Enum.map(&String.trim(&1))
    extensions = String.split(rest, ~r/,\s?/)

    def exts_from_type(unquote(type)), do: unquote(extensions)
    def type_from_ext(ext) when ext in unquote(extensions), do: unquote(type)
  end

  def exts_from_type(_type), do: []
  def type_from_ext(_ext), do: nil
  def valid_type?(type), do: exts_from_type(type) |> Enum.any?()
end

## Building an Internationalization Library

# 2. Implement a skeleton module with metaprogramming hooks
defmodule Translator do
  defmacro __using__(_options) do
    quote do
      Module.register_attribute(__MODULE__, :locales, accumulate: true, persist: false)
      import unquote(__MODULE__), only: [locale: 2]
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(env) do
    compile(Module.get_attribute(env.module, :locales))
  end

  defmacro locale(name, mappings) do
    quote bind_quoted: [name: name, mappings: mappings] do
      @locales {name, mappings}
    end
  end

  # 3. Generate Code from Your Accumulated Module Attributes
  def compile(translations) do
    translations_ast =
      for {locale, mappings} <- translations do
        deftranslations(locale, "", mappings)
      end

    quote do
      def t(locale, path, bindings \\ [])
      unquote(translations_ast)
      def t(_locale, _path, _bindings), do: {:error, :no_translation}
    end
  end

  defp deftranslations(locale, current_path, mappings) do
    for {key, val} <- mappings do
      path = append_path(current_path, key)

      if Keyword.keyword?(val) do
        deftranslations(locale, path, val)
      else
        quote do
          def t(unquote(locale), unquote(path), bindings) do
            unquote(interpolate(val))
          end
        end
      end
    end
  end

  # Final Step: Identify Areas for Compile-Time Optimizations
  defp interpolate(string) do
    ~r/(?<head>)%{[^}]+}(?<tail>)/
    |> Regex.split(string, on: [:head, :tail])
    |> Enum.reduce("", fn
      <<"%{" <> rest>>, acc ->
        key = String.to_atom(String.trim_trailing(rest, "}"))

        quote do
          unquote(acc) <> to_string(Keyword.fetch!(bindings, unquote(key)))
        end

      segment, acc ->
        quote do: unquote(acc) <> unquote(segment)
    end)
  end

  defp append_path("", next), do: to_string(next)
  defp append_path(current, next), do: "#{current}.#{next}"
end

# 1. Plan the macro API (also known as README Driven Developement)
defmodule I18n do
  use Translator

  locale(
    "en",
    flash: [
      hello: "Hello %{first} %{last}!",
      bye: "Bye, %{name}!"
    ],
    users: [
      title: "Users"
    ]
  )

  locale(
    "fr",
    flash: [
      hello: "Salut %{first} %{last}!",
      bye: "Au revoir, %{name}!"
    ],
    users: [
      title: "Utilisateurs"
    ]
  )
end

# iex> I18n.t("en", "flash.hello", first: "Max", last: "Strother")
# > "Hello Max Strother!"
