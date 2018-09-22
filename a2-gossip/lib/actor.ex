defmodule Actor do
  use GenServer

  # Client
  def start_link(default) do
    GenServer.start_link(__MODULE__, default)
  end

  def push_pid(pid, item) do
    GenServer.cast(pid, {:push, item})
  end

  def gossip(pid) do
    GenServer.cast(pid, :gossip)
  end

  # Server (callbacks)
  @impl true
  def init(default) do
    {:ok, default}
  end

  @impl true
  def handle_call(:pop, _from, {count,[head | tail]}) do
    {:reply, head, {count,tail}}
  end

  @impl true
  def handle_cast(:gossip, {count,neighbors}) do
    if List.first(neighbors) != nil do
      forwardTo = Enum.random(neighbors)
      current = self()
      # IO.inspect "from: " <> current
      # IO.inspect "to: " <> forwardTo
      IO.inspect current
      IO.inspect forwardTo
      IO.inspect count + 1
      if count<3 do
        Actor.gossip(forwardTo)
      end
    end
    {:noreply, {count+1,neighbors} }
  end

  @impl true
  def handle_cast({:push, item}, {count,neighbors}) do
    {:noreply, {count,[item | neighbors]} }
  end
end
