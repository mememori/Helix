defmodule Helix.Software.Internal.Storage do

  import Ecto.Query, only: [join: 5, where: 3]

  alias Helix.Cache.Action.Cache, as: CacheAction
  alias Helix.Hardware.Model.Component
  alias Helix.Software.Model.Storage
  alias Helix.Software.Model.StorageDrive
  alias Helix.Software.Repo

  @spec fetch(Storage.id) ::
    Storage.t
    | nil
  def fetch(storage_id),
    do: Repo.get(Storage, storage_id)

  @spec fetch_by_hdd(Component.id) ::
    Storage.t
    | nil
  def fetch_by_hdd(hdd_id) do
    Storage
    |> join(:inner, [s], sd in StorageDrive, s.storage_id == sd.storage_id)
    |> where([s, sd], sd.drive_id == ^hdd_id)
    |> Repo.one()
  end

  @spec get_drives(Storage.t | Storage.id) ::
    [StorageDrive.t]
  def get_drives(storage = %Storage{}) do
    storage
    |> Repo.preload(:drives)
    |> Map.get(:drives)
  end
  def get_drives(storage_id) do
    storage_id
    |> fetch()
    |> get_drives()
  end

  @spec create() ::
    {:ok, Storage.t}
    | {:error, Ecto.Changeset.t}
  def create do
    Storage.create_changeset()
    |> Repo.insert()
  end

  @spec delete(Storage.t) ::
    :ok
  def delete(storage) do
    Repo.delete(storage)

    CacheAction.purge_storage(storage)
    CacheAction.update_server_by_storage(storage)

    :ok
  end
end
