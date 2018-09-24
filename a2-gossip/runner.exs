#take commandline inputs
numNodes = String.to_integer(List.first(System.argv))
topology = Enum.at(System.argv,1)
algorithm = List.last(System.argv)
mainPid = A2.start_up(numNodes, topology)
if algorithm == "gossip" do
    f = A2.gossip(mainPid)
    IO.inspect f
else
    A2.pushSum(mainPid)
end


