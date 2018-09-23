defmodule Line do
    def setPeers(pidList) do

        first = List.first(pidList)
        last = List.last(pidList)
        size = length(pidList) 

        #first and last actors have just one neighbour
        GossipActor.push_pid(first,Enum.at(pidList,1))
        GossipActor.push_pid(last, Enum.at(pidList,size-2))
   
        #other actors have two neighbours
        for i <- 1..(length(pidList)-2) do
            GossipActor.push_pid(Enum.at(pidList,i),Enum.at(pidList,i+1))
            GossipActor.push_pid(Enum.at(pidList,i),Enum.at(pidList,i-1))
        end   
    end 
end