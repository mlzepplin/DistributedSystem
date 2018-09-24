#take commandline inputs
num_nodes = String.to_integer(List.first(System.argv))
topology = Enum.at(System.argv,1)
algorithm = List.last(System.argv)

mainPid = A2.start_up(num_nodes, topology)

case algorithm  do
   "gossip"  -> A2.gossip(mainPid)
   "pushsum" -> A2.pushSum(mainPid)
   _         -> IO.puts "Invalid input. Enter gossip or pushsum"
end


