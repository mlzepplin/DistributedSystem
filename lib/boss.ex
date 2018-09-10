defmodule Dos1.Boss do
    def fireSupervisor(n,k) do
        {:ok, pid} = Task.Supervisor.start_link(strategy: :one_for_one)
        result = Enum.to_list 1..n
        |> Stream.map(&Task.Supervisor.async_nolink(pid,fn -> Dos1.isPerfectSquare(fn -> Dos1.sumOfSquares(&1,k) end) end))
        |> Enum.map(&Task.await(&1)) 
        |> Enum.filter(fn x->x != 0 end)
       Enum.each(result, fn x->IO.inspect x end) 
       
    end
end