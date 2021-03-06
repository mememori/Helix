defmodule Helix.Log.Query.LogTest do

  use Helix.Test.IntegrationCase

  alias Helix.Entity.Model.Entity
  alias Helix.Server.Model.Server
  alias Helix.Log.Action.Log, as: LogAction
  alias Helix.Log.Query.Log, as: LogQuery

  alias Helix.Test.Factory.Log, as: Factory

  describe "get_logs_on_server/1" do
    # Well, i think that the function name might be a bit obvious, eh ?
    test "returns logs that belongs to a server" do
      # Random logs on other servers
      Enum.each(1..5, fn _ -> Factory.insert(:log) end)

      server = Server.ID.generate()
      expected =
        Enum.map(1..5, fn _ ->
          Factory.insert(:log, server_id: server)
        end)
        |> Enum.map(&(&1.log_id))
        |> MapSet.new()

      fetched =
        server
        |> LogQuery.get_logs_on_server()
        |> Enum.map(&(&1.log_id))
        |> MapSet.new()

      assert MapSet.equal?(expected, fetched)
    end
  end

  describe "get_logs_from_entity_on_server/2" do
    test "returns logs that were created by the entity" do
      server = Server.ID.generate()
      entity = Entity.ID.generate()

      create_log = fn params ->
        defaults = %{
          server_id: Server.ID.generate(),
          entity_id: Entity.ID.generate(),
          message: "Default message"
        }
        p = Map.merge(defaults, params)

        {:ok, log, _} = LogAction.create(p.server_id, p.entity_id, p.message)
        log
      end

      # Random logs that were not created by the entity
      Enum.each(1..5, fn _ -> create_log.(%{server_id: server}) end)

      entity_params = %{server_id: server, entity_id: entity}
      expected =
        1..5
        |> Enum.map(fn _ -> create_log.(entity_params) end)
        |> Enum.map(&(&1.log_id))
        |> MapSet.new()

      fetched =
        server
        |> LogQuery.get_logs_from_entity_on_server(entity)
        |> Enum.map(&(&1.log_id))
        |> MapSet.new()

      assert MapSet.equal?(expected, fetched)
    end

    test "returns logs that were touched by entity" do
      server = Server.ID.generate()
      entity = Entity.ID.generate()

      # Random logs that were not touched by the entity
      Enum.each(1..5, fn _ ->
        Factory.insert(:log, server_id: server)
      end)

      expected =
        Enum.map(1..5, fn _ ->
          Factory.insert(:log, server_id: server)
        end)
        |> Enum.map(fn log ->
          LogAction.revise(log, entity, "touched", 1)
          log
        end)
        |> Enum.map(&(&1.log_id))
        |> MapSet.new()

      fetched =
        server
        |> LogQuery.get_logs_from_entity_on_server(entity)
        |> Enum.map(&(&1.log_id))
        |> MapSet.new()

      assert MapSet.equal?(expected, fetched)
    end
  end
end
