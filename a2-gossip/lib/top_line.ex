defmodule Line do

    def spawn_actors(num_nodes, main_pid) do
    
      {ok, actors} = Enum.map(Enum.to_list(1..num_nodes),fn(x) -> (GossipActor.start_link({0,main_pid,System.monotonic_time(:millisecond),[]})) end) |> Enum.unzip
      actors
    end

    def set_peers(actors, imperfect \\ false) do
    
        first = List.first(actors)
        last = List.last(actors)
        size = length(actors) 

        case imperfect do
        
        #perfect line
        false ->
            #first and last actors have just one neighbour
            GossipActor.add_peer(first, Enum.at(actors,1))
            GossipActor.add_peer(last, Enum.at(actors,size-2))
    
            #other actors have two neighbours
            for i <- 1..(length(actors)-2) do
                GossipActor.add_peer(Enum.at(actors,i), Enum.at(actors,i+1))
                GossipActor.add_peer(Enum.at(actors,i), Enum.at(actors,i-1))
            end  

        #imperfect line
        true ->
            GossipActor.add_peer(first, Enum.at(actors,1))
            GossipActor.add_peer(first, Enum.random(actors))
            GossipActor.add_peer(last, Enum.at(actors,size-2))
            GossipActor.add_peer(last, Enum.random(actors))

             for i <- 1..(length(actors)-2) do
                GossipActor.add_peer(Enum.at(actors,i), Enum.at(actors,i+1))
                GossipActor.add_peer(Enum.at(actors,i), Enum.at(actors,i-1))
                GossipActor.add_peer(Enum.at(actors,i), Enum.random(actors))
            end 

        end


    end 

end