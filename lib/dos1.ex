defmodule Dos1 do
  
  def isPerfectSquare(callback) do
    {sum,startNum} = callback.();
    root = round(:math.sqrt(sum))
    if sum==root*root do
      startNum
    else
      0
    end

  end

  def sumOfSquares(n,k) do
    sum = div((n+k-1)*(n+k)*(2*n+2*k-1) - (n-1)*(n)*(2*n-1),6) #sum of squares for n
    {sum,n}
  end

  def worker(n, k, workUnitSize, n_max) do
    #handle cases where a job in a worker exceeds n_max
   
    ceiling = n+workUnitSize-1
    
    workResult = Enum.to_list n..ceiling
    |> Enum.map((&(isPerfectSquare(fn -> sumOfSquares(&1,k) end))))
    |> Enum.filter(fn x-> (x != 0 && x<=n_max) end)    
    Enum.each( workResult, fn x-> IO.inspect x end) 

  end

end
