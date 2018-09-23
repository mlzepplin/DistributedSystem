defmodule A2 do

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
    buildTopology(topology, pidList)

    #keep meetings happening
    for x <- 1..numMeetings do
      for pidIndex <- 1..numNodes do
          GossipActor.gossip(Enum.at(pidList,pidIndex))
      end
    end
  
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
      {ok_atoms, pidList} = Enum.map(Enum.to_list(1..numNodes),fn(x) -> (GossipActor.start_link({0,[]}))end) |> Enum.unzip
      pidList
  end

  def buildTopology(topology, pidList) do
      case topology do
          line -> Line.setPeers(pidList)
          _    -> IO.puts("not yet implemented")
      end
  end        


end
