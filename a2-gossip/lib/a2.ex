defmodule A2 do

  def gossip do
    
    {:ok, pid1} = Actor.start_link([])
    {:ok, pid2} = Actor.start_link([])
    {:ok, pid3} = Actor.start_link([])
    {:ok, pid4} = Actor.start_link([])

    Actor.push_pid(pid1,pid2)
    Actor.push_pid(pid2,pid3)
    Actor.push_pid(pid3,pid4)

    top = Actor.gossip(pid1)
    IO.inspect top



  end
end
