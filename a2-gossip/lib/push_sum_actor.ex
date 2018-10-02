defmodule PushSumActor do
  use GenServer
  @time_interval 10
  # Client Side
  def start_link(default) do
    GenServer.start_link(__MODULE__, default)
  end

  def get_ratio(pid)do
    count = GenServer.call(pid,:get_ratio)
  end

  def add_peer(pid, item) do
    GenServer.cast(pid, {:push, item})
  end

  def add_peers(pid, pidList) do
    for x <- 0..Enum.count(pidList)-1 do
      add_peer(pid, Enum.at(pidList,x))
    end
  end

  def push_sum(pid,swPair) do
    GenServer.cast(pid, {:push_sum,swPair})
    
  end

  def inform_main_of_hibernation(pid) do
    GenServer.cast(pid, :hibernate)
  end

  # Server Side (callbacks)
  def init(default) do
    {:ok, default}
  end

  #################### Handle_Calls #####################

  # get_count
  def handle_call(:get_ratio, _from, {s,w,prev_ratio,count,main_pid,start_time,neighbors} ) do
    {:reply,s/w}
  end

  #################### Handle_Infos #####################
  def handle_info(:repeat, {s,w,hibernated,prev_ratio,count,main_pid,start_time,neighbors}) do
    forwardTo = Enum.random(neighbors)
    # assuming when stepping the rounds, we send out our half state
    push_sum(forwardTo,{s/2,w/2})
    #if count < @limit do
    self = self()
    Process.send_after(self,:repeat, @time_interval)
    #end 
    { :noreply, {s,w,hibernated,prev_ratio,count,main_pid,start_time,neighbors} }
  end

  #################### Handle_Casts #####################
  
  # Push Sum
  def handle_cast({:push_sum,{recievedS,recievedW}}, {s,w,hibernated,prev_ratio,count,main_pid,start_time,neighbors}) do
    self = self()
    updatedS = recievedS + s;
    updatedW = recievedW + w;
    pair = {updatedS/2,updatedW/2}
    currentRatio = updatedS/updatedW
    forwardTo = Enum.random(neighbors)
    if count == 0 do
      Process.send_after(self,:repeat, @time_interval)
    end
    if hibernated do
      {:noreply, {s,w,hibernated,currentRatio,count,main_pid,start_time,neighbors}}
    else 
    
      if (abs(currentRatio - prev_ratio) < :math.pow(10,-10)) do
      
        if count==2 do
          inform_main_of_hibernation(main_pid)
          timeToHibernation = System.monotonic_time(:millisecond) - start_time
          IO.inspect "time to hibernation : #{timeToHibernation} "
          {:noreply, {updatedS,updatedW,true,currentRatio,count+1,main_pid,start_time,neighbors}}
        else
          push_sum(forwardTo,pair)
          push_sum(self,pair)
          {:noreply, {updatedS,updatedW,hibernated,currentRatio,count+1,main_pid,start_time,neighbors}}
        end
      
      else 
        push_sum(forwardTo,pair)
        push_sum(self,pair)
        {:noreply, {updatedS,updatedW,hibernated,currentRatio,0,main_pid,start_time,neighbors}}
      end
    
    end    
  end

  # push
  def handle_cast({:push, item}, {s,w,hibernated,prev_ratio,count,main_pid,start_time,neighbors}) do
    {:noreply, {s,w,hibernated,prev_ratio,count,main_pid,start_time,[item | neighbors]} }
  end


end