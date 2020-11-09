import Player

defmodule PlayerManager do

  def print_name(a) do
    IO.puts "Welcome player " <> a
  end

  defp raise_attack(player, a \\ 10) do
    newPlayer = %{ player | attack: player.attack + a }
  end
end



emma = %Player{}
PlayerManager.print_name(emma.name)
PlayerManager.raise_attack(emma)
