defmodule MastaniServer.CMS.Job do
  @moduledoc false
  alias __MODULE__

  use Ecto.Schema
  import Ecto.Changeset

  alias MastaniServer.CMS.{
    Author,
    Community,
    JobComment,
    JobFavorite,
    JobStar,
    JobViewer,
    JobCommunityFlag,
    Tag
  }

  @timestamps_opts [type: :utc_datetime_usec]
  @required_fields ~w(title company company_logo body digest length)a
  @optional_fields ~w(desc company_link link_addr copy_right salary exp education field finance scale)a

  @type t :: %Job{}
  schema "cms_jobs" do
    field(:title, :string)
    field(:company, :string)
    field(:company_logo, :string)
    field(:company_link, :string)
    field(:desc, :string)
    field(:body, :string)
    belongs_to(:author, Author)
    field(:views, :integer, default: 0)
    field(:link_addr, :string)
    field(:copy_right, :string)

    field(:salary, :string)
    field(:exp, :string)
    field(:education, :string)
    field(:field, :string)
    field(:finance, :string)
    field(:scale, :string)

    field(:digest, :string)
    field(:length, :integer)

    has_many(:community_flags, {"jobs_communities_flags", JobCommunityFlag})

    # NOTE: this one is tricky, pin is dynamic changed when return by func: add_pin_contents_ifneed
    field(:pin, :boolean, default_value: false, virtual: true)
    field(:trash, :boolean, default_value: false, virtual: true)

    has_many(:comments, {"jobs_comments", JobComment})
    has_many(:favorites, {"jobs_favorites", JobFavorite})
    has_many(:stars, {"jobs_stars", JobStar})
    has_many(:viewers, {"jobs_viewers", JobViewer})

    many_to_many(
      :tags,
      Tag,
      join_through: "jobs_tags",
      join_keys: [job_id: :id, tag_id: :id],
      # :delete_all will only remove data from the join source
      on_delete: :delete_all,
      on_replace: :delete
    )

    many_to_many(
      :communities,
      Community,
      join_through: "communities_jobs",
      on_replace: :delete
    )

    # timestamps(type: :utc_datetime)
    timestamps()
  end

  @doc false
  def changeset(%Job{} = job, attrs) do
    job
    |> cast(attrs, @optional_fields ++ @required_fields)
    |> validate_required(@required_fields)
    |> generl_changeset
  end

  @doc false
  def update_changeset(%Job{} = job, attrs) do
    job
    |> cast(attrs, @optional_fields ++ @required_fields)
    |> generl_changeset
  end

  defp generl_changeset(content) do
    content
    |> validate_length(:title, min: 3, max: 50)
    |> validate_length(:body, min: 3, max: 10_000)
  end

  @doc false
  def update_changeset(%Job{} = job, attrs) do
    job
    |> cast(attrs, @optional_fields ++ @required_fields)
  end
end
