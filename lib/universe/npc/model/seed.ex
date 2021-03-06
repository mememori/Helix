defmodule Helix.Universe.NPC.Model.Seed do

  def search_by_type(type) do
    key = case type do
      :download_center ->
        "DC0"
      _ ->
        # TODO
        raise ArgumentError
    end

    generate_entry(key, type)
  end

  def seed do
    # TODO: Cache and verify for changes based on hash or something like that.
    generate_seed()
  end

  @source [
    %{key: "DC0", type: :download_center},
    %{key: "Bank1", type: :bank}
  ]

  @dns %{
    "DC0" => "dc.com",
    "Bank1" => "bank.com"
  }

  @servers %{
    "DC0" => [%{spec: "todo", ip: "1.2.3.4"}],
    "Bank1" => [%{spec: "todo"}]
  }

  @ids %{
    "DC0" => %{
      npc: "2::920e:c06c:abea:b249:a158",
      servers: ["10::15c1:d147:47f9:b4b2:cbbd"]
    },
    "Bank1" => %{
      npc: "2::920e:c06c:abea:b249:a159",
      servers: ["10::15c1:d147:47f9:b4b2:cbbe"]
    }
  }

  @custom %{
    "Bank1" => %{name: "Bank One"}
  }

  defp generate_seed do
    Enum.map(@source, fn(npc) ->
      generate_entry(npc.key, npc.type)
    end)
  end

  defp generate_entry(key, type) do
    ids = Map.get(@ids, key)
    servers = Map.get(@servers, key)

    Kernel.length(servers) == Kernel.length(ids.servers) || stop()

    zip = Enum.zip(servers, ids.servers)
    server_entries = Enum.map(zip, fn(server) ->
      server_entry(server)
    end)

    %{
      id: ids.npc,
      type: type,
      servers: server_entries,
      anycast: Map.get(@dns, key, false),
      custom: Map.get(@custom, key, false)
    }
  end

  defp server_entry({server, id}) do
    %{id: id, spec: server.spec, static_ip: Map.get(server, :ip, false)}
  end

  defp stop,
    do: raise "Your seed config is invalid"
end
