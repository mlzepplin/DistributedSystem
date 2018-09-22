defmodule Actor do
  use GenServer

  # Client
  def start_link(default) when is_list(default) do
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
  def init(default_pid_list) do
    {:ok, default_pid_list}
  end

  @impl true
  def handle_call(:pop, _from, [head | tail]) do
    {:reply, head, tail}
  end

  @impl true
  def handle_cast(:gossip, neighbors) do
    if List.first(neighbors) != nil do
      forwardTo = Enum.random(neighbors)
      IO.inspect forwardTo
      Actor.gossip(forwardTo)
    end
    {:noreply, neighbors}
  end

  @impl true
  def handle_cast({:push, item}, state) do
    {:noreply, [item | state]}
    
end
end
