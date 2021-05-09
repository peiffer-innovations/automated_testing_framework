/// An exception that should be thrown by a [VariableResolver] when it is asked
/// to resolve a variable that it does not support resolving.
class UnknownVariableException implements Exception {
  UnknownVariableException(this.variableName);

  final String variableName;
}
