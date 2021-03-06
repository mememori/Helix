defmodule Helix.Software.Supervisor do

  use Supervisor

  alias Helix.Software.Repo

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init(_) do
    children = [
      worker(Repo, [])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
