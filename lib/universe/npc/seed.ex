defmodule Helix.Universe.NPC.Seed do

  alias Helix.Cache.Action.Cache, as: CacheAction
  alias Helix.Cache.State.PurgeQueue, as: StatePurgeQueue
  alias Helix.Entity.Internal.Entity, as: EntityInternal
  alias Helix.Hardware.Action.Flow.Hardware, as: HardwareFlow
  alias Helix.Hardware.Internal.Motherboard, as: MotherboardInternal
  alias Helix.Hardware.Internal.NetworkConnection, as: NetworkConnectionInternal
  alias Helix.Network.Action.DNS, as: DNSAction
  alias Helix.Network.Internal.DNS, as: DNSInternal
  alias Helix.Server.Internal.Server, as: ServerInternal
  alias Helix.Server.Model.Server
  alias Helix.Server.Repo, as: ServerRepo
  alias Helix.Universe.NPC.Internal.NPC, as: NPCInternal
  alias Helix.Universe.NPC.Model.NPC
  alias Helix.Universe.NPC.Model.NPCType
  alias Helix.Universe.NPC.Model.Seed
  alias Helix.Universe.Repo

  def migrate do
    npcs = Seed.seed()

    Repo.transaction fn ->

      # Ensure the DB has the basic NPC types
      add_npc_types()

      Enum.each(npcs, fn (entry) ->

        # Create NPC
        %{npc_type: entry.type}
        |> NPC.create_changeset()
        |> Ecto.Changeset.cast(%{npc_id: entry.id}, [:npc_id])
        |> Repo.insert(on_conflict: :nothing)

        npc = NPCInternal.fetch(entry.id)

        # Create Entity
        unless EntityInternal.fetch(entry.id) do
          %{entity_id: entry.id, entity_type: :npc}
          |> EntityInternal.create()
        end

        entity = EntityInternal.fetch(entry.id)

        Enum.each(entry.servers, fn(cur) ->
          create_server(cur, entity)
        end)

        create_dns(entry, npc)

        create_specialization(entry, npc)
      end)
    end

    # Ensure nothing is left on cache
    clean_cache(npcs)
  end

  def add_npc_types do
    Enum.each(NPCType.possible_types(), fn type ->
      Repo.insert!(%NPCType{npc_type: type}, on_conflict: :nothing)
    end)
  end

  def create_server(entry_server, entity) do
    unless ServerInternal.fetch(entry_server.id) do

      # Create Server
      server =
        %{server_type: :desktop}
        |> Server.create_changeset()
        |> Ecto.Changeset.cast(%{server_id: entry_server.id}, [:server_id])
        |> ServerRepo.insert!()

      # Create & attach mobo
      {:ok, motherboard_id} = HardwareFlow.setup_bundle(entity)
      {:ok, server} = ServerInternal.attach(server, motherboard_id)

      # Link to Entity
      {:ok, _} = EntityInternal.link_server(entity, server)

      # Change IP if a static one was specified
      if entry_server.static_ip do
        nc =
          motherboard_id
          |> MotherboardInternal.fetch()
          |> MotherboardInternal.get_networks()
          |> Enum.find(&(to_string(&1.network_id) == "::"))

        unless nc.ip == entry_server.static_ip do
          NetworkConnectionInternal.update_ip(nc, entry_server.static_ip)
        end
      end
    end
  end

  def create_dns(entry, npc) do
    if entry.anycast do
      unless DNSInternal.lookup_anycast(entry.anycast) do
        DNSAction.register_anycast(entry.anycast, npc.npc_id)
      end
    end
  end

  # TODO: Remove need for cache clean up by adding the `SKIP_CACHE` flag.
  # Note that, as long as the seed process takes less than the PurgeQueue
  # sync_interval, we don't even have to clean the cache, since teardown
  # would clean the ETS table without giving it time to sync. I'll leave it
  # here nonetheless.
  def clean_cache(npcs) do
    # Sync cache
    StatePurgeQueue.sync()

    # FIXME: This deletes all cache entries from all (seeded) NPCs. Might cause
    # load spikes on production. Filter out to purge only servers who were added
    # during the migration.
    Enum.each(npcs, fn(npc) ->
      Enum.each(npc.servers, fn(server) ->
        CacheAction.purge_server(server.id)
      end)
    end)
  end

  def create_specialization(_entry = %{type: :bank}, _npc) do
    # Bank
  end
  def create_specialization(_entry = %{type: :atm}, _npc) do
    # Atm
  end
  def create_specialization(%{custom: false}, _npc),
    do: :ok
  def create_specialization(_, _),
    do: raise "Invalid seed config"

end
