# Considers all the keys in `options` to be attribute names, and sets
# that attribute to the corresponding value. For example:
#
#   apply_options_to baz, foo: 'bar'
#
# This would cause the `foo=` message to be sent to `obj` with the value
# `'bar'`.
def apply_options_to(obj, options = {})
  options.each do |k, v|
    obj.send("#{k}=".to_sym, v)
  end
end
