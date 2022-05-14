defmodule Game do
  use Agent

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

  @monsters %{
    1 => %{
      :name => "imp",
      :display => "👿",
      :attack => 4,
      :hp => 5,
      :base_exp => 30,
    },
    2 => %{
      :name => "winged imp",
      :display => "🦇👿",
      :attack => 5,
      :hp => 5,
      :base_exp => 40,
    },
    3 => %{
      :name => "naga",
      :display => "🐍🙍",
      :attack => 10,
      :hp => 16,
      :base_exp => 45,
    }
  }

  @classes %{
    1 => %{
      :name => :warrior,
      :display => "⚔️",
      :bonus => :attack,
    },
    2 => %{
      :name => :mage,
      :display => "🔮",
      :bonus => :special,
    },
    3 => %{
      :name => :knight,
      :display => "🛡️",
      :bonus => :defense,
    }
  }

  def create_player do
    Agent.start_link(fn -> %{
      :attack => 10,
      :defense => 10,
      :special => 10,
      :exp => 0,
      :level => 1,
      :exp_needed_for_next_level => 100,
      :stats => %{},
      :class => :warrior,
      :inventory => %{
        :potion => %{
          :quantity => 1,
          :display => "🧪",
          :description => "Heals 10 HP."
        },
        :vial => %{
          :quantity => 0,
          :display => "⚗️",
          :description => "Heals 30 HP."
        },
        :fruit => %{
          :quantity => 0,
          :display => "🥝",
          :description => ""
        },
        :meat => %{
          :quantity => 0,
          :display => "🍖",
          :description => "",
        },
        :amphora => %{
          :quantity => 0,
          :display => "🏺",
          :description => "",
        }


      },
      :name => "",
      :current_hp => 10,
      :max_hp => 10,
    } end, name: :player)
  end

  def create_monster(monster) do
    Agent.start_link(fn -> Map.merge(
      monster,
      %{
        :current_hp => 10,
      }
    ) end, name: :monster)
  end

  def get_current_monster do
    Agent.get(:monster, fn n -> n end)
  end

  def kill_monster do
    Agent.stop(:monster)
  end

  def update_player(key, value) do
    Agent.get_and_update(:player, fn (x) -> {x, %{x | key => value }} end)
  end

  def get_player do
    Agent.get(:player, & &1)
  end

  def print_inventory do
    inventory = Game.get_player()[:inventory]
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

    with_indices = 1..length(items)
      |> Stream.zip(items)
      |> Enum.into(%{})

    message = with_indices
      |> Enum.map(fn {k, v} ->
        str = Atom.to_string(v)
        n_cap = String.capitalize(str)
        "  [#{k}] #{String.capitalize(str)} #{@areas[v].display}\n"
      end)

    number = prompt_parse(message)
    is_valid = 0 < number and number < 5

    IO.puts(is_valid)

    if is_valid do
      cond do
        number == 1 -> explore_area(Map.get(with_indices, 1))
        number == 2 -> explore_area(Map.get(with_indices, 2))
        number == 3 -> explore_area(Map.get(with_indices, 3))
        number == 4 -> explore_area(Map.get(with_indices, 4))
        true -> IO.puts("Cool")
      end
    else
      IO.puts("Could not recognize that command.")
      print_areas()
    end

  end

  def rest() do
    IO.puts("You rested, restoring HP ✨")
  end

  def explore_area(area) do
    IO.puts("Exploring #{Atom.to_string(area)} ...")
    size = map_size @monsters

    # @TODO: refactor to use weights??
    rand = Enum.random([:nothing, :enemy, :enemy, :enemy, :enemy, :item, :item, :alternate])
    IO.puts(rand)

    rand = Enum.random(@monsters)
    monster = elem(rand, 1)
    create_monster(monster)

    IO.puts("A wild #{monster.name} appeared!")

    monster_sequence(monster)

  end

  def monster_sequence(monster) do
    number = prompt_parse("""
╭╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╾╮
  What will you do?             > [1] Fight
                                > [2] Flee
                                > [3] Bag
  #{String.capitalize(monster.name)} #{monster.display} HP: #{monster.hp}
╰╼╼╼╼╼╼╼╼╼╼╼╼╼╼╼╼╼╼╼╼╼╼╼╼╼╼╼╼╼╼╼╼╼╼╼╼╼╼╼╼╼╼╼╼╼╯
""")
    cond do
      number == 1 -> fight_monster(monster)
      number == 2 -> IO.puts("You fleed from the #{String.capitalize(monster.name)}!")
      number == 3 -> use_item(monster)
    end
  end

  def use_item(monster) do

  end

  def award_exp(monster) do
    new_exp = Game.get_player()[:exp] + monster.base_exp
    update_player(:exp, new_exp)

    if Game.get_player()[:exp_needed_for_next_level] <= 0 do

    end
  end

  def fight_monster(monster) do
    monster_attack = get_current_monster()[:attack] - Game.get_player()[:defense]
    new_player_hp = Game.get_player()[:current_hp] - monster_attack
    monster_hp = get_current_monster()[:current_hp] - Game.get_player()[:attack]
    IO.puts("You took #{monster_attack} damage!")
    update_player(:current_hp, new_player_hp)

    if new_player_hp <= 0 do
      tombstone_check()
    else
      if monster_hp <= 0 do
        IO.puts("The monster was slain!")

      else
        fight_monster(monster)
      end
    end
  end

  def choose(map) do
    # @TODO: replace stub
  end


  def create_hp_display(current \\ -1, max \\ -1) do
    # @TODO: figure out a better way to do this!!
    current_hp = if (current == -1), do: Game.get_player()[:current_hp], else: current
    max_hp = if (max == -1), do: Game.get_player()[:max_hp], else: max
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
    #Tombstone.print()
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

  def prompt_name(prompt \\ "What is your name?") do
    name = IO.gets(prompt)
    update_player(:name, name)
  end

  def tombstone_check do
    current_hp = Game.get_player()[:current_hp]
    if current_hp <= 0 do
      #Tombstone.print()
    end
  end

  def prompt_action do
    print_inventory()
    tombstone_check()
    max_hp = Game.get_player()[:max_hp]

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
        number == 2 -> rest()
        number == 3 -> print()
        number == 4 -> print_inventory()
        true -> IO.puts("Cool")
      end
    else
      prompt_action()
    end
  end

  def update_class(class \\ :warrior) do
    data = Game.get_player

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
    name = prompt_parse("""
      What is your name?
    """)

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
      Game.prompt_class
    end
  end


  def print() do
    data = Game.get_player
    IO.write """
      Game: #{data[:name]} (#{data[:class]})
      Attack: #{data[:attack]}
      Special: #{data[:special]}
      Defense: #{data[:defense]}
      HP: #{Game.create_hp_display}
    """
  end
end

Game.create_player()
Game.prompt_class()
Game.prompt_action()
