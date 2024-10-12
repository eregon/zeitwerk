# frozen_string_literal: true

module Zeitwerk::RealModName
  UNBOUND_METHOD_MODULE_NAME = Module.instance_method(:name)
  private_constant :UNBOUND_METHOD_MODULE_NAME

  # Returns the real name of the class or module, as set after the first
  # constant to which it was assigned (or nil).
  #
  # The name method can be overridden, hence the indirection in this method.
  #
  # @sig (Module) -> String?
  if RUBY_ENGINE == 'truffleruby' && (RUBY_ENGINE_VERSION.split('.').map(&:to_i) <=> [24, 2, 0]) < 0
    def real_mod_name(mod)
      name = UNBOUND_METHOD_MODULE_NAME.bind_call(mod)
      # https://github.com/oracle/truffleruby/issues/3683
      if name && name.start_with?('Object::')
        p name
        puts caller, nil
      end
      name
    end

    def real_mod_name_with_workaround(mod)
      n = mod.name
      if n && n.start_with?('Object::')
        return n[8..-1]
      end

      real_mod_name(mod)
    end
  else
    def real_mod_name(mod)
      UNBOUND_METHOD_MODULE_NAME.bind_call(mod)
    end

    alias_method :real_mod_name_with_workaround, :real_mod_name
  end
end
