defmodule A2 do

  def push(l,item) do
    [item|l]
  end

  def gossip do
    
    n=4
  
    {ok_atoms, pidList} = Enum.map(Enum.to_list(1..n),fn(x) -> (Actor.start_link({0,[]}))end) |> Enum.unzip 
    IO.inspect pidList

   
    # Actor.push_pid(pidList[0],pidList[1])

    # Actor.push_pid(pidList[1],pidList[2])
    # Actor.push_pid(pidList[1],pidList[0])

    # Actor.push_pid(pidList[2],pidList[3])
    # Actor.push_pid(pidList[2],pidList[1])

    # Actor.push_pid(pidList[3],pidList[2])
    # top = Actor.gossip(pidList[0])
    # IO.inspect top

    # for x <- 1..20 do
    #   modList = Enum.to_list 1..n_max |> Enum.take_every(workUnitSize)
    
    #     result = modList
    #     |> Enum.map(&Task.Supervisor.async_nolink(pid,fn -> Dos1.worker(&1,k,workUnitSize, n_max) end))
    # end    


  end
end
