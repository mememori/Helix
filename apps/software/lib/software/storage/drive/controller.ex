defmodule HELM.Software.Storage.Drive.Controller do
  import Ecto.Query

  alias HELM.Software.Repo
  alias HELM.Software.Storage.Drive.Schema, as: SoftStorageDriveSchema

  def create(drive_id, storage_id) do
    %{drive_id: drive_id, storage_id: storage_id}
    |> SoftStorageDriveSchema.create_changeset
    |> do_create
  end

  def find(drive_id) do
    case Repo.get_by(SoftStorageDriveSchema, drive_id: drive_id) do
      nil -> {:error, "Drive not found."}
      res -> {:ok, res}
    end
  end

  def delete(drive_id) do
    case find(drive_id) do
      {:ok, drive} -> do_delete(drive)
      error -> error
    end
  end

  defp do_create(changeset) do
    case Repo.insert(changeset) do
      {:ok, schema} ->
        {:ok, schema}
      {:error, changeset} ->
        {:error, changeset}
    end
  end

  defp do_delete(changeset) do
    case Repo.delete(changeset) do
      {:ok, result} -> {:ok, result}
      {:error, msg} -> {:error, msg}
    end
  end
end