defmodule LvChatWeb.Router do
  use LvChatWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Phoenix.LiveView.Flash
  end

  pipeline :session do
    plug LvChatWeb.Plug.Session
  end

  scope "/", LvChatWeb do
    pipe_through :browser


    scope "/chat" do
      pipe_through :session

      live "/", PageLive
      get "/logout", PageController, :delete
    end
    
    get "/oauth", PageController, :oauth_facebook
    get "/auth/:provider/callback", PageController, :callback
    
    get "/*path", PageController, :login
  end
end
