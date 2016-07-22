defmodule Wallaby.QueryError do
  defexception [:message]

  alias Wallaby.Node.Query

  @spec exception(Query.t) :: Exception.t
  def exception(query) do
    %__MODULE__{message: errors(query)}
  end

  @spec errors(Query.t) :: String.t
  def errors(query) do
    query.errors
    |> hd
    |> error_message(query)
  end

  def error_message(:not_found, %Query{locator: locator, conditions: opts}) do
    msg = "Could not find any #{visibility(opts)} #{method(locator)} that matched: '#{expression(locator)}'"
    [msg] ++ conditions(opts)
    |> Enum.join(" and ")
  end
  def error_message(:found, %Query{locator: locator}) do
    """
    The element with #{method locator}: '#{expression locator}' should not have been found but was
    found.
    """
  end
  def error_message(:visible, %Query{locator: locator}) do
    """
    The #{method(locator)} that matched: '#{expression(locator)}' should not have been visible but was.

    If you expect the element to be visible to the user then you should
    remove the `visible: false` option from your finder.
    """
  end
  def error_message(:ambiguous, %Query{locator: locator, result: elements, conditions: opts}) do
    count = Keyword.get(opts, :count)

    """
    The #{method(locator)} that matched: '#{expression(locator)}' was found but
    the results are ambiguous. It was found #{times(length(elements))} but it
    should have been found #{times(count)}.

    If you expect to find the selector #{times(length(elements))} then you
    should include the `count: #{length(elements)}` option in your finder.
    """
  end
  def error_message(:not_visible, %Query{locator: locator}) do
    """
    The #{method locator}: '#{expression locator}' was found but its not visible to a
    real user.

    If you expect the element to be invisible to the user then you should
    include the `visible: false` option in your finder.
    """
  end
  def error_message(:label_with_no_for, %Query{locator: locator}) do
    """
    The text '#{expression locator}' matched a label but the label has no 'for'
    attribute and can't be used to find the correct #{method(locator)}.

    You can fix this by including the `for="YOUR_INPUT_ID"` attribute on the
    appropriate label.
    """
  end

  def error_message({:label_does_not_find_field, for_text}, %Query{locator: locator}) do
    """
    The text '#{expression locator}' matched a label but the label's 'for' attribute
    doesn't match the id of any #{method(locator)}.

    Make sure that id on your #{method(locator)} is `id="#{for_text}"`.
    """
  end

  def error_message(:button_with_no_type, %Query{locator: locator}) do
    """
    The text '#{expression locator}' matched a button but the button has no 'type' attribute.

    You can fix this by including `type="[submit|reset|button|image]"` on the appropriate button.
    """
  end

  defp conditions(opts) do
    opts
    |> Keyword.delete(:visible)
    |> Keyword.delete(:count)
    |> Enum.map(&condition/1)
    |> Enum.reject(& &1 == nil)
  end

  defp condition({:text, text}) when is_binary(text) do
    "text: '#{text}'"
  end
  defp condition(_), do: nil

  defp visibility(opts) do
    if Keyword.get(opts, :visible) do
      "visible"
    else
      "invisible"
    end
  end

  defp times(1), do: "1 time"
  defp times(count), do: "#{count} times"

  def method({:css, _}), do: "element with css"
  def method({:select, _}), do: "select"
  def method({:fillable_field, _}), do: "text input or textarea"
  def method({:checkbox, _}), do: "checkbox"
  def method({:radio_button, _}), do: "radio button"
  def method({:link, _}), do: "link"
  def method({:xpath, _}), do: "element with an xpath"
  def method({:button, _}), do: "button"
  def method(_), do: "element"

  def expression({_, expr}), do: expr
end

defmodule Wallaby.ExpectationNotMet do
  defexception [:message]
end

defmodule Wallaby.BadMetadata do
  defexception [:message]
end

defmodule Wallaby.NoBaseUrl do
  defexception [:message]

  def exception(relative_path) do
    msg = """
    You called visit with #{relative_path}, but did not set a base_url.
    Set this in config/test.exs or in test/test_helper.exs:

      Application.put_env(:wallaby, :base_url, "http://localhost:4001")

    If using Phoenix, you can use the url from your endpoint:

      Application.put_env(:wallaby, :base_url, YourApplication.Endpoint.url)
    """

    %__MODULE__{message: msg}
  end
end
