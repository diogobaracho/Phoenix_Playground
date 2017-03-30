defmodule PhoenixApi.Api.V1.UserController do
  use PhoenixApi.Web, :controller
  alias PhoenixApi.Repo
  alias PhoenixApi.User

  plug :scrub_params, "user" when action in [:create]

  def index(conn, _params) do
    users = Repo.all(User)
    conn
    |> render("index.json", users: users)
  end

  def show(conn,_params) do
    case Guardian.Plug.current_resource(conn) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{message: "User not found", error: :not_found})
      user ->
        conn
        |> put_status(:ok)
        |> render("show.json", user: user)
      end
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.registration_changeset(%User{}, user_params)
    case Repo.insert(changeset) do
      {:ok, user} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", user_path(conn, :show, user))
        |> render("show.json", user: user)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(PhoenixApi.ChangesetView, "error.json", changeset: changeset)
    end
  end
end