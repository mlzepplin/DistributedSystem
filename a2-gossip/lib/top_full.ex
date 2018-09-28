defmodule Full do
    
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
        PushSumActor.start_link({s,1,[],main_pid,System.monotonic_time(:millisecond),[]})
    end

    def set_peers(actors, algorithm) do
        case algorithm do
            "gossip" ->
                for actor <- actors do
                    GossipActor.add_peers(actor, Enum.filter(actors, fn(x) -> x != actor end))
                end
            
            "pushsum" ->
                for actor <- actors do
                    PushSumActor.add_peers(actor, Enum.filter(actors, fn(x) -> x != actor end))
                end
        end
    end
end