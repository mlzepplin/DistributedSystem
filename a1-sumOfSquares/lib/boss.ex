defmodule Dos1.Boss do
   # use Application

    def fireSupervisor(n_max,k) do
        {:ok, pid} = Task.Supervisor.start_link(strategy: :one_for_one)
        numActors = 100 #Identify optimal no of actors
        workUnitSize = div(n_max, numActors) + 1
        modList = Enum.to_list 1..n_max |> Enum.take_every(workUnitSize)
    
        result = modList
        |> Enum.map(&Task.Supervisor.async_nolink(pid,fn -> Dos1.worker(&1,k,workUnitSize, n_max) end))
        |> Enum.map(&Task.await(&1, 200000)) 
        
       
    end
end