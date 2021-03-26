defmodule DevChallengeRyanWeb.Contexts.UtilityContext do
  @moduledoc false

  def is_valid_changeset(changeset), do: {changeset.valid?, changeset}
  def is_valid_changeset_map(changeset), do: {changeset.valid?, {changeset.changes, changeset}}

  def get_url_or_value(key) do
    :dev_challenge_ryan
    |> Application.get_env(DevChallengeRyanWeb.UtilityContext)
    |> Keyword.get(key)
  end

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
