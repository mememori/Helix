defmodule Helix.Log.Event.LogTest do

  use Helix.Test.IntegrationCase

  alias Helix.Software.Model.SoftwareType.LogForge.Edit.ConclusionEvent,
    as: LogForgeEditComplete
  alias Helix.Software.Model.SoftwareType.LogForge.Create.ConclusionEvent,
    as: LogForgeCreateComplete
  alias Helix.Log.Event.Log, as: EventHandler
  alias Helix.Log.Query.Log, as: LogQuery
  alias Helix.Log.Repo

  alias Helix.Entity.Factory, as: EntityFactory
  alias Helix.Server.Factory, as: ServerFactory
  alias Helix.Test.Factory.Log, as: LogFactory

  # TODO: Depends on integration factory as it depends on a server being linked
  #   to an entity and having a network_connection (and this depends on a nic
  #   that depends on the motherboard and everything is just terrible)
  describe "when file is downloaded" do
    @tag :pending
    test "creates log"
  end

  describe "on log forger edit conclusion" do
    test "adds revision to target log" do
      target_log = LogFactory.insert(:log)
      entity = EntityFactory.insert(:entity)
      message = "I just got hidden"

      event = %LogForgeEditComplete{
        target_log_id: target_log.log_id,
        entity_id: entity.entity_id,
        message: message,
        version: 100
      }

      revisions_before = LogQuery.count_revisions_of_entity(target_log, entity)
      EventHandler.log_forge_conclusion(event)
      revisions_after = LogQuery.count_revisions_of_entity(target_log, entity)
      target_log = LogQuery.fetch(target_log.log_id)

      assert revisions_after == revisions_before + 1
      assert message == target_log.message
    end
  end

  describe "on log forger create conclusion" do
    test "creates specified log on target server" do
      entity = EntityFactory.insert(:entity)
      server = ServerFactory.insert(:server)
      message = "Mess with the best, die like the rest"

      event = %LogForgeCreateComplete{
        entity_id: entity.entity_id,
        target_server_id: server.server_id,
        message: message,
        version: 456
      }

      EventHandler.log_forge_conclusion(event)

      assert [log] = LogQuery.get_logs_on_server(server)
      assert [%{forge_version: 456}] = Repo.preload(log, :revisions).revisions
    end
  end

  describe "when ssh connection is started" do
    @tag :pending
    test "logs on gateway"

    @tag :pending
    test "logs on destination"
  end
end
