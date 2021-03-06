#doc Enumerable
#| The Enumerable module provides various methods for interacting with
#| collections of values. Both `List` and `Map` include this module by default.
#|
#| The only requirement for including this module is to define an `each` method
#| that accepts a block argument and calls that block for every element of the
#| collection.
defmodule Enumerable
  #doc map(&block) -> list
  #| Call `block` for each element of `self` and collect the result for each
  #| call into a new List. If `each` does not yield any elements, the result
  #| will be an empty List.
  def map(&block)
    result = []
    each do |elem|
      result.push(block(elem))
    end
    result
  end

  #doc join(delimiter) -> str
  #| Creates a new string from the result of calling `to_s` on every element of
  #| `self`, inserting `delimiter` between each element.
  def join(delimiter : String)
    str = ""
    first = true
    each do |e|
      when first
        str += e.to_s
        first = false
      else
        str += "<(delimiter)><(e)>"
      end
    end
    str
  end

  #doc size -> integer
  #| Returns the size of the enumerable, as determined by the number of
  #| times `each` yields an element to its block.
  def size
    counter = 0

    each do |e|
      counter += 1
    end

    counter
  end

  #doc all?(&block) -> boolean
  #| Return true if all elements in the enumerable cause `block` to return a
  #| truthy value.
  def all?(&block)
    result = nil
    each do |e|
      when block(e)
        result = true
      else
        result = false
        break
      end
    end
    result
  end

  #doc any?(&block) -> boolean
  #| Return true if at least one element in the enumerable evaluates to a
  #| truthy value for the given block.
  def any?(&block)
    result = nil
    each do |e|
      when block(e)
        result = true
        break
      else
        result = false
      end
    end
    result
  end

  #doc find(&block) -> element
  #| Iterate the enumerable, passing each element to `block`. Return the first
  #| element for which the block returns a truthy value.
  def find(&block)
    result = nil
    each do |e|
      when block(e)
        result = e
        break
      end
    end
    result
  end

  #doc select(&block) -> list
  #| Iterate the enumerable, passing each element to `block`. Return all
  #| elements for which the block returns a truthy value.
  def select(&block)
    result = []

    each do |e|
      when block(e)
        result.push(e)
      end
    end

    result
  end

  #doc min -> element
  #| Returns the element with the lowest value as determined by comparing
  #| values with their `<` operator.
  def min
    value = nil

    each do |e|
      when value == nil || e < value
        value = e
      end
    end

    value
  end

  #doc max -> element
  #| Returns the element with the highest value as determined by comparing
  #| values with their `>` operator.
  def max
    value = nil

    each do |e|
      when value == nil || e > value
        value = e
      end
    end

    value
  end

  #doc sort -> list
  #| Returns a new, sorted List of all elements in the enumerable.
  def sort
    list = to_list
    when size < 2
      return list
    end

    # insertion sort
    i = 1
    while i < size
      value = list[i]
      j = i - 1

      while j >= 0 && list[j] > value
        list[j + 1] = list[j]
        j -= 1
      end

      list[j + 1] = value
      i += 1
    end

    list
  end

  #doc to_list -> list
  #| Returns a new List containing all elements of the enumerable.
  def to_list
    list = []

    each do |e|
      list.push(e)
    end

    list
  end

  #doc reduce(&block) -> value
  #| For every element in the enumerable, call `block` with the result of the
  #| previous call and the current element as arguments. Returns a single
  #| value: the result of the final call to `block`.
  #|
  #| For the first element of the enumerable, the block is _not_ called, and
  #| the element is instead passed directly as the first argument of the
  #| `block` call for the second element.
  def reduce(&block)
    value = nil

    each do |e|
      when value == nil
        value = e
      else
        value = block(value, e)
      end
    end

    value
  end
  #doc reduce(value, &block) -> value
  #| Use `value` as the initial value for the accumulator instead of the first
  #| element, allowing `block` to be called for the first element as well.
  def reduce(value, &block)
    each do |e|
      value = block(value, e)
    end

    value
  end
end
