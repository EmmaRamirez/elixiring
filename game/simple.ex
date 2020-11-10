defmodule Player do
  def create_player do
    Agent.start_link(fn -> %{
      :attack => 10,
      :defense => 10,
      :special => 10,
      :class => :warrior,
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
      Enum.map(1..max_hp, fn n -> cond do
        n <= current_hp -> "▓"
        true -> "░"
      end
      end),
      fn x, acc -> x <> acc end
    )

    "#{current_hp}/#{max_hp} #{hps}"
  end

  def end_game do
    Agent.stop(:player, :term)
  end

  def print() do
    data = Player.get_player
    IO.write """
      Player: #{data[:name]} (#{data[:class]})
      Attack: #{data[:attack]}
      HP: #{Player.create_hp_display}
    """
  end

end

Player.create_player()
Player.update_player(:name, "Emma")
# Player.name_player("Emmanems")
Player.print()
