num_args = length(System.argv)
if (num_args != 3) do
    IO.puts "Invalid arguments \n args: num_nodes topology algorithm"
    exit(:shutdown)
end

#take commandline inputs
num_nodes = String.to_integer(List.first(System.argv))
topology = Enum.at(System.argv,1)
algorithm = List.last(System.argv)
{st,hibernate_actor_pid} = HibernateStatusActor.start_link({0,num_nodes})
main_pid = A2.start_up(hibernate_actor_pid,num_nodes, topology, algorithm)

IO.puts "started main and hubernate_actor"

case algorithm  do
   "gossip"  -> 
       f = A2.gossip(main_pid)
       IO.inspect f
       # hibernate actor to keep track of number of hibernated workers
       A2.do_work(hibernate_actor_pid)
   "pushsum" ->
        IO.inspect main_pid
        A2.push_sum(main_pid)
      _        -> 
        IO.puts "Invalid input. Enter gossip or pushsum"
end


