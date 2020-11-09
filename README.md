# Elixir

My personal notes for Elixir, these are just quick notes so I don't forget what I've read from the documentation.

Table of Contents
=================

* [Basic Types](#basic-types)
* [Basic Operators](#basic-operators)
* [Pattern Matching](#pattern-matching)
* [Conditionals](#conditionals)

## Basic Types

### Types in Elixir

integer, float, boolean, **atom**, **symbol**, string, list, tuple

> what do atoms actually do?
uses `:atom` notation

### Funcions

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

Do/end blocks are always bound to the outermost function call.








