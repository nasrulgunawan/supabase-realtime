defmodule Realtime.Replication.Replicator do
  @moduledoc false

  require Logger

  import Ecto.Query

  alias Realtime.Adapters.Changes.{
    NewRecord,
    UpdatedRecord,
    DeletedRecord
  }

  # TODO: need to handle deleted data?

  alias Realtime.Replication.{MainOrder, Repo, Trade}

  def replicate([change] = changes) when is_list(changes) do
    :ok = replicate(change)
  end

  def replicate(%NewRecord{table: table, record: record}) do
    insert_data(table, record)
    Logger.info("Data #{table} inserted")

    :ok
  end

  def replicate(%UpdatedRecord{
        table: table,
        old_record: _old_record,
        record: record
      }) do
    update_data(table, record)
    Logger.info("Data #{table} updated")

    :ok
  end

  def replicate(_record) do
    Logger.info("Action ignored")
  end

  defp insert_data(table, record) do
    # TODO: on_conflict -> need to update the data?
    Repo.insert_all(table, [Map.to_list(record)], returning: [:id], on_conflict: :nothing)
  end

  defp update_data(table, %{id: id} = record) do
    # TODO: need to check existing data? or use upsert?

    table
    |> where(id: ^id)
    |> update(set: ^Map.to_list(record))
    |> Repo.update_all([])
  end
end 
