defmodule Rumbl.Multimedia do
  @moduledoc """
  The Multimedia context.
  """

  import Ecto.Query, warn: false

  alias Rumbl.Repo
  alias Rumbl.Multimedia.{Annotation, Category, Video}
  alias Rumbl.Accounts

  @doc """
  Creates a category if it doesn't already exist.

  ## Examples

      iex> create_category("some category")
      %Category{}

  """
  def create_category(name) do
    Repo.get_by(Category, name: name) || Repo.insert!(%Category{name: name})
  end

  @doc """
  Returns an alphabetically sorted list of categories.

  ## Examples

      iex> list_alphabetical_categories()
      [%Category{}, ...]

  """
  def list_alphabetical_categories do
    Category
    |> Category.alphabetical()
    |> Repo.all()
  end

  @doc """
  Returns the list of videos.

  ## Examples

      iex> list_videos()
      [%Video{}, ...]

  """
  def list_videos do
    Video
    |> Repo.all()
    |> preload_user()
  end

  def list_user_videos(%Accounts.User{} = user) do
    Video
    |> user_videos_query(user)
    |> Repo.all()
    |> preload_user()
  end

  @doc """
  Gets a single video.

  Raises `Ecto.NoResultsError` if the Video does not exist.

  ## Examples

      iex> get_video!(123)
      %Video{}

      iex> get_video!(456)
      ** (Ecto.NoResultsError)

  """
  def get_video!(id), do: preload_user(Repo.get!(Video, id))

  def get_user_video!(%Accounts.User{} = user, id) do
    from(v in Video, where: v.id == ^id)
    |> user_videos_query(user)
    |> Repo.one!()
    |> preload_user()
  end

  defp preload_user(video_or_videos), do: Repo.preload(video_or_videos, :user)

  defp user_videos_query(query, %Accounts.User{id: user_id}) do
    from(v in query, where: v.user_id == ^user_id)
  end

  @doc """
  Updates a video.

  ## Examples

      iex> update_video(video, %{field: new_value})
      {:ok, %Video{}}

      iex> update_video(video, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_video(%Video{} = video, attrs) do
    video
    |> Video.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Video.

  ## Examples

      iex> delete_video(video)
      {:ok, %Video{}}

      iex> delete_video(video)
      {:error, %Ecto.Changeset{}}

  """
  def delete_video(%Video{} = video) do
    Repo.delete(video)
  end

  @doc """
  Creates a video.

  ## Examples

      iex> create_video(user, %{field: value})
      {:ok, %Video{}}

      iex> create_video(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_video(%Accounts.User{} = user, attrs \\ %{}) do
    %Video{}
    |> Video.changeset(attrs)
    |> put_user(user)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking video changes.

  ## Examples

      iex> change_video(user, video)
      %Ecto.Changeset{source: %Video{}}

  """
  def change_video(%Accounts.User{} = user, %Video{} = video) do
    video
    |> Video.changeset(%{})
    |> put_user(user)
  end

  def annotate_video(%Accounts.User{} = user, video_id, attrs) do
    %Annotation{video_id: video_id}
    |> Annotation.changeset(attrs)
    |> put_user(user)
    |> Repo.insert()
  end

  def list_annotations(%Video{} = video) do
    Repo.all(
      from(
        a in Ecto.assoc(video, :annotations),
        order_by: [asc: a.at, asc: a.id],
        limit: 500,
        preload: [:user]
      )
    )
  end

  defp put_user(changeset, user) do
    Ecto.Changeset.put_assoc(changeset, :user, user)
  end
end
