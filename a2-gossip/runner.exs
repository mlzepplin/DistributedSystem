#take commandline inputs
numNodes = String.to_integer(List.first(System.argv))
topology = Enum.at(System.argv,1)
algorithm = List.last(System.argv)

if algorithm == "gossip" do
    A2.gossip(numNodes, topology)
else
    A2.pushSum(numNodes, topology)
end


