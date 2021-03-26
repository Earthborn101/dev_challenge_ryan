defmodule DevChallengeRyanWeb.Contexts.ValidationContext do
    @moduledoc false
  
    def valid_changeset({true, changeset}), do: changeset.changes
    def valid_changeset({false, changeset}), do: {:error, changeset}
end  