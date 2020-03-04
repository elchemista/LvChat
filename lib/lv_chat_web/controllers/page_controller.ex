defmodule LvChatWeb.PageController do
  use LvChatWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def oauth_facebook(conn, _) do
    redirect(conn, external: LvChatWeb.Facebook.authorize_url!(scope: "user_gender,public_profile"))
  end

  def login(conn, _params) do
    render(conn, "login.html", layout: false)
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "You have been logged out!")
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end

  def callback(conn, %{"provider" => _provider, "code" => code}) do
    user = get_user!(code)
    profile = %{
      name: user.body["first_name"], 
      avatar: "https://graph.facebook.com/#{user.body["id"]}/picture",
      gender: user.body["gender"]
    }

    conn
    |> put_session(:profile, profile)
    |> redirect(to: "/chat")
  end

  defp get_user!(code) do
      LvChatWeb.Facebook.get_token!(code: code)
      |> OAuth2.Client.get!("/me?fields=id,first_name,name,picture,gender")
  end
end
