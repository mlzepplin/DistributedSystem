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

    def set_peers(actors_map,algorithm) do
        #TODO
    end
end