defmodule Grid do
    def spawn_actors(num_nodes, main_pid, algorithm) do
        grid_rows = round(:math.ceil(:math.sqrt(num_nodes)))
        range = 1..grid_rows

        actors_map = Enum.reduce(range, %{}, fn(y,acc_out) -> (
            row_map = Enum.reduce(range, %{}, fn(x,acc_in) -> (
                case algorithm do
                    "gossip" ->
                        {:ok, pid} = create_gossip_worker(main_pid)
                        Map.put(acc_in, x, pid)
                    "pushsum" ->
                        {:ok,pid} = create_pushsum_worker(main_pid)
                        Map.put(acc_in, x, pid)
                end
            ) end)
            Map.put(acc_out, y, row_map)
            ) 
            end
            
        )

        IO.inspect actors_map
        actors_map
    
    end

    def create_gossip_worker(main_pid) do
        GossipActor.start_link({0,main_pid,System.monotonic_time(:millisecond),[]})
    end

    def create_pushsum_worker(main_pid) do
        GossipActor.start_link({0,main_pid,System.monotonic_time(:millisecond),[]})
    end
    
    def set_peers(actors, imperfect \\ false) do
        IO.puts "TODO Add peers"
    end
    
end