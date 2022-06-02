defmodule Jili5Test do
  use ExUnit.Case
  doctest Jili5

  test "greets the world" do
    assert Jili5.hello() == :world
  end
end

defmodule InterpCase do
  use ExUnit.Case
  doctest Jili5

  test "interp numc" do
    assert Jili5.interp(%NumC{n: 4}, Jili5.top_env) == %PrimV{v: 4}
  end
end
