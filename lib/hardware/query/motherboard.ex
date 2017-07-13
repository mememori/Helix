defmodule Helix.Hardware.Query.Motherboard do

  alias Helix.Hardware.Internal.Motherboard, as: MotherboardInternal
  alias Helix.Hardware.Model.Component
  alias Helix.Hardware.Model.Motherboard
  alias Helix.Hardware.Model.MotherboardSlot
  alias Helix.Hardware.Model.NetworkConnection
  alias Helix.Hardware.Repo
  alias Helix.Server.Model.Server
  alias Helix.Server.Query.Server, as: ServerQuery
  alias Helix.Hardware.Query.Component, as: ComponentQuery
  alias Helix.Hardware.Model.Component.NIC
  alias Helix.Software.Query.Storage, as: StorageQuery


  @spec fetch!(Component.t) :: Motherboard.t
  @doc """
  Fetches a motherboard by component
  """
  def fetch!(component) do
    MotherboardInternal.fetch!(component)
  end

  @spec get_slots(Motherboard.t | HELL.PK.t) :: [MotherboardSlot.t]
  @doc """
  Gets every slot from a motherboard
  """
  def get_slots(motherboard) do
    MotherboardInternal.get_slots(motherboard)
  end

  @spec preload_components(Motherboard.t) :: Motherboard.t
  def preload_components(motherboard) do
    Repo.preload(motherboard, slots: :component)
  end

  @spec resources(Motherboard.t) :: %{cpu: non_neg_integer, ram: non_neg_integer, net: %{any => %{uplink: non_neg_integer, downlink: non_neg_integer}}}
  def resources(motherboard) do
    MotherboardInternal.resources(motherboard)
  end

  @spec fetch_by_server(HELL.PK.t) :: Motherboard.t | nil
  def fetch_by_server(server_id) do
    with \
      server = %Server{} <- ServerQuery.fetch(server_id),
      true <- not is_nil(server.motherboard_id),
      component = %{} <- ComponentQuery.fetch(server.motherboard_id),
      motherboard = %{} <- fetch!(component)
    do
      motherboard
    else
      :nil
    end
  end

  def get_networks(motherboard) do
    with \
      slots = [_|_] <- get_slots(motherboard),
      nics = [_|_] <- Enum.filter(slots, &(&1.link_component_type == :nic)),
      nics = [_|_] <- Enum.reject(nics, &is_nil(&1.link_component_id)),
      nics = [_|_] <- Enum.map(nics, &Repo.get(NIC, &1.link_component_id)),
      nets = [_|_] <- Enum.map(
               nics,
               &Repo.get(NetworkConnection, &1.network_connection_id))
    do
      nets
    end

  end

  def get_components(motherboard) do
    motherboard
    |> preload_components()
    |> MotherboardInternal.get_components_ids()
  end

  def get_hdds(motherboard) do
    motherboard
    |> MotherboardInternal.get_hdds()
  end

  def storages_on_motherboard(motherboard) do
    # FIXME: Works only for one hd
    hdd = motherboard
    |> get_hdds()
    |> List.first()
    |> Map.get(:hdd_id)
    |> StorageQuery.get_storage_from_hdd()
  end
end
