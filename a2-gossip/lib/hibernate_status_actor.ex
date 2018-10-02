defmodule HibernateStatusActor do
    use GenServer
  
    # Client Side
    def start_link(default) do
      GenServer.start_link(__MODULE__, default)
    end
  
    def get_hibernate_status(pid)do
      status = GenServer.call(pid,:get_hibernate_status)
    end
  
    # Server Side (callbacks)
    def init(default) do
      {:ok, default}
    end

    def hibernate(pid) do
      GenServer.cast(pid,:hibernate)
    end
  
    #################### Handle_Call #####################
    # get hibernated
    def handle_call(:get_hibernate_status, _from, {numHibernated,numNodes}) do
        if numHibernated == numNodes do
            {:reply, true, {numHibernated,numNodes}}
        else
            {:reply, false, {numHibernated,numNodes}}
        end
    end

    #################### Handle_Casts #####################
    
    # hibernate
    def handle_cast(:hibernate, {numHibernated, numNodes}) do
      {:noreply, {numHibernated+1,numNodes} }  
    end

end 
    
  
  