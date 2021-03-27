defmodule DevChallengeRyan.Contexts.UtilityContext do
  @moduledoc false
  @type changeset() :: map()
  @type key() :: atom()

  @spec is_valid_changeset(changeset) :: tuple
  def is_valid_changeset(changeset), do: {changeset.valid?, changeset}
  def is_valid_changeset_map(changeset), do: {changeset.valid?, {changeset.changes, changeset}}

  @spec get_url_or_value(key) :: String.t()
  def get_url_or_value(key) do
    :dev_challenge_ryan
    |> Application.get_env(DevChallengeRyanWeb.UtilityContext)
    |> Keyword.get(key)
  end

  @spec transform_error_message(changeset) :: map()
  def transform_error_message(changeset) do
    errors =
      Enum.map(changeset.errors, fn {key, {message, _}} ->
        %{
          key => message
        }
      end)

    Enum.reduce(errors, fn head, tail ->
      Map.merge(head, tail)
    end)
  end
end
