defmodule DevChallengeRyanWeb.Contexts.UtilityContext do
    @moduledoc false
  
    def is_valid_changeset(changeset), do: {changeset.valid?, changeset}

    def get_url_or_value(key) do
        :dev_challenge_ryan
        |> Application.get_env(DevChallengeRyanWeb.UtilityContext)
        |> Keyword.get(key)
    end
end
