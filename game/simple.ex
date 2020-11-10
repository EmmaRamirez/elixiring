defmodule Player do
  @areas %{
    :mountain => %{
      :display => "⛰️",
    },
    :volcano => %{
      :display => "🌋",
    },
    :desert => %{
      :display => "🏜️",
    },
    :forest => %{
      :display => "🌲",
    }
  }

  def create_player do
    Agent.start_link(fn -> %{
      :attack => 10,
      :defense => 10,
      :special => 10,
      :stats => %{},
      :class => :warrior,
      :inventory => %{
        :potion => %{
          :quantity => 1,
          :display => "🧪",
          :description => "Heals 10 HP."
        },
        :vial => %{
          :quantity => 1,
          :display => "⚗️",
          :description => "Heals 30 HP."
        },
        :fruit => %{
          :quantity => 1,
          :display => "🥝",
          :description => ""
        },
        :meat => %{
          :quantity => 1,
          :display => "🍖",
          :description => "",
        },
        :amphora => %{
          :quantity => 1,
          :display => "🏺",
          :description => "",
        }


      },
      :name => "",
      :current_hp => 10,
      :max_hp => 10,
    } end, name: :player)
  end

  def update_player(key, value) do
    Agent.get_and_update(:player, fn (x) -> {x, %{x | key => value }} end)
  end

  def get_player do
    Agent.get(:player, & &1)
  end

  def print_inventory do
    inventory = Player.get_player()[:inventory]
    items = Enum.sort(Map.keys(inventory))

    Enum.map(items, fn n ->
      n_cap = String.capitalize(Atom.to_string(n))
      IO.puts("""
        #{inventory[n].display} #{n_cap}: ×#{inventory[n].quantity}
        > #{inventory[n].description}
      """)
    end)
  end

  def print_areas do
    items = Enum.sort(Map.keys(@areas))

    Enum.map(items, fn v ->
      n_cap = String.capitalize(Atom.to_string(v))
      IO.puts("#{String.capitalize(Atom.to_string(v))} #{@areas[v].display}")
    end)
  end

  def create_hp_display do
    current_hp = Player.get_player()[:current_hp]
    max_hp = Player.get_player()[:max_hp]
    # hp_diff = max_hp - current_hp
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
    print_tombstone()
    Agent.stop(:player, :term)
  end

  def end_game(:choice) do
    IO.puts "See ya later!"
    Agent.stop(:player, :term)
  end

  def prompt_parse(prompt \\ "Please answer me :(") do
    answer = IO.gets(prompt)
    n = Integer.parse answer

    cond do
      n == :error -> -1
      true -> elem(n, 0)
    end
  end

  def prompt_action do
    print_inventory()
    current_hp = Player.get_player()[:current_hp]
    max_hp = Player.get_player()[:max_hp]

    if current_hp <= 0 do
      print_tombstone()
    end

    number = prompt_parse("""
      What is your next course of action?

      [1] Explore
      [2] Rest
      [3] Profile
      [4] Inventory
    """)
    is_valid = 0 < number and number < 5

    if is_valid do
      cond do
        number == 1 -> print_areas()
        number == 3 -> print()
        number == 4 -> print_inventory()
        true -> IO.puts("Cool")
      end
    else
      prompt_action()
    end
  end

  def update_class(class \\ :warrior) do
    data = Player.get_player

    cond do
      class == :warrior -> (
        update_player(:class, :warrior)
        update_player(:attack, data[:attack] + 5)
      )
      class == :mage -> (
        update_player(:class, :mage)
        update_player(:special, data[:special] + 5)
      )
      class == :knight -> (
        update_player(:class, :knight)
        update_player(:defense, data[:defense] + 5)
      )
      true -> (
        update_player(:class, :warrior)
        update_player(:attack, data[:attack] + 5)
      )
    end
  end

  def prompt_class do
    # answer = IO.gets("Hello! Welcome to Buttslandia! What class of character shall you select?\n[1] Warrior (+5 Attack)\n[2] Mage (+5 Special)\n[3] Knight (+5 Defense)\n")
    number = prompt_parse("""
      Hello! Welcome to Buttslandia! What class of character shall you select?
      [1] ⚔️ Warrior (+5 Attack)
      [2] 🔮 Mage (+5 Special)
      [3] 🛡️ Knight (+5 Defense)
    """)
    is_valid = 0 < number and number < 4

    if is_valid do
      cond do
        number == 1 -> update_class()
        number == 2 -> update_class(:mage)
        number == 3 -> update_class(:knight)
        # Pick warrior as the default class
        true -> update_class()
      end
    else
      IO.puts("Sorry I didn't recognize that selection. Let's try again...")
      Player.prompt_class
    end
  end

  def print_tombstone do
    IO.puts("""
        _.---,._,'
        /' _.--.<
          /'     `'
        /' _.---._____
        \.'   ___, .-'`
            /'    \\             .
          /'       `-.          -|-
        |                       |
        |                   .-'~~~`-.
        |                 .'         `.
        |                 |  R  I  P  |
        |                 |           |
        |                 |           |
         \              \\|           |//
    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
                            YOU DIED!
    """)
  end

  def print() do
    data = Player.get_player
    IO.write """
      Player: #{data[:name]} (#{data[:class]})
      Attack: #{data[:attack]}
      Special: #{data[:special]}
      Defense: #{data[:defense]}
      HP: #{Player.create_hp_display}
    """
  end
end

Player.create_player()
Player.prompt_class()
Player.prompt_action()
