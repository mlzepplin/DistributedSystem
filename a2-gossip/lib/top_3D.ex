defmodule ThreeDimGrid do
    def spawn_actors(num_nodes, main_pid) do
        grid_size = round(Float.ceil(:math.pow(num_nodes, 1/3)))
        actors = 
            for x <- 0..(grid_size-1), y <- 0..(grid_size-1), z <- 0..(grid_size-1) do
               {:ok, actor} = create_worker(main_pid)
            end

        Enum

    IO.inspect actors
    end

    #state holds count, main_pid, start_time, neighors
    def create_worker(main_pid) do
        GossipActor.start_link({0,main_pid,System.monotonic_time(:millisecond),[]})
    end

    def set_peers(actors) do
        #TODO
    end
end