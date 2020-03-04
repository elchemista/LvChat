defmodule LvChatWeb.PageLive do
  use Phoenix.LiveView
  alias LvChatWeb.PageView

  def render(assigns) do
    PageView.render("index.html", assigns)
  end

  def mount(_, session, socket) do
    session
    |> Map.get("profile")
    |> case do
      profile when is_map(profile) ->
        GenServer.cast(self(), :start)
        {:ok, assign(socket, excluding: [self()], profile: profile, chat: nil, messages: [])}
      
      _ ->
        {:ok, redirect(socket, to: "/")}
    end
  end

  def handle_event("new_message", value, socket) do
    GenServer.cast(socket.assigns.chat.pid, {:message, value["message"]})
    {:noreply, assign(socket, messages: socket.assigns.messages ++ [%{avatar: false, message: value["message"]}])}
  end
  def handle_event("reset", _value, socket = %{assign: %{chat: chat}}) when not is_nil(chat) do
    GenServer.cast(socket.assigns.chat.pid, :start)
    GenServer.cast(self(), :start)
    {:noreply, assign(socket, excluding: [socket.assigns.chat.pid | socket.assigns.excluding])}
  end
  def handle_event("logout", _value, socket) do
    {:noreply, redirect(socket, to: "/chat/logout")}
  end
  def handle_event(_, _value, socket) do
    {:noreply, socket}
  end

  def handle_cast({:message, message}, socket) do
    {:noreply, assign(socket, messages: socket.assigns.messages ++ [%{avatar: true, message: message}])}
  end

  def handle_cast(:start, socket) do
    if Map.get(socket.assigns, :monitor), do: Process.demonitor(socket.assigns.monitor) 
    LvChat.subscribe(self(), socket.assigns.profile.gender)
    send(self(), :searching)
    {:noreply, assign(socket, messages: [], chat: nil, monitor: nil)}
  end
  def handle_cast(_, socket), do: {:noreply, socket}
  
  def handle_call({:handshake, prof}, {from, _}, socket = %{assigns: %{chat: chat}}) when is_nil(chat) do
    if socket.assigns.ref, do: Process.cancel_timer(socket.assigns.ref)
    monitor = Process.monitor(from)
    LvChat.unsubscribe(self())
    LvChat.unsubscribe(from)
    {:reply, {:ok, self(), socket.assigns.profile}, assign(socket, chat: %{pid: from, profile: prof}, monitor: monitor)}
  end

  def handle_info(:searching, socket = %{assigns: %{chat: chat}}) when is_nil(chat) do
    LvChat.match(socket.assigns.profile.gender, socket.assigns.excluding)
    |> try_call(socket.assigns.profile)
    |> case do
      {:ok, from, prof} ->
        monitor = Process.monitor(from)
        {:noreply, assign(socket, chat: %{pid: from, profile: prof}, monitor: monitor)}
      
      _ ->
        ref = Process.send_after(self(), :searching, 5000)
        {:noreply, assign(socket, ref: ref)}
    end
  end

  def handle_info({:EXIT, from, _reason}, socket = %{assigns: %{chat: %{pid: pid}}}) when from == pid do
    Process.demonitor(socket.assigns.monitor)
    Process.send_after(self(), :searching, 5000)
    {:noreply, assign(socket, chat: nil, monitor: nil)}
  end
  def handle_info({:DOWN, ref, :process, _, _}, socket) do
    Process.demonitor(ref)
    Process.send_after(self(), :searching, 5000)
    {:noreply, assign(socket, chat: nil, monitor: nil)}
  end
  def handle_info(_, socket), do: {:noreply, socket}

  defp try_call([h | r], prof) do  
    GenServer.call(h, {:handshake, prof}, 50_000)
  catch
    _, _ ->
      LvChat.unsubscribe(h)
      try_call(r, prof)
  end
  defp try_call([], _prof), do: :empty
end