num_args = length(System.argv)
if (num_args != 3) do
    IO.puts "Invalid arguments \n args: num_nodes topology algorithm"
    exit(:shutdown)
end

#take commandline inputs
num_nodes = String.to_integer(List.first(System.argv))
topology = Enum.at(System.argv,1)
algorithm = List.last(System.argv)

main_pid = A2.start_up(num_nodes, topology, algorithm)
IO.puts "started main"

case algorithm  do
   "gossip"  -> 
       f = A2.gossip(main_pid)
       IO.inspect f
       A2.do_work(main_pid)
   "pushsum" ->
        A2.pushSum(main_pid)
      _        -> 
        IO.puts "Invalid input. Enter gossip or pushsum"
end


