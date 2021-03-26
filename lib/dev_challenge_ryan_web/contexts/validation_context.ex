defmodule DevChallengeRyanWeb.Contexts.ValidationContext do
  @moduledoc false

  def valid_changeset({true, {map, changeset}}), do: {map, changeset}
  def valid_changeset({false, {_map, changeset}}), do: {:error, changeset}
  def valid_changeset({true, changeset}), do: changeset.changes
  def valid_changeset({false, changeset}), do: {:error, changeset}
end
