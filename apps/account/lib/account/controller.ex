defmodule HELM.Account.Controller do
  import Ecto.Changeset
  import Ecto.Query

  alias HELF.{Broker, Error}
  alias HELM.Account.{Repo, Schema}

  def find_account(account_id) do
    Schema
    |> where([a], a.account_id == ^account_id)
    |> select([a], map(a, [:account_id, :confirmed, :email]))
    |> Repo.one()
    |> case do
      nil -> {:error, :notfound}
      account -> {:ok, account}
    end
  end

  def find(email) do
    case Repo.get_by(Account, email: email) do
      nil -> {:reply, {:error, Error.format_reply(:not_found, "Account with given email not found")}}
      res -> {:reply, {:ok, res}}
    end
  end

  defp do_find_account(email: email, password: password) do
    Schema
    |> where([a], a.email == ^email and a.password == ^password)
    |> select([a], map(a, [:account_id, :confirmed, :email]))
    |> Repo.one()
    |> case do
      nil -> {:error, :notfound}
      account -> {:ok, account}
    end
  end

  def new_account(account) do
    changeset   = Schema.create_changeset(account)
    account_id  = changeset.changes.account_id

    with {:ok, _} <- do_new_account(changeset),
         {:ok, _} <- do_new_entity(account_id) do
      Broker.cast("event:account:created", account_id)
      {:ok, changeset}
    else
      {:error, :entity, msg} ->
        Repo.delete(changeset)
        {:error, msg}
      {:error, msg} -> {:error, msg}
    end
  end

  defp do_new_account(changeset) do
    case Repo.insert(changeset) do
      {:ok, changeset} -> {:ok, changeset}
      {:error, changeset} ->
        email_taken? = Enum.any?(changeset.errors, &(&1 == {:email, "has already been taken"}))
        if email_taken? do
          {:error, Error.format_reply({:bad_request, "Email has already been taken"})}
        else
          {:error, Error.format_reply({:internal, "Could not create the account"})}
        end
    end
  end

  defp do_new_entity(account_id) do
    case Broker.call("entity:create", {:account_id, account_id}) do
      {:ok, message} -> {:ok, message}
      {:error, _} -> {:error, :entity, Error.format_reply({:internal, "Could not create the entity"})}
    end
  end

  def login_with(account = %{"email" => email, "password" => pass}) do
    do_find_account(email: email, password: pass)
    |> do_login
  end

  defp do_login({:ok, account}) do
    Broker.call("jwt:create", account.account_id)
  end

  defp do_login({:error, err}) do
    case err do
      :notfound ->
        {:error, Error.format_reply(:unauthorized, "Account not found.")}
      _ ->
        {:error, Error.format_reply(:unspecified, "oh god")}
    end
  end

  def get(request) do
    case Broker.call("auth:account:verify", request.args["jwt"]) do
      :ok -> find(request.args["email"])
      {:error, reason} -> {:reply, {:error, reason}}
    end
  end
end