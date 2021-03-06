defmodule Helix.Universe.NPC.Model.NPC do

  use Ecto.Schema
  use HELL.ID, field: :npc_id, meta: [0x0002]

  import Ecto.Changeset

  alias HELL.Constant
  alias Helix.Universe.NPC.Model.NPCType

  @type t :: %__MODULE__{
    npc_id: id,
    npc_type: Constant.t,
    inserted_at: NaiveDateTime.t,
    updated_at: NaiveDateTime.t
  }

  @type creation_params :: %{
    :npc_type => Constant.t
  }

  @creation_fields ~w/npc_type/a

  @primary_key false
  schema "npcs" do
    field :npc_id, ID,
      primary_key: true

    field :npc_type, Constant

    timestamps()
  end

  @spec create_changeset(creation_params) ::
    Ecto.Changeset.t
  def create_changeset(params) do
    %__MODULE__{}
    |> cast(params, @creation_fields)
    |> validate_required(:npc_type)
    |> validate_inclusion(:npc_type, NPCType.possible_types())
  end

  defmodule Query do

    import Ecto.Query, only: [where: 3]

    alias Ecto.Queryable
    alias Helix.Universe.NPC.Model.NPC

    @spec by_id(Queryable.t, NPC.idtb) ::
      Queryable.t
    def by_id(query \\ NPC, npc),
      do: where(query, [n], n.npc_id == ^npc)
  end
end
