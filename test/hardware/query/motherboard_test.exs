defmodule Helix.Hardware.Query.MotherboardTest do

  use Helix.Test.IntegrationCase

  alias HELL.TestHelper.Random
  alias Helix.Hardware.Query.Motherboard, as: MotherboardQuery

  alias Helix.Hardware.Factory

  describe "fetch/1" do
    test "succeeds by component" do
      motherboard = Factory.insert(:motherboard)
      result = MotherboardQuery.fetch(motherboard.component)

      assert result
      assert result.motherboard_id == motherboard.motherboard_id
    end

    test "returns nil when input is invalid" do
      bogus_motherboard = Factory.build(:motherboard)

      refute MotherboardQuery.fetch(bogus_motherboard.component)
    end
  end

  describe "get_slots/1" do
    test "succeeds by id" do
      motherboard = Factory.insert(:motherboard)

      slots =
        motherboard.slots
        |> Enum.map(&(&1.slot_id))
        |> Enum.sort()

      got =
        motherboard.motherboard_id
        |> MotherboardQuery.get_slots()
        |> Enum.map(&(&1.slot_id))
        |> Enum.sort()

      assert slots == got
    end

    test "succeeds by struct" do
      motherboard = Factory.insert(:motherboard)

      slots =
        motherboard.slots
        |> Enum.map(&(&1.slot_id))
        |> Enum.sort()

      got =
        motherboard
        |> MotherboardQuery.get_slots()
        |> Enum.map(&(&1.slot_id))
        |> Enum.sort()

      assert slots == got
    end

    test "returns empty list when nothing is found" do
      bogus = Random.pk()
      assert Enum.empty?(MotherboardQuery.get_slots(bogus))
    end
  end
end
