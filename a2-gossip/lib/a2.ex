defmodule A2 do
  use GenServer

  def setNeighbors(pid,pidList) do
    for x <- 0..Enum.count(pidList)-1 do
      A2.add_peer(pid,Enum.at(pidList,x))
    end
  end
  
  # def do_work(pid) do
  #     A2.gossipStep(pid)
  #     do_work(pid)
  # end

  def gossipStep(pid) do
      GenServer.cast(pid,:gossip_step)
  end

  def pushSumStep(pid) do
      GenServer.cast(pid,:push_sum_step)
  end


  def buildTopology(hibernate_actor_pid,topology, num_nodes, algorithm) do
    #main_pid = self()
    case topology do
    "line"    -> 
      actors = Line.spawn_actors(num_nodes, hibernate_actor_pid, algorithm)
      Line.set_peers(actors, algorithm)
      actors
          
    "impline" -> 
      actors = Line.spawn_actors(num_nodes, hibernate_actor_pid, algorithm)
      Line.set_peers(actors, algorithm, true)
      actors
         
    "full"    ->
      actors = Full.spawn_actors(num_nodes, hibernate_actor_pid, algorithm)
      Full.set_peers(actors, algorithm)
      actors

    "grid"    -> 
      actors_map = Grid.spawn_actors(num_nodes, hibernate_actor_pid, algorithm)
      Grid.set_peers(num_nodes, actors_map, algorithm)
      actors = get_list_of_actors_2d(actors_map)

    #Torus. Similar to a 2D grid, joined at the edges
    "sphere"  ->
      actors_map = Torus.spawn_actors(num_nodes, hibernate_actor_pid, algorithm)
      Torus.set_peers(num_nodes, actors_map, algorithm)
      actors = get_list_of_actors_2d(actors_map)

    "3D"      ->
      actors_map = ThreeDimGrid.spawn_actors(num_nodes, hibernate_actor_pid, algorithm)
      ThreeDimGrid.set_peers(actors_map, algorithm)
      actors = get_list_of_actors_3d(actors_map)

        

        _  -> IO.puts("not yet implemented")
      end
  end 

  def get_list_of_actors_2d(actors_map) do
 
    actors_list = Enum.reduce(Map.values(actors_map), [], fn(x, acc) -> (
      acc ++ Map.values(x) 
      )end
    )
  end

  def get_list_of_actors_3d(actors_map) do

    map_3d_values = Map.values(actors_map)
    actors_list = Enum.reduce(map_3d_values, [], fn(map_2d, acc) -> (
     acc ++ get_list_of_actors_2d(map_2d) 
    )end)

  end

  def start_up(hibernate_actor_pid,num_nodes, topology, algorithm) do
    #build topology
    actors = buildTopology(hibernate_actor_pid,topology, num_nodes, algorithm)
    IO.inspect actors

    #spin up the main actor
    {status,mainActor} = A2.start_link({0,[]})

    #put all other actors in its mailbox 
    setNeighbors(mainActor,actors)
    mainActor
  end

  def gossip(pid) do    
    GenServer.cast(pid, :gossip)
  end

  def push_sum(pid) do
    GenServer.cast(pid, :push_sum)
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

  def hibernate(pid) do
    GenServer.cast(pid, :hibernate)
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

  def do_work(pid) do
   hibernationStatus = HibernateStatusActor.get_hibernate_status(pid)
   if hibernationStatus == false do
    do_work(pid)
   else
    IO.inspect "########################## DONE #############################"
   end
  end
  

  ################ Handle_casts ##########################

  # push 
  def handle_cast({:push, item}, {numHibernated,neighbors}) do
    {:noreply, {numHibernated,[item | neighbors]} }
  end

  # hibernate
  def handle_cast(:hibernate, {numHibernated,neighbors}) do
      IO.inspect "hibernated!!"
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
    PushSumActor.push_sum(forwardTo,{0,0})
    {:noreply, {numHibernated,neighbors} }
  end

  # step gossip
  def handle_cast(:gossip_step, {numHibernated,neighbors}) do 
    for x <-0..Enum.count(neighbors)-1 do
        GenServer.cast(Enum.at(neighbors,x),:step)
    end
    {:noreply, {numHibernated,neighbors} }
  end

  # step push sum
  def handle_cast(:push_sum_step, {numHibernated,neighbors}) do 
    for x <-0..Enum.count(neighbors)-1 do
        GenServer.cast(Enum.at(neighbors,x),:step)
    end
    {:noreply, {numHibernated,neighbors} }
  end



end
