# Elixir

My personal notes for Elixir, these are just quick notes so I don't forget what I've read from the documentation.

Table of Contents
=================

* [Basic Types](#basic-types)
* [Basic Operators](#basic-operators)
* [Pattern Matching](#pattern-matching)
* [Conditionals](#conditionals)
* [Strings](#strings)
* [Keyword Lists and Maps](#keyword-lists-and-maps)

## Basic Types

### Types in Elixir

integer, float, boolean, **atom**, **symbol**, string, list, tuple

> what do atoms actually do?
uses `:atom` notation

### Functions

Functions are identified _both_ by name and arity.

```elixir
h round/1
# documents round/1
```

### Atoms

```elixir
:apple == :apple
# true
:apple == :orange
```

The booleans `true` and `false` are also atoms

Alias -- start in uppercase and are also atoms.

### Strings

- utf-8

```elixir
string = :world
"hello #{string}"

# "hello world"
```

### Anonymous functions

```elixir
add = fn a, b -> a + b end
add.(1, 2)
# 3
is_function(add)
# true
double = fn a -> add.(a, a) end
```

A variable assigned inside a function does *not* affect its surrounding scope.

### Linked Lists

Concatenate using ++/2 and --/2 operators.

Elixir data structures are immutable.

#### Head & Tail example
```elixir
list = [1, 2, 3]
hd(list)
# 1
tl(list)
# [2, 3]
```


```elixir
# charlist for hello
[104, 101, 108, 108, 111]
```

### Tuples

Can hold any value

```elixir
{:ok, "hello"}
tuple_size {:ok, "hello"}
# 2
```

### Lists/Tuples

Common pattern is to use a tuple with ok/error

```elixir
File.read("path/file")
{:ok, "... contents ..."}
File.read("path/file")
{:error, :enoent}
```

When counting elements...

- `size` if the operation is in constnat time
- `length` if the operation is linear time

## Basic Operators

```elixir
# ++ & -- to mainpulate lists
[1, 2] ++ [3, 3]
# [1, 2, 3, 3]
[1, 2, 3] -- [2]
# [1, 3]

# or and and are short-circuit operators
false and raise("This error will never be raised")

true or raise("This error will never be raised")

1 < :atom
```

Sorting order defined below

```
number < atom < reference < function < port < pid < tuple < map < list < bitstring
```

## Pattern Matching

`=` is known as the match operator

```elixir
# match operator is not only used to match against simple values but more complex data types

# destructure
{ a, b, c} = {:hello, "world", 42}
# a
# :hello
```

### The pin operator


Variables in Elixir can rebound. [1] What does that mean?

```elixir
x = 1
x = 2

^x = 2
```

Pin operator can be used inside other pattern matches, such as tuples or lists.

```elixir
[^x, 2, 3] = [1, 2, 3]

{y, ^x} = {2, 1}

# y
# 2
```

If you don't care about a particular value in a pattern, it is a common practice to bind those values to `_`

```elixir
[head | _] = [1, 2, 3]
# [1, 2, 3]
# head
# 1
```

You can never read from `_`!

Although pattern matching allows us to build powerful constructs, its usage is limited. For instance, you cannot make function calls on the left side of a match.

```elixir
length([1, [2], 3]) = 3
```

## Conditionals

- `case`
- `cond`
- `if` / `unless`
- `do` / `end`

### case

```elixir
case {1, 2, 3} do
```

```elixir
case {1, 2, 3} do
    {4, 5, 6} ->
        "This clause won't match."
    {1, x, 3} ->
        "This clause will match and bind x to 2 in this clause"
    _ ->
        "This clause will match any value"
end
```

If you want to pattern match against an existing variable, you need to use the `^` operator

```elixir
x = 1
case 10 do
    # matches against the existing x variable
    ^x -> "Won't match"
    _ -> "Will match"
end
"Will match"
```

Clauses also allow extra conditions to be specified via guards

```elixir
case {1, 2, 3} do
    {1, x, 3} when x > 0 ->
        "Will match"
    _ ->
        "Would match, if guard condition were NOT satisfied"
end
"Will match"
```

The first clause above will only match when `x` is positive.

Keep in mind errors in guard do not leak but simply make the guard fail

```elixir
case 1 do
    x when hd(x) -> "Won't match"
    x -> "Got #{x}"
end
```

If none of the clauses match, an error is raised

```elixir
case :ok do
    :error -> "Won't match"
end
```
> (CaseClauseError) no case clause matching: :ok


Anonymous functions can also have multiple clauses and guards

```elixir
f = fn
    x, y when x > 0 -> x + y
    x, y -> x * y
end
```

The number of arguments in each anonymous function clause needs to be the same, otherwise an error is raised.

```elixir
f2 = fn
    # arity of 2
    x, y when x > 0 -> x + y
    # arity of 3
    x, y, z -> x * y + z
end

--- compile error: cannot mix clauses with different arities in anonymous functions
```

### cond

`case` is useful when you need to match against different values. However, in many circumstances, we want to check different conditions and find the first one that does not evaluate to `nil` or `false`

```elixir
cond do
    2 + 2 == 5 ->
        "This will not be true"
    2 * 2 == 3 ->
        "Nor this"
    1 + 1 == 2 ->
        "But this will"
end
```

```elixir
cond do
    2 + 2 == 5 ->
        "this is never true"
    2 * 3 == 3 ->
        "nor this"
    true ->
        "This is always true (equivalent to else)"
end
```

`cond` considers any value besides `nil` and `false` to be true

```elixir
cond do 
    hd([1, 2, 3]) ->
        "1 is considered as true"
end
```

### if and unless

```elixir
if true do
    "This works!"
end

unless true do
    "This will never be seen"
end
```

> `if/2` and `unless/2` are implemented as macros; they aren't special language constructs

### do/end blocks

```elixir
if true do
    a = 1 + 2
    a + 10
end
# 13
```

`Do/end` blocks are always bound to the outermost function call.

## Strings

Strings are very comprehensive in Elixir, and follow a more-developed spec than in other languages.

### Unicode and Code Points

The Unicode standard acts as an official registry of virtually all characters. Unicode organizes all the characters into charts, and each is given an index known as a Code Point.

In elixir, you can use the `?` operator in front of a literal to reveal its code point

```elixir
?a
# 97
?é
# 233
```

### UTF-8 and Encodings

Whereas the code point is *what* we store, encodings are *how* we store them. Encoding is just an implementation. UTF-8 uses _variable width_ character encoding.

> `String.length/1` counts graphemes but `byte_size/1` counts raw bytes!

A common trick in Elixir is to see the binary representation of a string by concatenating the null byte `<<0>>` to it

```elixir
"hełło" <> <<0>>
# <<104, 101, 197, 130, 197, 130, 111, 0>>
"Pokémon" <> <<0>>
# <<80, 111, 107, 195, 169, 109, 111, 110, 0>>
```

Note that both of these have the `0` from the null byte at the end

Or by using `IO.inspect/2`

```elixir
IO.inspect("hełło", binaries: :as_binaries)
# <<104, 101, 197, 130, 197, 130, 111>>
```

### Bitstrings

Bitstrings are a fundamental data type in Elixir, denoted with `<<>>` syntax. *A bitstring is a contiguous sequences of bits in memory*

When a value exceeds the number of bits it can hold, it gets cut off

```elixir
<<1>> === <<257>>
# true
```

### Binaries

A binary is a bitstring where the number of bits is divisible by 8

```bash
iex> is_binary("hello")
true
iex> is_binary(<<239, 191, 19>>)
true
iex> String.valid?(<<239, 191, 19>>)
false
```

### Charlists

A charlist is a list of integers where all the integers are valid code points. Whereas strings (i.e. binaries) are created using double-quotes, charlists are single quoted.

By default, only code points above ASCII get printed as lists

```bash
iex> 'hello'
'hello'
iex> 'hełło'
[104, 101, 322, 322, 111]
```

> Strings use `<>` to concatenate but lists use `++`

Because charlists are lists :]

## Keyword lists and maps

Associative data structures are structures that associate certain value(s) to a key. Referred to as dictionaries, hashes, etc. Keyword lists and maps are the main ones in Elixir.

### Keyword lists

Elixir uses a list of tuples, and the first item in a key is an atom

```elixir
list = [{:a, 1}, {:b, 2}]
# [a: 1, b: 2]

# special syntax for defining a keyword list
list == [a: 1, b: 2]
```

We can also use the `++` operator to add new values

```elixir
list ++ [c: 3]
# [a: 1, b: 2, c: 3]
```

First value is the list is the one fetched on lookup

```elixir
[a: 0, a: 1, b: 2]

new_list[:a]
# 0
```

Keyword lists have three special characteristics

* Keys must be atoms
* Keys are ordered, as specificed by the developer
* Keys *can* be given more than once

As an example, the `if/2` macro supports the following syntax

```elixir
if false, do: :this, else: :that
# :that
```

The `do:` and `else:` pairs form a keyword list. The call above is equivalent to

```elixir
if(false, [do: :this, else: :that])
```

Although we can pattern match on keyword lists, it is rarely done in practice since pattern matching on lists requires the number of items and their order to match.

Keyword lists have the same performance impact as a regular list.

> If you need to store many items or guarantee one-key associations with at maximum one-value, you should use maps instead.

### Maps

Whenever you need a key-value store, maps are the "go to" data structure in Elixir. A map is created using the `%{}` syntax

```elixir
map = %{:a => 1, 2 => :b}
map[:a]
# 1
map[2]
# :b
map[:c]
# nil
```

In contrast to keyword lists, maps are great for pattern matching

```elixir
%{} = %{:a => 1, 2 => :b}
%{2 => :b, :a => 1}
%{a => :b, :a => 1}
1
%{:c => c} = %{:a => 1, 2 => :b}
# MatchError!  no match
```

> An empty map matches all maps

Maps also have their own syntax for accessing atom keys

```elixir
map = %{:a => 1, 2 => :b}
map.a
# 1
map.c
# KeyError
```

### Nested Data structures

Often we will have maps inside maps, keyword lists inside maps, etc. Elixir provides conveniences for nested data structures

Given this structure...

```elixir
users = [
    # keyword lists of users where each value is a map
    john: %{name: "John", age: 22, languages: ["Erlang", "Ruby"]}
    mary: %{name: "Mary", age: 20, languages: ["Elixir", "F#"]}
]
```
To access the age for john, we could write:

```elixir
users[:john].age
```

To update the value

```elixir
users = put_in users[:john].age, 32
```

To remove a value

```elixir
users = update_in users[:mary].languages, fn languages ->
    List.delete(languages, "F#") end
```


