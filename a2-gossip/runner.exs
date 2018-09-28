num_args = length(System.argv)
if (num_args != 3) do
    IO.puts "Invalid arguments \n args: num_nodes topology algorithm"
    exit(:shutdown)
end

#take commandline inputs
num_nodes = String.to_integer(List.first(System.argv))
topology = Enum.at(System.argv,1)
algorithm = List.last(System.argv)

mainPid = A2.start_up(num_nodes, topology, algorithm)
IO.puts "started main"
case algorithm  do
   "gossip"  -> A2.gossip(mainPid)
   "pushsum" -> A2.pushSum(mainPid)
   _         -> IO.puts "Invalid input. Enter gossip or pushsum"
end


