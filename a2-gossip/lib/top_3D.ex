defmodule ThreeDimGrid do
    def spawn_actors(num_nodes, main_pid, algorithm) do
        n = round(Float.ceil(:math.pow(num_nodes, 1/3)))
        range =1..n

        
        actors_map = Enum.reduce(range, %{}, fn(z,acc_z) -> (
            yx_map = Enum.reduce(range, %{}, fn(y,acc_y) -> (
                x_map = Enum.reduce(range, %{}, fn(x,acc_x) ->(
                    case algorithm do
                    "gossip" ->
                        {:ok, pid} = create_gossip_worker(main_pid)
                         Map.put(acc_x, x, pid)
                    "pushsum" ->
                        #Explore other start values for pushsum
                        {:ok,pid} = create_pushsum_worker(main_pid,(z-1)*n*n + (y-1)*n + x)
                        Map.put(acc_x, x, pid)
                    end

                )end)
                Map.put(acc_y, y, x_map)
            )end)
            Map.put(acc_z, z, yx_map)
        )end)


    #IO.inspect actors_map
    end

    #state holds count, main_pid, start_time, neighors
    def create_gossip_worker(main_pid) do
        GossipActor.start_link({0,main_pid,System.monotonic_time(:millisecond),[]})
    end

    #state holds initial s,w values, s/w ratio differences, main_pid, strt_time,neighbors_list
    def create_pushsum_worker(main_pid, s) do
        PushSumActor.start_link({s,1,false,s,0,main_pid,System.monotonic_time(:millisecond),[]})
    end

    def set_peers(num_nodes, actors_map,algorithm) do
        n = round(Float.ceil(:math.pow(num_nodes, 1/3)))

        Enum.each(actors_map, fn({x,twoD_map}) -> (
            Enum.each(twoD_map, fn({y,oneD_map}) -> (
                Enum.each(oneD_map, fn({z,actor}) -> (

                    neighbors = cond do
                        x == 1 ->
                            cond do
                                y == 1 ->
                                    cond do
                                        z==1 ->
                                            [actors_map[x][1][2]] ++ [actors_map[x][2][1]] ++ [actors_map[x+1][1][1]]
                                        z==n ->
                                            [actors_map[x+1][1][n]] ++ [actors_map[x][1][n-1]] ++ [actors_map[x][y+1][n]]
                                        z>1 && z<n ->
                                            [actors_map[x+1][y][z]] ++ [actors_map[x][y][z+1]] ++ [actors_map[x][y][z-1]] ++ [actors_map[x][y+1][z]]
                                    end

                                y == n ->
                                    cond do
                                        z==1 ->
                                            [actors_map[x+1][y][z]] ++ [actors_map[x][y][z+1]] ++ [actors_map[x][y-1][z]]
                                        z==n ->
                                            [actors_map[x][y-1][z]] ++ [actors_map[x][y][z-1]] ++ [actors_map[x+1][n][n]]
                                        z>1 && z<n ->
                                            [actors_map[x][y][z-1]] ++ [actors_map[x][y][z+1]] ++ [actors_map[x][y-1][z]] ++ [actors_map[x+1][y][z]]
                                    end

                                y>1 && y<n ->
                                    cond do
                                        z==1 ->
                                            [actors_map[x][y-1][z]] ++ [actors_map[x][y+1][z]] ++ [actors_map[x][y][z+1]] ++ [actors_map[x+1][y][z]]
                                        z==n ->
                                            [actors_map[x][y][z-1]] ++ [actors_map[x][y-1][z]] ++ [actors_map[x][y+1][z]] ++ [actors_map[x+1][y][z]]
                                        z>1 && z<n ->
                                            [actors_map[x][y-1][z]] ++ [actors_map[x][y+1][z]] ++ [actors_map[x][y][z-1]] ++ [actors_map[x][y][z+1]] ++ [actors_map[x+1][y][z]]
                                    end
                            end
                        

                        x == n ->
                            cond do
                                y == 1 ->
                                    cond do
                                        z==1 ->
                                            [actors_map[x][1][2]] ++ [actors_map[x][2][1]] ++ [actors_map[x-1][1][1]]
                                        z==n ->
                                            [actors_map[x-1][1][n]] ++ [actors_map[x][1][n-1]] ++ [actors_map[x][y+1][n]]
                                        z>1 && z<n ->
                                            [actors_map[x-1][y][z]] ++ [actors_map[x][y][z+1]] ++ [actors_map[x][y][z-1]] ++ [actors_map[x][y+1][z]]
                                    end

                                y == n ->
                                    cond do 
                                        z==1 ->
                                            [actors_map[x-1][y][z]] ++ [actors_map[x][y][z+1]] ++ [actors_map[x][y-1][z]]
                                        z==n ->
                                            [actors_map[x][y-1][z]] ++ [actors_map[x][y][z-1]] ++ [actors_map[x-1][n][n]]
                                        z>1 && z<n ->
                                            [actors_map[x][y][z-1]] ++ [actors_map[x][y][z+1]] ++ [actors_map[x][y-1][z]] ++ [actors_map[x-1][y][z]]
                                    end

                                y>1 && y<n ->
                                    cond do
                                        z==1 ->
                                            [actors_map[x][y-1][z]] ++ [actors_map[x][y+1][z]] ++ [actors_map[x][y][z+1]] ++ [actors_map[x-1][y][z]]
                                        z==n ->
                                            [actors_map[x][y][z-1]] ++ [actors_map[x][y-1][z]] ++ [actors_map[x][y+1][z]] ++ [actors_map[x-1][y][z]]
                                        z>1 && z<n ->
                                            [actors_map[x][y-1][z]] ++ [actors_map[x][y+1][z]] ++ [actors_map[x][y][z-1]] ++ [actors_map[x][y][z+1]] ++ [actors_map[x-1][y][z]]
                                    end
                            end

                        x>1 && x<n ->
                            cond do
                                y == 1 ->
                                    cond do
                                        z==1 ->
                                            [actors_map[x+1][y][z]] ++ [actors_map[x-1][y][z]] ++ [actors_map[x][y+1][z]] ++ [actors_map[x][y][z+1]]
                                        z==n ->
                                            [actors_map[x+1][y][z]] ++ [actors_map[x-1][y][z]] ++ [actors_map[x][y+1][z]] ++ [actors_map[x][y][z-1]]
                                        z>1 && z<n ->
                                            [actors_map[x+1][y][z]] ++ [actors_map[x-1][y][z]] ++ [actors_map[x][y][z-1]] ++ [actors_map[x][y][z+1]] ++ [actors_map[x][y][z-1]] ++ [actors_map[x][y+1][z]]
                                    end

                                y == n ->
                                    cond do
                                        z==1 ->
                                            [actors_map[x+1][y][z]] ++ [actors_map[x-1][y][z]] ++ [actors_map[x][y-1][z]] ++ [actors_map[x][y][z+1]]
                                        z==n ->
                                            [actors_map[x+1][y][z]] ++ [actors_map[x-1][y][z]] ++ [actors_map[x][y-1][z]] ++ [actors_map[x][y][z-1]]
                                        z>1 && z<n ->
                                            [actors_map[x+1][y][z]] ++ [actors_map[x-1][y][z]] ++ [actors_map[x][y][z-1]] ++ [actors_map[x][y][z+1]] ++ [actors_map[x][y][z-1]] ++ [actors_map[x][y-1][z]]
                                    end

                                y>1 && y<n ->
                                    cond do
                                        z==1 ->
                                            [actors_map[x+1][y][z]] ++ [actors_map[x-1][y][z]] ++ [actors_map[x][y-1][z]] ++ [actors_map[x][y+1][z]] ++ [actors_map[x][y][z+1]]
                                        z==n ->
                                            [actors_map[x+1][y][z]] ++ [actors_map[x-1][y][z]] ++ [actors_map[x][y-1][z]] ++ [actors_map[x][y+1][z]] ++ [actors_map[x][y][z-1]]
                                        z>1 && z<n ->
                                            [actors_map[x+1][y][z]] ++ [actors_map[x-1][y][z]] ++ [actors_map[x][y-1][z]] ++ [actors_map[x][y+1][z]] ++ [actors_map[x][y][z-1]] ++ [actors_map[x][y][z+1]]
                                    end
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
        )end)







    end
end