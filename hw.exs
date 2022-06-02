
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
    @enforce_keys [:args, :body, :env]
    defstruct [:args, :body, :env]
end

# no OpV


defmodule Main do
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

    def lookup(n, env) do
        find = env[n]
        if find == nil do
          raise("var is undefined")
        else
            find
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
            %IdC{s: str} ->
                cond do
                  no_idc(str) -> raise("not valid idc")
                  true -> lookup(str, env)
                end
        end
    end
end

# test cases
# Main.interp(%CondC{test: %IdC{s: :true}, then: %StringC{s: "branch eval"}, else: %StringC{s: "never going to reach"}}, Main.top_env)
