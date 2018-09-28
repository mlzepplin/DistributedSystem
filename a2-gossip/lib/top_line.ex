defmodule Line do

    def spawn_actors(num_nodes, main_pid, algorithm) do
        case algorithm do
            "gossip" ->
                {ok, actors} = Enum.map(Enum.to_list(1..num_nodes), fn(x) -> create_gossip_worker(main_pid) end) |> Enum.unzip
                actors
            "pushsum" ->
                {ok, actors} = Enum.map(Enum.to_list(1..num_nodes), fn(x) -> create_pushsum_worker(main_pid, x) end) |> Enum.unzip
                actors
        end
        
    end

    #state holds count, main_pid, start_time, neighbors_list
    def create_gossip_worker(main_pid) do
        GossipActor.start_link({0,main_pid,System.monotonic_time(:millisecond),[]})
    end

    #state holds initial s,w values, s/w ratio differences, main_pid, strt_time,neighbors_list
    def create_pushsum_worker(main_pid, s) do
        PushSumActor.start_link({s,1,false,s,0,main_pid,System.monotonic_time(:millisecond),[]})
    end

    def set_peers(actors, algorithm, imperfect \\ false) do
    
        first = List.first(actors)
        last = List.last(actors)
        size = length(actors) 

        case algorithm do
        "gossip" ->
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
        
        "pushsum" ->
            PushSumActor.add_peer(first, Enum.at(actors,1))
            PushSumActor.add_peer(last, Enum.at(actors,size-2))

            #other actors have two neighbours
            for i <- 1..(size-2) do
                PushSumActor.add_peers(Enum.at(actors,i), [Enum.at(actors,i+1), Enum.at(actors,i-1)])    
            end 

            if (imperfect == true) do    
                for i <- 0..(size-1) do
                    #add a random neighbor
                    PushSumActor.add_peer(Enum.at(actors,i), Enum.random(actors)) 
                end           
            end
        end

    end 

end