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

  # # get_count
  # def handle_call(:get_ratio, _from, {s,w,round,main_pid,start_time,neighbors} ) do
  #   {:reply,div(s/w)}
  # end

  #################### Handle_Casts #####################
  
  # Push Sum
  def handle_cast({:push_sum,{recievedS,recievedW}}, {s,w,[head|rest],main_pid,start_time,neighbors}) do
    self = self()
    updatedS = div(recievedS + s,2);
    updatedW = div(recievedW + w,2);
    pair = {updatedS,updatedW}
    currentRatio = div(updatedS,updatedW)
    forwardTo = Enum.random(neighbors)
    if Enum.count(prevThreeVals)<3 do
      #compute ratio 
      #append it to prevThreeVals tail
      pushSum(forwardTo,pair)
      pushSum(self,pair)
      {:noreply,{updatedS,updatedW,[head|rest|currentRatio],_}}

    else
      #compute ratio
      #append it to prevThreeVals tail
      #check if the currentratio - first entry in prevThreeVals > 10^-10
        #if no --> terminate actor
        #else send relevent message to random neighbor and self
      if (currentRatio - head) < :math.pow(10,-10) do
        IO.inspect "limit reached"
        inform_main_of_hibernation(main_pid)
        timeToHibernation = System.monotonic_time(:millisecond) - start_time
        IO.inspect "time to hibernation : #{ timeToHibernation}"
        {:noreply,{_}}
      else
        pushSum(forwardTo,pair)
        pushSum(self,pair)
        #remove the head from state
        {:noreply,{updatedS,updatedW,[rest|currentRatio],_}}
      end
      
    end
    
  end

  # push
  def handle_cast({:push, item}, {count,main_pid,start_time,neighbors}) do
    {:noreply, {count,main_pid,start_time,[item | neighbors]} }
  end


end