defmodule Grid do
    def spawn_actors(num_nodes, main_pid) do
        grid_size = round(Float.ceil(:math.sqrt(num_nodes)))
        actors = 
            for x <- 1..grid_size, y <- 1..grid_size do
               {:ok, actor} = GossipActor.start_link({0,main_pid,System.monotonic_time(:millisecond),[]})
               actor
            end

    IO.inspect actors
    end
    
    def set_peers(actors, imperfect \\ false) do

    end
    
end