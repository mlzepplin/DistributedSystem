defmodule PushSumActor do
  use GenServer

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

  def pushSum(pid,swPair) do
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
  
  # pop
  # def handle_call(:pop, _from, {s,w,round,main_pid,start_time,[head | tail]}) do
  #   {:reply, head, start_time,{count,tail}}
  # end

  # get_count
  def handle_call(:get_ratio, _from, {s,w,prev_ratio,count,main_pid,start_time,neighbors} ) do
    {:reply,s/w}
  end

  #################### Handle_Casts #####################
  
  # Push Sum
  def handle_cast({:push_sum,{recievedS,recievedW}}, {s,w,hibernated,prev_ratio,count,main_pid,start_time,neighbors}) do
    self = self()
    updatedS = (recievedS + s)/2;
    updatedW = (recievedW + w)/2;
    pair = {updatedS,updatedW}
    currentRatio = updatedS/updatedW
    forwardTo = Enum.random(neighbors)
    if hibernated do
      {:noreply, {updatedS,updatedW,hibernated,currentRatio,count,main_pid,start_time,neighbors}}
    else 
    
      if (abs(currentRatio - prev_ratio) < :math.pow(10,-10)) do
      
        if count==2 do
          IO.inspect "limit reached"
          inform_main_of_hibernation(main_pid)
          timeToHibernation = System.monotonic_time(:millisecond) - start_time
          IO.inspect "time to hibernation : #{ timeToHibernation}"
          {:noreply, {updatedS,updatedW,true,currentRatio,count+1,main_pid,start_time,neighbors}}
        else
          pushSum(forwardTo,pair)
          pushSum(self,pair)
          {:noreply, {updatedS,updatedW,hibernated,currentRatio,count+1,main_pid,start_time,neighbors}}
        end
      
      else 
        pushSum(forwardTo,pair)
        pushSum(self,pair)
        {:noreply, {updatedS,updatedW,hibernated,currentRatio,0,main_pid,start_time,neighbors}}
      end
    
    end
  
    
  end

  # push
  def handle_cast({:push, item}, {s,w,prev_ratio,count,main_pid,start_time,neighbors}) do
    {:noreply, {s,w,prev_ratio,count,main_pid,start_time,[item | neighbors]} }
  end


end