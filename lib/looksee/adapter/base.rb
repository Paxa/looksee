module Looksee
  module Adapter
    class Base
      #
      # Return the chain of classes and modules which comprise the
      # object's method lookup path.
      #
      def lookup_modules(object)
        start =
          begin
            singleton_class = (class << object; self; end)
            singleton_class unless has_no_methods?(singleton_class) && !(Class === object)
          rescue TypeError  # immediate object
          end
        start ||= Object.instance_method(:class).bind(object).call
        start.ancestors
      end

      #
      # Return a description of the given module.
      #
      # This is used for the module labels in the Inspector output.
      #
      def describe_module(mod)
        num_brackets = 0
        object = mod
        while singleton_class?(object)
          num_brackets += 1
          object = singleton_instance(object)
        end

        if included_class?(mod) || object.is_a?(Module)
          description = module_name(object)
          if description.empty?
            is_class = real_module(object).is_a?(Class)
            description = "unnamed #{is_class ? 'Class' : 'Module'}"
          end
        else
          description = "#{module_name(object.class)} instance"
        end

        if num_brackets == 0
          description
        else
          "#{'['*num_brackets}#{description}#{']'*num_brackets}"
        end
      end

      def real_module(module_or_included_class)
        module_or_included_class
      end

      def included_class?(object)
        raise NotImplementedError, "abstract"
      end

      def internal_public_instance_methods(mod)
        Module.instance_method(:public_instance_methods).bind(mod).call(false)
      end

      def internal_protected_instance_methods(mod)
        Module.instance_method(:protected_instance_methods).bind(mod).call(false)
      end

      def internal_private_instance_methods(mod)
        Module.instance_method(:private_instance_methods).bind(mod).call(false)
      end

      def internal_undefined_instance_methods(mod)
        raise NotImplementedError, "abstract"
      end

      def has_no_methods?(mod)
        internal_public_instance_methods(mod).empty? &&
          internal_protected_instance_methods(mod).empty? &&
          internal_private_instance_methods(mod).empty? &&
          internal_undefined_instance_methods(mod).empty?
      end

      def singleton_class?(object)
        raise NotImplementedError, "abstract"
      end

      def singleton_instance(singleton_class)
        raise NotImplementedError, "abstract"
      end

      def module_name(mod)
        raise NotImplementedError, "abstract"
      end

      if RUBY_VERSION >= '1.9.0' || Looksee.ruby_engine == 'rbx'
        def source_location(method)
          method.is_a?(UnboundMethod) or
            raise TypeError, "expected UnboundMethod, got #{method.class}"
          method.source_location
        end
      else
        def source_location(method)
          raise NotImplementedError, 'abstract'
        end
      end
    end
  end
end
