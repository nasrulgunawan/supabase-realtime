defmodule Realtime.Replication.Replicator do
  @moduledoc false

  require Logger

  alias Realtime.Adapters.Changes.{
    NewRecord,
    UpdatedRecord,
    DeletedRecord
  }

  alias Realtime.{Replication.Repo, Todo}

  def replicate(changes) when is_list(changes) do
    Enum.each(changes, fn change ->
      {:ok, _record} = replicate(change)
    end)
  end

  def replicate(%NewRecord{record: record}) do
    Logger.info("# NEW RECORD #")
    Repo.insert(Todo.changeset(%Todo{}, record))
  end

  def replicate(%UpdatedRecord{record: %{"id" => id} = record}) do
    Logger.info("# UPDATE RECORD #")

    case Repo.get(Todo, id) do
      nil ->
        Repo.insert(Todo.changeset(%Todo{}, record))
      todo ->
        Repo.update(Todo.changeset(todo, record))
    end
  end

  def replicate(%DeletedRecord{old_record: %{"id" => id}} = record) do
    Logger.info("# DELETE RECORD #")

    case Repo.get(Todo, id) do
      nil -> {:ok, nil}
      todo -> Repo.delete(todo)
    end
  end

  def replicate(_record) do
    Logger.info("Action ignored")
  end
end
