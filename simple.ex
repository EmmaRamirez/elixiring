
data = %{:attack => 1, :hp => 10, :name => ""}

defmodule Player do
  @player_data %{:attack => 10, :hp => 10, :name => ""}

  def get_data, do: @player_data

  def hp do
    Agent.start_link(fn -> 10 end, name: __MODULE__)
  end

  def add_hp(n \\ 10) do
    Agent.get_and_update(__MODULE__, fn (x) -> { x + n, x + n} end)
  end

  def create_player do
    Agent.start_link(fn -> %{
      :attack => 10,
      :name => "",
      :current_hp => 5,
      :max_hp => 10,
    } end, name: :player)
  end

  def update_player(key, value) do
    Agent.get_and_update(:player, fn (x) -> {x, %{x | key => value }} end)
  end

  def get_player do
    Agent.get(:player, fn x -> x end)
  end

  def name_player(a) do
    Agent.get_and_update(:player, fn (x) -> {x, %{x | name: a }} end)
  end

  def create_hp_display do
    current_hp = Player.get_player()[:current_hp]
    max_hp = Player.get_player()[:max_hp]
    hp_diff = max_hp - current_hp
    # hps = Enum.map(1..current_hp, fn x -> "*" end)
    hps = Enum.reduce(
      Enum.map(1..current_hp, fn _ -> "░" end),
      fn x, acc -> x <> acc end
    )

    dead_hps = Enum.reduce(
      Enum.map(1..hp_diff, fn _ -> "▓" end),
      fn x, acc -> x <> acc end
    )

    # for hp <- hps, do: hp <> hp

    "#{current_hp}/#{max_hp} #{hps <> dead_hps}"
  end

  def end_game do
    Agent.stop(:player, :term)
  end

  def print() do
    data = Player.get_player
    IO.write """
      Player: #{data[:name]}
      Attack: #{data[:attack]}
      HP: #{Player.create_hp_display}
    """
  end

end

IO.inspect Player.create_player()
IO.inspect Player.get_player
IO.inspect Player.update_player(:name, "Emma")
# Player.name_player("Emmanems")
Player.print()


# defmodule PlayerManager do

#   # def name_player(a) do
#   #   %{ Player | name: a }
#   # end

#   def print_name() do
#     IO.puts "Welcome player " <> data[:name]
#   end

#   def raise_attack(a \\ 10) do
#     %{ data | attack: data.attack + a }
#   end
# end


# # PlayerManager.name_player("Emma")
# PlayerManager.print_name()
# # PlayerManager.raise_attack()
