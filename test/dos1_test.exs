defmodule Dos1Test do
  use ExUnit.Case
  doctest Dos1

  test "greets the world" do
    assert Dos1.hello() == :world
  end
end
