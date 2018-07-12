defmodule MastaniServer.Accounts.SysNotificationMail do
  use Ecto.Schema
  import Ecto.Changeset
  alias MastaniServer.Accounts.{User, SysNotificationMail}

  @required_fields ~w(user_id source_id source_type)a
  @optional_fields ~w(source_preview read)a

  schema "sys_notification_mails" do
    belongs_to(:user, User)

    field(:source_id, :string)
    field(:source_preview, :string)
    field(:source_title, :string)
    field(:source_type, :string)
    field(:read, :boolean)

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(%SysNotificationMail{} = sys_notication_mail, attrs) do
    sys_notication_mail
    |> cast(attrs, @optional_fields ++ @required_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:user_id)
  end
end