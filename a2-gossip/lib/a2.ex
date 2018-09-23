defmodule A2 do

  use GenServer

  def set_neighbors(pidList) do
    for x <- 0..Enum.count(pidList) do
      A2.push_pid(Enum.at(pidList,x))
    end
  end

  def gossip(numNodes, topology) do
  
    numMeetings = 10000
  
    #spawn actors
    
    # # PLACE TO SETUP THE TOPOLOGY
    # # call will be like.. A2.buildTopology(pidList,topology)
    # GossipActor.push_pid(Enum.at(pidList,0),Enum.at(pidList,1))

    # GossipActor.push_pid(Enum.at(pidList,1),Enum.at(pidList,2))
    # GossipActor.push_pid(Enum.at(pidList,1),Enum.at(pidList,0))

    # GossipActor.push_pid(Enum.at(pidList,2),Enum.at(pidList,3))
    # GossipActor.push_pid(Enum.at(pidList,2),Enum.at(pidList,1))

    # GossipActor.push_pid(Enum.at(pidList,3),Enum.at(pidList,2))
    # top = GossipActor.gossip(Enum.at(pidList,0))
    # IO.inspect top

    pidList = spawnActors(numNodes)
    set_neighbors(pidList)
    buildTopology(topology, pidList)

    GossipActor.gossip(Enum.at(pidList,0))

    #keep meetings happening
    # for x <- 1..numMeetings do
    #   for pidIndex <- 1..numNodes do
    #       GossipActor.gossip(Enum.at(pidList,pidIndex))
    #   end
    # end
  
  end


  def pushSum(numNodes, topology) do
    numMeetings = 10000
   
    pidList = spawnActors(numNodes)
    buildTopology(numNodes, topology)
    
    #keep meetings happening
    for x <- 1..numMeetings do
      for pidIndex <- 1..numNodes do
          PushSumActor.gossip(Enum.at(pidList,pidIndex))
      end
    end
  end

  def spawnActors(numNodes) do
      self = self()
      {ok_atoms, pidList} = Enum.map(Enum.to_list(1..numNodes),fn(x) -> (GossipActor.start_link({0,self,System.monotonic_time(:millisecond),[]}))end) |> Enum.unzip
      pidList
  end

  def buildTopology(topology, pidList) do
      case topology do
          line -> Line.setPeers(pidList)
          _    -> IO.puts("not yet implemented")
      end
  end        

  # Client Side
  def start_link(default) do
    GenServer.start_link(__MODULE__, default)
  end

  def get_numHibernated(pid)do
    numHibernated = GenServer.call(pid,:get_numHibernated)
  end

  def push_pid(pid, item) do
      Genserver.cast(pid, {:push, item})
  end

 
  def push_sum(pid) do
      GenServer.cast(pid, :push_sum)
  end

  # Server Side (callbacks)
  def init(default) do
    {:ok, default}
  end

  ################ Hanlde_Calls ########################

  # pop
  def handle_call(:pop, _from, {numHibernated,[head | tail]}) do
    {:reply, head, {numHibernated,tail}}
  end

  # numHibernated 
  def handle_call(:get_numHibernated, _from, {numHibernated,neighbors} ) do
    {:reply,numHibernated, {numHibernated,neighbors}}
  end


  ################ Handle_casts ##########################

  # push 
  def handle_cast({:push, item}, {numHibernated,neighbors}) do
    {:noreply, {numHibernated,[item | neighbors]} }
  end

  # hibernate
  def handle_cast(:hibernate, {numHibernated,neighbors}) do
      current = self()
      if (numHibernated + 1 == Enum.count(neighbors)) do 
        IO.inspect "all Hibernated !!!"
      end
      {:noreply, {numHibernated+1,neighbors} }
  end



end
