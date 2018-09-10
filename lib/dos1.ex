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

  def sumOfSquares(n, k) do
    sum = div((n+k-1)*(n+k)*(2*n+2*k-1) - (n-1)*(n)*(2*n-1),6)
    {sum,n}
  end

end
