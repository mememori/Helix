defmodule Helix.Software.Action.Flow.FileTest do

  use Helix.Test.IntegrationCase

  alias HELL.IPv4
  alias Helix.Account.Action.Flow.Account, as: AccountFlow
  alias Helix.Cache.Query.Cache, as: CacheQuery
  alias Helix.Entity.Model.Entity
  alias Helix.Entity.Query.Entity, as: EntityQuery
  alias Helix.Log.Action.Log, as: LogAction
  alias Helix.Log.Model.Log
  alias Helix.Network.Model.Network
  alias Helix.Server.Model.Server
  alias Helix.Software.Action.Flow.File, as: FileFlow
  alias Helix.Software.Internal.File, as: FileInternal
  alias Helix.Software.Model.SoftwareType.Cracker
  alias Helix.Software.Model.SoftwareType.Firewall.Passive, as: FirewallPassive
  alias Helix.Software.Model.SoftwareType.LogForge
  alias Helix.Software.Query.Storage, as: StorageQuery

  alias Helix.Account.Factory, as: AccountFactory
  alias Helix.Cache.Helper, as: CacheHelper
  alias Helix.Test.Process.TOPHelper
  alias Helix.Software.Factory

  describe "firewall" do
    test "starts firewall process on success" do
      account = AccountFactory.insert(:account)

      {:ok, %{server: server}} = AccountFlow.setup_account(account)

      :timer.sleep(250)
      CacheHelper.sync_test()

      {:ok, storages} = CacheQuery.from_server_get_storages(server)
      storage = storages |> Enum.random() |> StorageQuery.fetch()

      file = Factory.insert(:file, software_type: :firewall, storage: storage)
      modules = %{firewall_passive: 100}
      # FIXME: this function should exist on the FileAction
      FileInternal.set_modules(file, modules)

      result = FileFlow.execute_file(file, server, %{})
      assert {:ok, process} = result
      assert %FirewallPassive{} = process.process_data
      assert "firewall_passive" == process.process_type

      TOPHelper.top_stop(server)
    end
  end

  describe "log_forger 'edit' operation" do
    test "fails if target log doesn't exist" do
      account = AccountFactory.insert(:account)

      {:ok, %{server: server}} = AccountFlow.setup_account(account)

      :timer.sleep(100)
      CacheHelper.sync_test()

      {:ok, storages} = CacheQuery.from_server_get_storages(server)
      storage = storages |> Enum.random() |> StorageQuery.fetch()

      file = Factory.insert(:file, software_type: :log_forger, storage: storage)
      params = %{
        target_log_id: Log.ID.generate(),
        message: "I say hey hey",
        operation: "edit",
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

      {:ok, storages} = CacheQuery.from_server_get_storages(server)
      storage = storages |> Enum.random() |> StorageQuery.fetch()

      entity_id = EntityQuery.get_entity_id(account)

      {:ok, log, _} = LogAction.create(server, entity_id, "Root logged in")
      file = Factory.insert(:file, software_type: :log_forger, storage: storage)
      modules = %{log_forger_create: 100, log_forger_edit: 100}
      # FIXME: this function should exist on the FileAction
      FileInternal.set_modules(file, modules)

      params = %{
        target_log_id: log.log_id,
        message: "",
        operation: "edit",
        entity_id: entity_id
      }

      result = FileFlow.execute_file(file, server, params)
      assert {:ok, process} = result
      assert %LogForge{} = process.process_data
      assert "log_forger" == process.process_type

      TOPHelper.top_stop(server)
    end
  end

  describe "log_forger 'create' operation" do
    test "starts log_forger process on success" do
      account = AccountFactory.insert(:account)

      {:ok, %{server: server}} = AccountFlow.setup_account(account)

      :timer.sleep(250)
      CacheHelper.sync_test()

      {:ok, storages} = CacheQuery.from_server_get_storages(server)
      storage = storages |> Enum.random() |> StorageQuery.fetch()

      entity_id = EntityQuery.get_entity_id(account)

      file = Factory.insert(:file, software_type: :log_forger, storage: storage)
      modules = %{log_forger_create: 100, log_forger_edit: 100}
      # FIXME: this function should exist on the FileAction
      FileInternal.set_modules(file, modules)

      params = %{
        target_server_id: server,
        message: "",
        operation: "create",
        entity_id: entity_id
      }

      result = FileFlow.execute_file(file, server, params)
      assert {:ok, process} = result
      assert %LogForge{} = process.process_data
      assert "log_forger" == process.process_type

      TOPHelper.top_stop(server)
    end
  end

  describe "cracker" do
    test "starts firewall process on success" do
      account = AccountFactory.insert(:account)

      {:ok, %{server: server}} = AccountFlow.setup_account(account)

      :timer.sleep(250)
      CacheHelper.sync_test()

      params = %{
        entity_id: Entity.ID.generate(),
        network_id: Network.ID.generate(),
        target_server_id: Server.ID.generate(),
        target_server_ip: IPv4.autogenerate(),
        server_type: "vpc"
      }

      {:ok, storages} = CacheQuery.from_server_get_storages(server)
      storage = storages |> Enum.random() |> StorageQuery.fetch()

      file = Factory.insert(:file, software_type: :cracker, storage: storage)
      modules = %{cracker_password: 100}
      # FIXME: this function should exist on the FileAction
      FileInternal.set_modules(file, modules)

      result = FileFlow.execute_file(file, server, params)
      assert {:ok, process} = result
      assert %Cracker{} = process.process_data
      assert "cracker" == process.process_type

      TOPHelper.top_stop(server)
    end
  end
end
