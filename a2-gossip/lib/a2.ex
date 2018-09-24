defmodule A2 do
    use GenServer

  def set_neighbors(pidList) do
    for x <- 0..Enum.count(pidList) do
      A2.push_pid(Enum.at(pidList,x))
    end
  end

  def buildTopology(topology, num_nodes) do
  
      case topology do
          line    -> 
            actors = Line.spawn_actors(num_nodes, self())
            Line.set_peers(:line, actors)
            actors
          
          impline -> 
            actors = Line.spawn_actors(num_nodes, self())
            Line.set_peers(:line, actors, true)
         
          grid    -> 
            actors = Grid.spawn_actors(num_nodes)
            Grid.set_peers(:grid, actors)

          _    -> IO.puts("not yet implemented")
      end
  end 

  def gossip(num_nodes, topology) do
  
    numMeetings = 10000
    
    actors = buildTopology(topology, num_nodes)
    
    #keep meetings happening
    for x <- 1..numMeetings do
      for pidIndex <- 1..num_nodes do
          GossipActor.gossip(Enum.at(actors,pidIndex))
      end
    end
  
  end


  def pushSum(num_nodes, topology) do
    numMeetings = 10000
   
    
    actors = buildTopology(num_nodes, topology)
    
    #keep meetings happening
    for x <- 1..numMeetings do
      for pidIndex <- 1..num_nodes do
          PushSumActor.pushsum(Enum.at(actors,pidIndex))
      end
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
