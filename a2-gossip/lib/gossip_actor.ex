defmodule GossipActor do
  use GenServer
  @limit 10
  @time_interval 1
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

  def add_peers(pid, pidList) do
    for x <- 0..Enum.count(pidList)-1 do
      add_peer(pid, Enum.at(pidList,x))
    end
  end

  def gossip(pid) do
    GenServer.cast(pid, :gossip)
  end

  def inform_main_of_hibernation(pid) do
    HibernateStatusActor.hibernate(pid)
  end

  # Server Side (callbacks)
  def init(default) do
    {:ok, default}
  end

  #################### Handle_Calls #####################
  # get_count
  def handle_call(:get_count, _from, {count,main_pid,start_time,neighbors} ) do
    {:reply,count, start_time,{count,neighbors}}
  end

  #################### Handle_Infos #####################
  def handle_info(:repeat, {count,main_pid,start_time,neighbors}) do
    forwardTo = Enum.random(neighbors)
    GossipActor.gossip(forwardTo)
    #if count < @limit do
      Process.send_after(self,:repeat, @time_interval)
    #end 
    { :noreply, {count,main_pid,start_time,neighbors} }
  end
  
  #################### Handle_Casts #####################
  # Gossip
  def handle_cast(:gossip, {count,main_pid,start_time,neighbors}) do
    current = self()
    #rumor handling for the first time
    if count == 0 do
      Process.send_after(self,:repeat, @time_interval)
    end
    updatedState = 
    case count < @limit do 
      true -> 
        forwardTo = Enum.random(neighbors)
        GossipActor.gossip(forwardTo)
        if (count+1) == @limit do
          inform_main_of_hibernation(main_pid)
          timeToHibernation = System.monotonic_time(:millisecond) - start_time
          IO.inspect "time to hibernation: #{ timeToHibernation}"
        end
        {:noreply, {count+1,main_pid,start_time,neighbors} }
      false ->  
        {:noreply, {count,main_pid,start_time,neighbors}}
    end 
  end

  # push
  def handle_cast({:push, item}, {count,main_pid,start_time,neighbors}) do
    {:noreply, {count,main_pid,start_time,[item | neighbors]} }
  end

  # step
  def handle_cast(:step, {count,main_pid,start_time,neighbors}) do 
    if count >= 1 do
      self = self()
      GossipActor.gossip(self)
    end
    {:noreply, {count,main_pid,start_time,neighbors}}
  end
end

