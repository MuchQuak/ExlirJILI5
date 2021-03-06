defmodule NumC do
    @enforce_keys [:n]
    defstruct [:n]
end

defmodule StringC do
    @enforce_keys [:s]
    defstruct [:s]
end

defmodule CondC do
    @enforce_keys [:test, :then, :else]
    defstruct [:test, :then, :else]
end

defmodule IdC do
    @enforce_keys [:s]
    defstruct [:s]
end

defmodule AppC do
    @enforce_keys [:fun, :args]
    defstruct [:fun, :args]
end

defmodule LamC do
    @enforce_keys [:args, :body]
    defstruct [:args, :body]
end

defmodule PrimV do
    @enforce_keys [:v]
    defstruct [:v]
end

defmodule CloV do
    @enforce_keys [:args, :body, :e]
    defstruct [:args, :body, :e]
end

defmodule Jili5 do
  @moduledoc """
  Documentation for `Jili5`.
  """

  def top_env, do: %{+: :+, /: :/, -: :-, *: :*, <=: :"<=", true: %PrimV{v: true}, false: %PrimV{v: false}, error: :error, equal?: :equal?}

  def no_idc(sym) do
      case sym do
          :in -> true
          :var -> true
          :if -> true
          :"=>" -> true
          _ -> false
      end
  end

  defprotocol Parse do
    def prog(p)
  end

  defimpl Parse, for: Integer  do
    def prog(p), do: %NumC{n: p}
  end

  defimpl Parse, for: BitString  do
    def prog(p), do: %StringC{s: p}
  end

  defimpl Parse, for: Atom do
    def prog(p), do: %IdC{s: p}
  end

  def createAst(p) do
    s = quote do: unquote(p)
    Parse.prog(s)
  end

  def lookup(n, env) do
      find = env[n]
      if find == nil do
        raise("var is undefined #{n}")
      else
          find
      end
  end

  def interp_args(argVals, env) do
      Enum.map(argVals, fn val -> interp(val, env) end)
  end

  # def bind_args([], [], env) do: niol

  def bind_args(argVals, argIds, env) do

      cond do
          length(argVals) != length(argIds) ->
              raise("function was given wrong number of args")
          true ->
              case argVals do
                  [first_argVals | rest_argVals] ->
                      case argIds do
                          [first_argIds | rest_argIds] ->
                              cond do
                                  length(argVals) == 1 ->
                                      Map.put(env, first_argIds, first_argVals)
                                  true ->
                                      bind_args(rest_argVals, rest_argIds, Map.put(env, first_argIds, first_argVals))
                              end
                      end
              end
      end
  end

  def eval_op(op, args) do
      expr = [op | args]
      case expr do
          [:error, arg] ->
              raise("JILI user-error: #{arg}")
          [oper, v1, v2] when oper in [:-, :+, :"<=", :*, :/] -> # not checking if v1 and v2 are PrimV structs
              r1 = v1.v
              r2 = v2.v # need to check if these are real values
              case op do
                  :+ -> %PrimV{v: r1 + r2}
                  :- -> %PrimV{v: r1 - r2}
                  :* -> %PrimV{v: r1 * r2}
                  :"<=" -> %PrimV{v: r1 <= r2}
                  :/ ->
                      if r2 == 0 do
                          raise("divison by zero error")
                      else %PrimV{v: r1 / r2}
                  end
              end
          [:equal?, a1, a2] -> %PrimV{v: a1 == a2}
          _ -> raise("JILI operator not supported")
      end
  end

  def interp(exp, env) do
      case exp do
          %NumC{n: num} -> %PrimV{v: num}
          %StringC{s: str} -> %PrimV{v: str}
          %CondC{test: a, then: b, else: c} ->
              test_cond = interp(a, env)
              cond do
                  test_cond == %PrimV{v: true} ->
                      interp(b, env)
                  true ->
                      interp(c, env)
              end
          %AppC{fun: f, args: aVals} ->
              f = interp(f, env)
              case f do
                  %CloV{args: a, body: b, e: clov_e} ->
                      interp(b, bind_args(interp_args(aVals, env), a, clov_e))
                  _ -> eval_op(f, interp_args(aVals, env))
              end
          %LamC{args: a, body: b} ->
              %CloV{args: a, body: b, e: env}
          %IdC{s: str} ->
              cond do
                no_idc(str) -> raise("not valid idc")
                true -> lookup(str, env)
              end
      end
  end

end
