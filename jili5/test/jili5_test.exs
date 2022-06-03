defmodule Jili5InterpTests do
  use ExUnit.Case

  test "interp numc" do
    assert Jili5.interp(%NumC{n: 4}, Jili5.top_env) == %PrimV{v: 4}
  end

  test "interp IdC True" do
    assert Jili5.interp(%IdC{s: :true}, Jili5.top_env) == %PrimV{v: true}
  end

  test "interp StringC" do
    assert Jili5.interp(%StringC{s: "str"}, Jili5.top_env) == %PrimV{v: "str"}
  end

  test "interp AppC Prim Op" do
    assert Jili5.interp(
      %AppC{
      fun: %IdC{s: :+}, 
      args: [%NumC{n: 4}, %NumC{n: 4}]},
      Jili5.top_env) == %PrimV{v: 8}
  end

  test "interp AppC nested LamC" do
    assert Jili5.interp(
      %AppC{
        fun: %LamC{args: [:x, :y], 
        body: %AppC{
          fun: %IdC{s: :+}, 
          args: [%IdC{s: :x}, %AppC{
            fun: %IdC{s: :-}, 
            args: [%NumC{n: 2}, %IdC{s: :y}]}]}}, 
      args: [%NumC{n: 3}, %NumC{n: 4}]}, 
      Jili5.top_env) == %PrimV{v: 1}
  end

  test "interp CondC" do
    assert Jili5.interp(
      %CondC{
        test: %IdC{s: :true}, 
        then: %StringC{s: "branch eval"}, 
        else: %StringC{s: "never going to reach"}},
      Jili5.top_env) == %PrimV{v: "branch eval"}
  end

  test "interp complex CondC" do
    assert Jili5.interp(
      %CondC{
        test: %AppC{fun: %IdC{s: :"<="}, 
          args: [%NumC{n: 4}, %NumC{n: 5}]}, 
        then: %StringC{s: "entered first branch"}, 
        else: %StringC{s: "entered else branch"}},
      Jili5.top_env) == %PrimV{v: "entered first branch"}
  end

  test "interp double Nested LamC" do
    assert Jili5.interp(
      %AppC{
        fun: %LamC{
          args: [:x], 
          body: %AppC{
            fun: %LamC{ 
              args: [:y], 
              body: %AppC{
                fun: %IdC{s: :+}, 
                args: [%IdC{s: :y}, %IdC{s: :x}]}},
            args: [%NumC{n: 4}]}}, 
        args: [%NumC{n: 3}]}, 
    Jili5.top_env) == %PrimV{v: 7}
  end

end