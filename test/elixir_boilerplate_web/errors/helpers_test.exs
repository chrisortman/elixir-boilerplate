defmodule ElixirBoilerplateWeb.Errors.HelpersTest do
  use ElixirBoilerplate.DataCase, async: true

  alias ElixirBoilerplateWeb.Errors.Helpers

  defmodule UserRole do
    use Ecto.Schema

    import Ecto.Changeset

    embedded_schema do
      field(:type, :string)

      timestamps()
    end

    def changeset(%__MODULE__{} = user_role, params) do
      user_role
      |> cast(params, [:type])
      |> validate_inclusion(:type, ~w(admin moderator member))
    end
  end

  defmodule User do
    use Ecto.Schema

    import Ecto.Changeset

    schema "users" do
      field(:email, :string)

      embeds_one(:role, UserRole)

      timestamps()
    end

    def changeset(%__MODULE__{} = user, params) do
      user
      |> cast(params, [:email])
      |> cast_embed(:role)
      |> validate_required([:email])
    end
  end

  test "error_messages/1 without errors should return an empty string" do
    html =
      %User{}
      |> change()
      |> changeset_to_error_messages()

    assert html == ""
  end

  test "error_messages/1 should render error messages on changeset" do
    html =
      %User{}
      |> User.changeset(%{"email" => "", "role" => %{"type" => "lol"}})
      |> changeset_to_error_messages()

    assert html == """
             <ul>
                 <li>email can&#39;t be blank</li>
                 <li>role.type is invalid</li>
             </ul>
           """
  end

  defp changeset_to_error_messages(changeset) do
    changeset
    |> Helpers.error_messages()
    |> Phoenix.HTML.safe_to_string()
  end
end
