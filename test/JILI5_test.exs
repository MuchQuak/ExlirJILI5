ExUnit.start()

# 2) Create a new test module (test case) and use "ExUnit.Case".
defmodule THANG do
  # 3) Note that we pass "async: true", this runs the test case
  #    concurrently with other test cases. The individual tests
  #    within each test case are still run serially.
  use ExUnit.Case #, async: true

  # 4) Use the "test" macro instead of "def" for clarity.
  test "the truth" do
    assert true
  end
end