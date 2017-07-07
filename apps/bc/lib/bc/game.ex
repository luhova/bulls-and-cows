defmodule BC.Game do
  defstruct secret: nil

  def start_link(number) do
    secret = Enum.join(Enum.shuffle(1..String.to_integer(number)))
    Agent.start_link(fn -> %{secret: secret} end)
  end

  def guess(game, guess) do
    secret = Agent.get(game, &Map.get(&1, :secret))
    if guess == secret do
      {:ok, :win}
    else
      secret = group_digit_to_index(secret)
      guess = group_digit_to_index(guess)

      count_bulls_and_cows(secret, guess, {0, 0})
    end
  end

  defp count_bulls_and_cows(_secret, [], result) do
    {:ok, result}
  end

  defp count_bulls_and_cows(secret, [head | tail], {bulls, cows}) do
    cond do
      bull?(secret, head) ->
        count_bulls_and_cows(secret, tail, {bulls + 1, cows})
      cow?(secret, head) ->
        count_bulls_and_cows(secret, tail, {bulls, cows + 1})
      true ->
        count_bulls_and_cows(secret, tail, {bulls, cows})
    end
  end

  defp bull?(secret, element) do
    Enum.find_value(secret, fn(el) -> el == element end)
  end

  defp cow?(secret, {symbol, _pos}) do
    Enum.find_value(secret, fn({sym, _pos}) -> sym == symbol end)
  end

  # returns array of tuples {digit, index}
  defp group_digit_to_index(secret) do
    secret
    |> String.split("", trim: true)
    |> Enum.with_index
  end
end
