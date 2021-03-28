defmodule DevChallengeRyan.Contexts.ValidationContext do
  @moduledoc false

  @type changeset() :: map()
  @type params() :: map()

  @spec valid_changeset({boolean(), tuple}) :: tuple()
  def valid_changeset({true, {params, changeset}}), do: {params, changeset}
  def valid_changeset({false, {_map, changeset}}), do: {:error, changeset}

  @spec valid_changeset({boolean(), changeset}) :: any()
  def valid_changeset({true, changeset}), do: changeset.changes
  def valid_changeset({false, changeset}), do: {:error, changeset}
end
