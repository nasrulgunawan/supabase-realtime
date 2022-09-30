defmodule Realtime.Todo do
  @moduledoc false

  use Ecto.Schema

  alias Realtime.Replication.Repo

  # @primary_key true
  schema "todos" do
    field :details, :string
    field :user_id, :integer
  end

  def changeset(todo, attrs) do
    todo
    |> Ecto.Changeset.cast(attrs, [:id, :details, :user_id])
  end
end
