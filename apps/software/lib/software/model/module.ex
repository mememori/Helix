defmodule Helix.Software.Model.Module do

  use Ecto.Schema

  alias HELL.PK
  alias Helix.Software.Model.ModuleRole, as: MdlModuleRole, warn: false
  alias Helix.Software.Model.File, as: MdlFile, warn: false
  import Ecto.Changeset

  @type t :: %__MODULE__{
    module_version: non_neg_integer,
    file: MdlFile.t,
    file_id: PK.t,
    role: MdlModuleRole.t,
    module_role_id: PK.t,
    inserted_at: NaiveDateTime.t,
    updated_at: NaiveDateTime.t
  }

  @type creation_params :: %{
    file_id: PK.t,
    module_role_id: PK.t,
    module_version: non_neg_integer
  }
  @type update_params :: %{module_version: non_neg_integer}

  @creation_fields ~w/file_id module_role_id module_version/a
  @update_fields ~w/module_version/a

  @primary_key false
  schema "modules" do
    belongs_to :file, MdlFile,
      foreign_key: :file_id,
      references: :file_id,
      type: HELL.PK,
      primary_key: true
    belongs_to :role, MdlModuleRole,
      foreign_key: :module_role_id,
      references: :module_role_id,
      type: HELL.PK,
      primary_key: true

    field :module_version, :integer

    timestamps()
  end

  @spec create_changeset(creation_params) :: Ecto.Changeset.t
  def create_changeset(params) do
    %__MODULE__{}
    |> cast(params, @creation_fields)
    |> validate_required([:file_id, :module_role_id, :module_version])
    |> generic_validations()
  end

  @spec update_changeset(t | Ecto.Changeset.t, update_params) :: Ecto.Changeset.t
  def update_changeset(schema, params) do
    schema
    |> cast(params, @update_fields)
    |> generic_validations()
  end

  @spec generic_validations(Ecto.Changeset.t) :: Ecto.Changeset.t
  def generic_validations(changeset) do
    changeset
    |> validate_number(:module_version, greater_than: 0)
  end
end