defmodule PushSumActor do
    use GenServer
  
    # Client
    def start_link(default) do
      GenServer.start_link(__MODULE__, default)
    end
  
    def get_count(pid)do
      count = GenServer.call(pid,:get_count)
    end
  
    def push_pid(pid, item) do
      GenServer.cast(pid, {:push, item})
    end
  
    def pushsum(pid) do
        GenServer.cast(pid, :pushsum)
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
  
    #get my count
    @impl true
    def handle_call(:get_count, _from, {count,neighbors} ) do
      {:reply,count, {count,neighbors}}
    end
  
    @impl true
    def handle_cast(:gossip, {count,neighbors}) do
      current = self()
      if (List.first(neighbors) != nil) && count<10 do 
        forwardTo = Enum.random(neighbors)
        IO.inspect current
        IO.inspect forwardTo
        IO.inspect count + 1
        PushSumActor.gossip(forwardTo) 
      end
      {:noreply, {count+1,neighbors} }
    end
  
    @impl true
    def handle_cast({:push, item}, {count,neighbors}) do
      {:noreply, {count,[item | neighbors]} }
    end
  end
  