defmodule Helix.Cache.Action.Cache do
  @moduledoc """
  Welcome to the Cache invalidation API. Here's a few things you should know:

  - I, the Cache, am responsible for transparent synchronization and invalidation
  of cached data.
  - YOU, the programmer, is responsible for telling me about changes on the data.
  - Caching is hard. Don't blame me.
  - Never use Internal modules directly.

  You can request me to either **update** or **purge** (delete) data, but I'll get
  quite mad if you ask me to do an action I'm not supposed to. Basically:

  - Purge data when its underlying object has been effectively deleted.
  - For all other cases, you probably want to update the data.

  Here's why:

  When you tell me an object has been updated, I'll grab everything we know about
  it and create related entries. For instance, if you tell me an IP address has
  changed, I'll take care of ensuring that any related entries have been updated.

  But suppose you just deleted a component (maybe the player sold it). If you tell
  me that that component has been updated, I won't be able to fetch any information
  from it (because it no longer exists). Furthermore, updates will always lead to
  new data being added to cache, and I definitely shouldn't add something that just
  got deleted.

  In this case, you should notify me that:
  - the component has been deleted, so I can purge it from my database.
  - relevant entries, for instance the server, were updated. (don't worry,
  usually one purge affects only one object).

  Follow these rules and no one will get hurt.
  """

  import HELL.MacroHelpers

  alias HELL.IPv4
  alias Helix.Hardware.Model.Component
  alias Helix.Hardware.Model.Motherboard
  alias Helix.Network.Model.Network
  alias Helix.Server.Model.Server
  alias Helix.Server.Query.Server, as: ServerQuery
  alias Helix.Software.Model.Storage
  alias Helix.Cache.Internal.Cache, as: CacheInternal
  alias Helix.Cache.Query.Cache, as: CacheQuery

  @spec purge_server(Server.idtb) ::
    :ok
  @doc """
  Purges the server entry from the cache.

  If there is a motherboard attached to it, it will purge all related
  objects as well (components, storages and networks).

  If it does not exist on the cache, it won't purge anything. No matter the
  change, the cache is consistent.
  """
  def purge_server(server_id) do
    server_id = server_to_id(server_id)
    server = direct_cache_query(:server, server_id)

    unless is_nil(server) do
      unless is_nil(server.motherboard_id) do
        Enum.each(server.components, &CacheInternal.purge(:component, &1))
        Enum.each(server.storages, &CacheInternal.purge(:storage, &1))
        CacheInternal.purge(:component, server.motherboard_id)
        Enum.each(
          server.networks,
          &CacheInternal.purge(:network, {&1["network_id"], &1["ip"]})
        )
      end
      CacheInternal.purge(:server, server_id)
    end
  end

  @spec update_server(Server.idtb) ::
    :ok
  @doc """
  Updates a server entry.

  If the server has a motherboard attached to it, it will update all related
  components as well (components, storages and networks).

  If it does not exist on the cache, it won't update anything. No matter the
  change, the cache is consistent.
  """
  def update_server(server_id) do
    server_id = server_to_id(server_id)
    params = direct_cache_query(:server, server_id)
    update_server(server_id, params)
  end

  @spec update_server(Server.idtb, term) ::
    :ok
  defp update_server(server_id, params) do
    unless is_nil(params) do
      unless is_nil(params.motherboard_id) do
        Enum.each(params.components, &CacheInternal.update(:component, &1))
        Enum.each(params.storages, &CacheInternal.update(:storage, &1))
        CacheInternal.update(:component, params.motherboard_id)
        Enum.each(
          params.networks,
          &CacheInternal.update(:network, {&1["network_id"], &1["ip"]})
        )
      end
      CacheInternal.update(:server, server_id)
    end
  end

  @spec update_server_by_motherboard(Motherboard.idtb) ::
    :ok
  @doc """
  Given a motherboard, update its corresponding server.

  If the motherboard is not found, it won't update anything, since the server
  entry doesn't exists anyway.
  """
  def update_server_by_motherboard(motherboard_id) do
    motherboard_id = motherboard_to_id(motherboard_id)
    server = direct_cache_query(:motherboard, motherboard_id)

    # If data is not on the cache, there's no need to update it
    if server do
      update_server(server.server_id, server)
    end
  end

  @spec update_server_by_storage(Storage.idtb) ::
    :ok
  @doc """
  Given a storage, update its corresponding server.

  If the storage is not found, it won't update anything. Notice that,
  technically, it's possible a server entry exists but the storage entry
  doesn't. It's up to the caller to make sure this distinction. If that's
  the case, `update_storage/1` may be a better fit.
  """
  def update_server_by_storage(storage_id) do
    storage_id = storage_to_id(storage_id)
    server_id = direct_cache_query(:storage, storage_id)

    if server_id do
      update_server(server_id)
    end
  end

  @spec update_storage(Storage.idtb) ::
    :ok
  @doc """
  Updates a storage entry from the cache.

  It will also update the underlying server, even if it doesn't exists.
  """
  def update_storage(storage_id) do
    storage_id = storage_to_id(storage_id)
    {:ok, server_id} = CacheQuery.from_storage_get_server(storage_id)
    update_server(server_id)
    CacheInternal.update(:storage, storage_id)
  end

  @spec purge_storage(Storage.idtb) ::
    :ok
  @doc """
  Purges a storage entry.

  It does not purge/update the server.
  """
  def purge_storage(storage_id),
    do: CacheInternal.purge(:storage, storage_to_id(storage_id))

  @spec update_component(Motherboard.idtb) ::
    :ok
  @doc """
  Updates a component entry on the cache.

  If the corresponding server is found *on the cache*, it is also updated.
  """
  def update_component(%Motherboard{motherboard_id: id}),
    do: update_component(id)
  def update_component(component_id) do
    component_id = component_to_id(component_id)
    server = direct_cache_query(:component, component_id)

    if server do
      update_server(server.server_id)
    end
    CacheInternal.update(:component, component_id)
  end

  @spec purge_component(Motherboard.idtb) ::
    :ok
  @doc """
  Purges a component entry from the cache.

  It does not purge/update the server.
  """
  def purge_component(%Motherboard{motherboard_id: id}),
    do: purge_component(id)
  def purge_component(component_id),
    do: CacheInternal.purge(:component, component_to_id(component_id))

  @spec update_network(Network.idtb, IPv4.t) ::
    :ok
  @doc """
  Updates the nip entry on the cache.

  It will also update the underlying server, even if it doesn't exists.
  """
  def update_network(network_id, ip) do
    network_id = network_to_id(network_id)
    {:ok, server_id} = CacheQuery.from_nip_get_server(network_id, ip)
    update_server(server_id)
    CacheInternal.update(:network, {network_id, ip})
  end

  @spec purge_network(Network.idtb, IPv4.t) ::
    :ok
  @doc """
  Purges the nip entry from the cache.

  It does not purge/update the server.
  """
  def purge_network(network_id, ip),
    do: CacheInternal.purge(:network, {network_to_id(network_id), ip})

  @spec update_web(Network.idtb, IPv4.t) ::
    :ok
  def update_web(network, ip),
    do: CacheInternal.update(:web, {network_to_id(network), ip})

  @spec purge_web(Network.idtb, IPv4.t) ::
    :ok
  def purge_web(network, ip),
    do: CacheInternal.purge(:web, {network_to_id(network), ip})

  @spec direct_cache_query(:server | :motherboard | :component | :storage, HELL.PK.t) ::
    server_id :: HELL.PK.t
    | nil
  docp """
  This is a helper function with the goal of aiding this module to fetch cached
  data that is related to whatever is being purged/updated.

  The reasons for this method's painful existence are:

  1) In some cases, we only want to purge/update data if it's already cached,
  and calling CacheQuery.$function causes side-effects, populating the entry
  if a miss occurs.

  2) Sometimes the underlying data changes (most common on purges). This means
  that fetching the origin will fail because that object is no longer valid.
  However, it may still be saved on the cache, and directly querying it will
  give us related data. We know the object isn't valid, but the related data is.
  """
  defp direct_cache_query(:server, id) do
    case CacheInternal.direct_query(:server, id) do
      {:hit, server} ->
        server
      _ ->
        nil
    end
  end
  defp direct_cache_query(:motherboard, id) do
    case CacheInternal.direct_query(:motherboard, id) do
      {:hit, server} ->
        server
      _ ->
        nil
    end
  end
  defp direct_cache_query(:component, id) do
    with \
      {:hit, mobo} <- CacheInternal.direct_query(:component, id),
      server = %{} <- ServerQuery.fetch_by_motherboard(mobo.motherboard_id)
    do
      server
    else
      _ ->
        nil
    end
  end
  defp direct_cache_query(:storage, id) do
    case CacheInternal.direct_query(:storage, id) do
      {:hit, storage} ->
        storage.server_id
      _ ->
        nil
    end
  end

  @spec storage_to_id(Storage.idtb) ::
    HELL.PK.t
  def storage_to_id(%Storage{storage_id: id}),
    do: storage_to_id(id)
  def storage_to_id(id = %Storage.ID{}),
    do: to_string(id)
  def storage_to_id(id) when is_binary(id),
    do: id

  @spec network_to_id(Network.idtb) ::
    HELL.PK.t
  def network_to_id(%Network{network_id: id}),
    do: network_to_id(id)
  def network_to_id(id = %Network.ID{}),
    do: to_string(id)
  def network_to_id(id) when is_binary(id),
    do: id

  @spec motherboard_to_id(Motherboard.idtb) ::
    HELL.PK.t
  defp motherboard_to_id(%Motherboard{motherboard_id: id}),
    do: component_to_id(id)
  defp motherboard_to_id(%Component{component_id: id, component_type: :mobo}),
    do: to_string(id)
  defp motherboard_to_id(id = %Component.ID{}),
    do: to_string(id)
  defp motherboard_to_id(id) when is_binary(id),
    do: id

  @spec component_to_id(Component.idtb) ::
    HELL.PK.t
  defp component_to_id(%Component{component_id: id}),
    do: component_to_id(id)
  defp component_to_id(id = %Component.ID{}),
    do: to_string(id)
  defp component_to_id(id) when is_binary(id),
    do: id

  @spec server_to_id(Server.idtb) ::
    HELL.PK.t
  defp server_to_id(%Server{server_id: id}),
    do: server_to_id(id)
  defp server_to_id(id = %Server.ID{}),
    do: to_string(id)
  defp server_to_id(id) when is_binary(id),
    do: id
end
