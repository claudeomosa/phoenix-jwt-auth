defmodule PhoenixAuthWeb.Utils do
  import Ecto.Changeset
  @internal_server_error "Internal Server Error"
  @invalid_credentials "Invalid Credentials"

  def format_changeset_errors(%Ecto.Changeset{} = changeset) do
    errors = traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn ({key, value}, acc) ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)

    formatted_errors = Enum.map(errors, fn {key, value} ->
      formatted_errors = "#{key} #{value}"
      formatted_errors
    end)
    formatted_errors
  end

  def internal_server_error() do
    @internal_server_error
  end

  def invalid_credentials do
    @invalid_credentials
  end
end