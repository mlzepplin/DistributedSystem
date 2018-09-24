defmodule GossipActor do
  use GenServer

  # Client Side
  def start_link(default) do
    GenServer.start_link(__MODULE__, default)
  end

  def get_count(pid)do
    count = GenServer.call(pid,:get_count)
  end

  def add_peer(pid, item) do
    GenServer.cast(pid, {:push, item})
  end

  def gossip(pid) do
    GenServer.cast(pid, :gossip)
  end

  def inform_main_of_hibernation(pid) do
    A2.cast(pid, :hibernate)
  end

  # Server Side (callbacks)
  def init(default) do
    {:ok, default}
  end

  #################### Handle_Calls #####################
  
  # pop
  def handle_call(:pop, _from, {count,main_pid,start_time,[head | tail]}) do
    {:reply, head, start_time,{count,tail}}
  end

  # get_count
  def handle_call(:get_count, _from, {count,main_pid,start_time,neighbors} ) do
    {:reply,count, start_time,{count,neighbors}}
  end

  #################### Handle_Casts #####################
  
  # Gossip
  def handle_cast(:gossip, {count,main_pid,start_time,neighbors}) do
    current = self()
    updatedState = 
    case count + 1 >= 5 do 
      true -> 
        inform_main_of_hibernation(main_pid)
        timeToHibernation = System.monotonic_time(:millisecond) - start_time
        IO.inspect "time to hibernation : #{ timeToHibernation}"
        {:noreply, {count,main_pid,start_time,neighbors}}
        #TODO - decide, to kill the node or not
      false ->
        forwardTo = Enum.random(neighbors)
        IO.inspect current
        IO.inspect forwardTo
        IO.inspect count + 1
        GossipActor.gossip(forwardTo) 
        {:noreply, {count+1,main_pid,start_time,neighbors} }
    end
    
  end

  # push
  def handle_cast({:push, item}, {count,main_pid,start_time,neighbors}) do
    {:noreply, {count,main_pid,start_time,[item | neighbors]} }
  end

end
