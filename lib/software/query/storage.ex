defmodule Helix.Software.Query.Storage do

  alias Helix.Software.Internal.Storage, as: StorageInternal
  alias Helix.Software.Model.Storage

  @spec fetch(HELL.PK.t) :: Storage.t | nil
  def fetch(storage_id),
    do: StorageInternal.fetch(storage_id)

  @spec fetch_by_hdd(HELL.PK.t) :: Storage.t | nil
  def fetch_by_hdd(hdd_id),
    do: StorageInternal.fetch_by_hdd(hdd_id)

  def get_drives(storage_id) do
    StorageInternal.get_drives(storage_id)
    |> List.first()
    |> Map.get(:drive_id)
  end

end
