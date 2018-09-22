defmodule A2 do

  def gossip do
    
    {:ok, pid1} = Actor.start_link({0,[]})
    IO.inspect pid1
    {:ok, pid2} = Actor.start_link({0,[]})
    IO.inspect pid2
    {:ok, pid3} = Actor.start_link({0,[]})
    IO.inspect pid3
    {:ok, pid4} = Actor.start_link({0,[]})
    IO.inspect pid4

    Actor.push_pid(pid1,pid2)

    Actor.push_pid(pid2,pid3)
    Actor.push_pid(pid2,pid1)

    Actor.push_pid(pid3,pid4)
    Actor.push_pid(pid3,pid2)

    Actor.push_pid(pid4,pid3)
    top = Actor.gossip(pid1)
    IO.inspect top

  end
end
