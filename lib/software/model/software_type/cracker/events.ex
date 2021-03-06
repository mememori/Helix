defmodule Helix.Software.Model.SoftwareType.Cracker.ProcessConclusionEvent do

  alias HELL.IPv4
  alias Helix.Entity.Model.Entity
  alias Helix.Network.Model.Network
  alias Helix.Server.Model.Server

  @type t :: %__MODULE__{
    entity_id: Entity.id,
    network_id: Network.id,
    server_id: Server.id,
    server_ip: IPv4.t,
    server_type: term
  }

  @enforce_keys [:entity_id, :network_id, :server_ip, :server_id, :server_type]
  defstruct [:entity_id, :network_id, :server_ip, :server_id, :server_type]
end
