defmodule DevChallengeRyanWeb.Schema do
  @moduledoc false
  defmacro __using__(_) do
    quote do
      use Ecto.Schema

      import Ecto
      import Ecto.Changeset
      import Ecto.Query

      alias DevChallengeRyan.Repo

      @primary_key {:id, :binary_id, autogenerate: true}
      @foreign_key_type :binary_id
      # @timestamps_opts [type: :naive_datetime]
      @timestamps_opts [type: :utc_datetime, usec: true]
    end
  end
end
