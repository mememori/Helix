defmodule Helix.Software.Action.Flow.FileTest do

  use Helix.Test.IntegrationCase

  alias Helix.Account.Action.Flow.Account, as: AccountFlow
  alias Helix.Entity.Query.Entity, as: EntityQuery
  alias Helix.Hardware.Query.Component, as: ComponentQuery
  alias Helix.Hardware.Query.Motherboard, as: MotherboardQuery
  alias Helix.Log.Action.Log, as: LogAction
  alias Helix.Log.Model.Log
  alias Helix.Software.Action.Flow.File, as: FileFlow
  alias Helix.Software.Internal.File, as: FileInternal
  alias Helix.Software.Model.SoftwareType.LogForge
  alias Helix.Software.Query.Storage, as: StorageQuery

  alias Helix.Account.Factory, as: AccountFactory
  alias Helix.Cache.Helper, as: CacheHelper
  alias Helix.Software.Factory

  @moduletag :integration

  describe "log_forger" do
    test "fails if target log doesn't exist" do
      account = AccountFactory.insert(:account)

      {:ok, %{server: server}} = AccountFlow.setup_account(account)

      :timer.sleep(100)
      CacheHelper.sync_test()

      storage =
        server.motherboard_id
        |> ComponentQuery.fetch()
        |> MotherboardQuery.fetch()
        |> MotherboardQuery.get_slots()
        |> Enum.filter(&(&1.link_component_type == :hdd))
        |> Enum.reject(&(is_nil(&1.link_component_id)))
        |> Enum.map(&(&1.link_component_id))
        |> List.first()
        |> StorageQuery.fetch_by_hdd()

      file = Factory.insert(:file, software_type: :log_forger, storage: storage)
      params = %{
        target_log_id: Log.ID.generate(),
        message: "I say hey hey",
        entity_id: EntityQuery.get_entity_id(account)
      }

      result = FileFlow.execute_file(file, server, params)
      assert {:error, {:log, :notfound}} == result
    end

    test "starts log_forger process on success" do
      account = AccountFactory.insert(:account)

      {:ok, %{server: server}} = AccountFlow.setup_account(account)

      :timer.sleep(250)
      CacheHelper.sync_test()

      storage =
        server.motherboard_id
        |> ComponentQuery.fetch()
        |> MotherboardQuery.fetch()
        |> MotherboardQuery.get_slots()
        |> Enum.filter(&(&1.link_component_type == :hdd))
        |> Enum.reject(&(is_nil(&1.link_component_id)))
        |> Enum.map(&(&1.link_component_id))
        |> List.first()
        |> StorageQuery.fetch_by_hdd()

      entity_id = EntityQuery.get_entity_id(account)

      {:ok, log} = LogAction.create(server, entity_id, "Root logged in")
      file = Factory.insert(:file, software_type: :log_forger, storage: storage)
      modules = %{log_forger_create: 100, log_forger_edit: 100}
      # FIXME: this function should exist on the FileAction
      FileInternal.set_modules(file, modules)

      params = %{
        target_log_id: log.log_id,
        message: "",
        entity_id: entity_id
      }

      result = FileFlow.execute_file(file, server, params)
      assert {:ok, process} = result
      assert %LogForge{} = process.process_data
      assert "log_forger" == process.process_type

      # FIXME
      server
      |> Helix.Process.State.TOP.Manager.get()
      |> Helix.Process.State.TOP.Server.force_stop()

      CacheHelper.sync_test()
    end
  end
end