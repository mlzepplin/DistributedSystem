defmodule A2 do
    use GenServer

  def setNeighbors(pid,pidList) do
    for x <- 0..Enum.count(pidList)-1 do
      A2.add_peer(pid,Enum.at(pidList,x))
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

  def start_up(num_nodes, topology) do
    #build topology
    actors = buildTopology(topology, num_nodes)
    #spin up the main actor
    {status,mainActor} = A2.start_link({0,[]})
    #put all other actors in its mailbox 
    setNeighbors(mainActor,actors)
    mainActor
  end

  def gossip(pid) do    
    GenServer.cast(pid, :gossip)
  end


  def pushSum(pid) do
    A2.cast(pid,:push_sum)
  end 



  # Client Side
  def start_link(default) do
    GenServer.start_link(__MODULE__, default)
  end

  def get_numHibernated(pid)do
    numHibernated = GenServer.call(pid,:get_numHibernated)
  end

  def add_peer(pid, item) do
      GenServer.cast(pid, {:push, item})
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
      IO.inspect "#{numHibernated} ==> hibernated uptill now"
      if (numHibernated + 1 == Enum.count(neighbors)) do 
        IO.inspect "all Hibernated !!!"
      end
      {:noreply, {numHibernated+1,neighbors} }
  end      

  # gossip
  def handle_cast(:gossip, {numHibernated,neighbors}) do
    #choose neighbor at random and start gossiping
    forwardTo = Enum.random(neighbors)
    GossipActor.gossip(forwardTo)
    {:noreply, {numHibernated,neighbors} }
  end

  # push sum
  def handle_cast(:push_sum, {numHibernated,neighbors}) do
    #choose neighbor at random and start gossiping
    forwardTo = Enum.random(neighbors)
    PushSumActor.pushSum(forwardTo)
    {:noreply, {numHibernated,neighbors} }
  end

end
