defmodule Torus do
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
                        {:ok,pid} = create_pushsum_worker(main_pid, (y-1)*grid_rows + x) 
                        Map.put(acc_in, x, pid)
                end
            ) end)
            Map.put(acc_out, y, row_map)
            ) 
            end
            
        )
    end

    #state holds count, main_pid, start_time, neighors
    def create_gossip_worker(main_pid) do
        GossipActor.start_link({0,main_pid,System.monotonic_time(:millisecond),[]})
    end

    #state holds initial s,w values, s/w ratio differences, main_pid, strt_time,neighbors_list
    def create_pushsum_worker(main_pid, s) do
        PushSumActor.start_link({s,1,false,s,0,main_pid,System.monotonic_time(:millisecond),[]})
    end

    def set_peers(num_nodes, actors_map, algorithm) do
        n = round(:math.ceil(:math.sqrt(num_nodes)))

        Enum.each(actors_map, fn({r,row_map}) -> (
            Enum.each(row_map, fn({c,actor}) -> (
                neighbors = cond do
                    r == 1 ->
                        cond do
                            c==1 ->
                                [actors_map[r][c+1]] ++ [actors_map[r+1][c]] ++ [actors_map[1][n]] ++ [actors_map[n][1]]
                            c==n ->
                                [actors_map[r+1][c]] ++ [actors_map[r][c-1]] ++ [actors_map[1][1]] ++ [actors_map[n][n]]
                            c>1 && c<n ->
                                [actors_map[r][c-1]] ++ [actors_map[r][c+1]] ++ [actors_map[r+1][c]] ++ [actors_map[n][c]]

                        end
                    
                    r == n ->
                        cond do
                            c==1 ->
                                [actors_map[r-1][c]] ++ [actors_map[r][c+1]] ++ [actors_map[1][1]] ++ [actors_map[n][n]]
                            c==n ->
                                [actors_map[r-1][c]] ++ [actors_map[r][c-1]] ++ [actors_map[n][1]] ++ [actors_map[1][n]]
                            c>1 && c<n ->
                                [actors_map[r][c-1]] ++ [actors_map[r][c+1]] ++ [actors_map[r-1][c]] ++ [actors_map[1][c]]
                        end

                    r>1 && r<n ->
                        cond do 
                            c==1 ->
                                [actors_map[r-1][c]] ++ [actors_map[r+1][c]] ++ [actors_map[r][c+1]] ++ [actors_map[r][n]]
                            c==n ->
                                [actors_map[r-1][c]] ++ [actors_map[r][c-1]] ++ [actors_map[r+1][c]] ++ [actors_map[r][1]]
                            c>1 && c<n ->
                                [actors_map[r-1][c]] ++ [actors_map[r+1][c]] ++ [actors_map[r][c-1]] ++ [actors_map[r][c+1]]
                        end

                    end

                    case algorithm do
                    "gossip" -> 
                        GossipActor.add_peers(actor, neighbors)
                    "pushsum" ->
                        PushSumActor.add_peers(actor, neighbors)
                    end
            )end)
        )end)

    end
end