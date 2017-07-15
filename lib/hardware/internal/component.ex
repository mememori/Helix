defmodule Helix.Hardware.Internal.Component do

  alias HELL.Constant
  alias Helix.Hardware.Model.Component
  alias Helix.Hardware.Model.ComponentSpec
  alias Helix.Hardware.Model.ComponentType
  alias Helix.Hardware.Repo

  @type find_param ::
    {:id, [HELL.PK.t]}
    | {:type, [Constant.t] | Constant.t}

  @spec create_from_spec(ComponentSpec.t) ::
    {:ok, Component.t}
    | {:error, Ecto.Changeset.t}
  def create_from_spec(spec = %ComponentSpec{}) do
    module = ComponentType.type_implementation(spec.component_type)

    changeset = module.create_from_spec(spec)

    case Repo.insert(changeset) do
      {:ok, %{component: c}} ->
        {:ok, c}
      e ->
        e
    end
  end

  @spec fetch(HELL.PK.t) :: Component.t | nil
  def fetch(component_id),
    do: Repo.get(Component, component_id) |> Repo.preload(:slot)

  @spec find([find_param], meta :: []) :: [Component.t]
  def find(params, _meta \\ []) do
    params
    |> Enum.reduce(Component, &reduce_find_params/2)
    |> Repo.all()
  end

  @spec delete(Component.t | HELL.PK.t) :: no_return
  def delete(component = %Component{}),
    do: delete(component.component_id)
  def delete(component_id) do
    component_id
    |> Component.Query.by_id()
    |> Repo.delete_all()

    :ok
  end

  @spec reduce_find_params(find_param, Ecto.Queryable.t) :: Ecto.Queryable.t
  defp reduce_find_params({:id, id_list}, query) when is_list(id_list),
    do: Component.Query.from_id_list(query, id_list)
  defp reduce_find_params({:type, type_list}, query) when is_list(type_list),
    do: Component.Query.from_type_list(query, type_list)
  defp reduce_find_params({:type, type}, query),
    do: Component.Query.by_type(query, type)

  def get_motherboard(component = %Component{component_type: :mobo}) do
    component.component_id
  end
  def get_motherboard(component = %Component{}) do
    component
    |> Repo.preload(:slot)
    |> Map.get(:slot)
    |> case do
         nil ->
           nil
         slot ->
           Map.get(slot, :motherboard_id)
       end
  end
  def get_motherboard(component_id) do
    component_id
    |> fetch()
    |> get_motherboard()
  end
end
