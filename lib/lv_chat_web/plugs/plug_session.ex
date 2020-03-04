defmodule LvChatWeb.Plug.Session do
    @behaviour Plug
    alias LvChatWeb.Router.Helpers, as: Routes

    def init(opts), do: opts
  
    def call(conn = %{private: %{:plug_session => sess = %{"profile" => session}}}, _) do
        conn
    end

    def call(conn, _), do: Phoenix.Controller.redirect(conn, to: Routes.page_path(conn, :login, [])) |> Plug.Conn.halt
end