defmodule A2 do

  def buildTopology(topology, num_nodes) do
      case topology do
          line    -> 
            actors = Line.spawn_actors(num_nodes)
            Line.set_peers(:line, actors)
            actors
          
          impline -> 
            actors = Line.spawn_actors(num_nodes)
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


end
