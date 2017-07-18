defmodule Helix.Hardware.Query.ComponentSpec do

  alias Helix.Hardware.Model.ComponentSpec
  alias Helix.Hardware.Query.ComponentSpec.Origin, as: ComponentSpecQueryOrigin

  @spec fetch(String.t) :: ComponentSpec.t | nil
  @doc """
  Fetches acomponent specification
  """
  defdelegate fetch(spec_id),
    to: ComponentSpecQueryOrigin

  @spec find([ComponentSpecInternal.find_param], meta :: []) ::
    [ComponentSpec.t]
  @doc """
  Search for component specifications

  ## Params

  * `:type` - filters by specification type
  """
  defdelegate find(params, meta \\ []),
    to: ComponentSpecQueryOrigin

  defmodule Origin do

    alias Helix.Hardware.Internal.ComponentSpec, as: ComponentSpecInternal

    def fetch(spec_id) do
      ComponentSpecInternal.fetch(spec_id)
    end

    def find(params, meta) do
      ComponentSpecInternal.find(params, meta)
    end
  end
end
