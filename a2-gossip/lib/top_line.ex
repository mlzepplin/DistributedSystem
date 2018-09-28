defmodule Line do

    def spawn_actors(num_nodes, main_pid) do
    
      {ok, actors} = Enum.map(Enum.to_list(1..num_nodes), fn(x) -> create_worker(main_pid) end) |> Enum.unzip
      actors
    end

    #state holds count, main_pid, start_time, neighors
    def create_worker(main_pid) do
        GossipActor.start_link({0,main_pid,System.monotonic_time(:millisecond),[]})
    end

    def set_peers(actors, imperfect \\ false) do
    
        first = List.first(actors)
        last = List.last(actors)
        size = length(actors) 

        #first and last actors have just one neighbour
        GossipActor.add_peer(first, Enum.at(actors,1))
        GossipActor.add_peer(last, Enum.at(actors,size-2))

        #other actors have two neighbours
        for i <- 1..(size-2) do
            GossipActor.add_peers(Enum.at(actors,i), [Enum.at(actors,i+1), Enum.at(actors,i-1)])    
        end 

        if (imperfect == true) do    
            for i <- 0..(size-1) do
                #add a random neighbor
                GossipActor.add_peer(Enum.at(actors,i), Enum.random(actors)) 
            end           
        end

    end 

end