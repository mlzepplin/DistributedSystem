defmodule Full do
    
    def spawn_actors(num_nodes, main_pid) do
      {ok, actors} = Enum.map(Enum.to_list(1..num_nodes),fn(x) -> (GossipActor.start_link({0,main_pid,System.monotonic_time(:millisecond),[]})) end) |> Enum.unzip
      actors
    end

     def set_peers(actors) do
        for actor <- actors do
            GossipActor.add_peers(actor, Enum.filter(actors, fn(x) -> x != actor end))
        end
     end
end