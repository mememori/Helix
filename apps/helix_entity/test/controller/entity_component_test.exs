defmodule Helix.Entity.Controller.EntityComponentTest do

  use ExUnit.Case, async: true

  alias HELL.PK
  alias Helix.Entity.Controller.EntityComponent, as: EntityComponentController
  alias Helix.Entity.Model.Entity
  alias Helix.Hardware.Model.Component

  alias Helix.Entity.Factory

  @moduletag :integration

  describe "adding entity ownership over components" do
    test "succeeds with entity_id" do
      %{entity_id: entity_id} = Factory.insert(:entity)
      comp_id = PK.pk_for(Component)

      assert {:ok, _} = EntityComponentController.create(entity_id, comp_id)
    end

    test "succeeds with entity struct" do
      entity = Factory.insert(:entity)
      component_id = PK.pk_for(Component)

      assert {:ok, _} = EntityComponentController.create(entity, component_id)
    end

    test "fails when entity doesn't exist" do
      entity_id = PK.pk_for(Entity)
      component_id = PK.pk_for(Component)

      assert_raise(Ecto.ConstraintError, fn ->
        EntityComponentController.create(entity_id, component_id)
      end)
    end
  end

  describe "fetching components owned by an entity" do
    test "returns a list with owned components" do
      entity = Factory.insert(:entity)
      components = Factory.insert_list(5, :entity_component, %{entity: entity})
      expected_components = Enum.map(components, &(&1.component_id))
      fetched_components = EntityComponentController.find(entity)

      assert expected_components == fetched_components
    end

    test "returns an empty list when no component is owned" do
      entity = Factory.insert(:entity)
      fetched_components = EntityComponentController.find(entity)

      assert Enum.empty?(fetched_components)
    end
  end

  test "removing entity ownership over components is idempotent" do
    ec = Factory.insert(:entity_component)

    refute Enum.empty?(EntityComponentController.find(ec.entity_id))

    EntityComponentController.delete(ec.entity_id, ec.component_id)
    EntityComponentController.delete(ec.entity_id, ec.component_id)

    assert Enum.empty?(EntityComponentController.find(ec.entity_id))
  end
end