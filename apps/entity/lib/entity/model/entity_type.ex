defmodule HELM.Entity.Model.EntityType do
  use Ecto.Schema

  import Ecto.Changeset

  alias HELM.Entity.Model.Entity, as: MdlEntity
  alias HELM.Entity.Model.EntityType, as: MdlEntityType

  @primary_key {:entity_type, :string, autogenerate: false}
  @creation_fields ~w/entity_type/a

  schema "entity_types" do
    has_many :entities, MdlEntity,
      foreign_key: :entity_type,
      references: :entity_type

    timestamps
  end

  def create_changeset(params) do
    %__MODULE__{}
    |> cast(params, @creation_fields)
    |> validate_required(:entity_type)
  end
end