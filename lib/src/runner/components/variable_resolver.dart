/// A resolver that takes a variable name to a value.  If this resolver does not
/// recognize the variable, it must throw an [UnknownVariableException] rather
/// than returning [null].  A [null] return value will be interpreted as the
/// variable was explicitly resolved to [null].
typedef VariableResolver = dynamic Function(String variableName);
