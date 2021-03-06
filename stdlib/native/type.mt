# This file is for documentation purposes only. The methods defined here
# are implemented as part of the native library of Myst. They are reproduced
# here to allow the documentation generator to include native documentation.

#doc Type
#| Type is the base type for all types in Myst. It provides default
#| implementations for common operations, as well as additional reflective
#| functionality to allow programs to introspect themselves at runtime.
deftype Type
  #doc to_s -> string
  #| Returns the original name given to this type as a String.
  defstatic to_s; end

  #doc ==(other) -> boolean
  #| Returns `true` if `other` represents the same Type as this type.
  defstatic ==(other); end

  #doc !=(other) -> boolean
  #| Returns `false` if `other` represents the same Type as this type.
  defstatic !=(other); end

  #doc ancestors -> list
  #| Returns a flat list of supertypes, included modules, and extended modules
  #| for this type. This list will _always_ contain the base `Type`, but will
  #| _not_ contain the original type itself.
  defstatic ancestors; end

  #doc to_s -> string
  #| Returns a new String with some debug information about the instance. This
  #| method should be overridden by any type that wants to serialize its content.
  def to_s; end

  #doc ==(other) -> boolean
  #| Returns `true` only if `other` represents the same instance as this instance.
  #| Two different instances with the same content will _not_ be considered equal
  #| by this method.
  def ==(other); end

  #doc !=(other) -> boolean
  #| Returns `false` only if `other` represents the same instance as this instance.
  #| Two different instances with the same content will _not_ be considered equal
  #| by this method.
  def !=(other); end
end
