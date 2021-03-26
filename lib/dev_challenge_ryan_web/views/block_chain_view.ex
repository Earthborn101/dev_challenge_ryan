defmodule DevChallengeRyanWeb.BlockChainView do
  use DevChallengeRyanWeb, :view

  def render("success.json", %{result: result}), do: result
  def render("error.json", %{errors: errors}), do: errors
end
