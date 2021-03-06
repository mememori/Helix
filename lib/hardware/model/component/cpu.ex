defmodule Helix.Hardware.Model.Component.CPU do

  use Ecto.Schema

  import Ecto.Changeset

  alias Ecto.Changeset
  alias Helix.Hardware.Model.Component
  alias Helix.Hardware.Model.ComponentSpec

  @behaviour Helix.Hardware.Model.ComponentSpec

  @type id :: Component.id
  @type t :: %__MODULE__{
    cpu_id: id,
    clock: non_neg_integer,
    cores: pos_integer,
    component: term
  }

  @primary_key false
  schema "cpus" do
    field :cpu_id, Component.ID,
      primary_key: true

    field :clock, :integer
    field :cores, :integer,
      default: 1

    belongs_to :component, Component,
      foreign_key: :cpu_id,
      references: :component_id,
      define_field: false,
      on_replace: :delete
  end

  @spec create_from_spec(ComponentSpec.t) ::
    Changeset.t
  def create_from_spec(cs = %ComponentSpec{spec: spec}) do
    params = Map.take(spec, ["clock", "cores"])

    component = Component.create_from_spec(cs)

    %__MODULE__{}
    |> changeset(params)
    |> put_assoc(:component, component)
  end

  @spec update_changeset(t | Ecto.Changeset.t, map) ::
    Changeset.t
  def update_changeset(struct, params),
    do: changeset(struct, params)

  @spec changeset(%__MODULE__{} | Changeset.t, map) ::
    Changeset.t
  def changeset(struct, params) do
    struct
    |> cast(params, [:clock, :cores])
    |> validate_required([:clock, :cores])
    |> validate_number(:clock, greater_than_or_equal_to: 0)
    |> validate_number(:cores, greater_than_or_equal_to: 1)
    |> foreign_key_constraint(:cpu_id, name: :cpus_cpu_id_fkey)
  end

  @spec validate_spec(%{:clock => non_neg_integer, :cores => pos_integer, optional(any) => any}) ::
    Changeset.t
  @doc false
  def validate_spec(params) do
    data = %{
      clock: nil,
      cores: nil
    }
    types = %{
      clock: :integer,
      cores: :integer
    }

    {data, types}
    |> cast(params, [:clock, :cores])
    |> validate_required([:clock, :cores])
    |> validate_number(:clock, greater_than_or_equal_to: 0)
    |> validate_number(:cores, greater_than_or_equal_to: 1)
  end

  defmodule Query do
    import Ecto.Query

    alias Ecto.Queryable
    alias Helix.Hardware.Model.Component
    alias Helix.Hardware.Model.Component.CPU

    @spec from_components_ids(Queryable.t, [Component.idtb]) ::
      Queryable.t
    def from_components_ids(query \\ CPU, components_ids),
      do: where(query, [c], c.cpu_id in ^components_ids)

    @spec by_component(Queryable.t, Component.idtb) ::
      Queryable.t
    def by_component(query \\ CPU, id),
      do: where(query, [c], c.cpu_id == ^id)
  end
end
