defmodule Helix.Software.Internal.Storage do

  alias Helix.Software.Model.Storage
  alias Helix.Software.Model.StorageDrive
  alias Helix.Software.Repo

  import Ecto.Query, only: [join: 5, where: 3]

  @spec create() :: {:ok, Storage.t} | {:error, Ecto.Changeset.t}
  def create do
    Storage.create_changeset()
    |> Repo.insert()
  end

  @spec fetch(HELL.PK.t) :: Storage.t | nil
  def fetch(storage_id),
    do: Repo.get(Storage, storage_id)

  @spec delete(HELL.PK.t) :: no_return
  def delete(storage_id) do
    Storage
    |> where([s], s.storage_id == ^storage_id)
    |> Repo.delete_all()

    :ok
  end

  # FIXME: This doesn't belongs here, does it ?
  @spec fetch_by_hdd(HELL.PK.t) :: Storage.t | nil
  def fetch_by_hdd(hdd_id) do
    Storage
    |> join(:inner, [s], sd in StorageDrive, s.storage_id == sd.storage_id)
    |> where([s, sd], sd.drive_id == ^hdd_id)
    |> Repo.one()
  end

  def get_drives(storage_id) do
    storage_id
    |> fetch()
    |> Repo.preload(:drives)
    |> Map.get(:drives)
  end
end
