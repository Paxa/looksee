module Looksee
  module ObjectMixin
    #
    # Return a Looksee::Inspector for this object.
    #
    # +args+ is an optional list of specifiers.
    #
    #   * +:public+ - include public methods
    #   * +:protected+ - include public methods
    #   * +:private+ - include public methods
    #   * +:undefined+ - include public methods (see Module#undef_method)
    #   * +:overridden+ - include public methods
    #   * +:nopublic+ - include public methods
    #   * +:noprotected+ - include public methods
    #   * +:noprivate+ - include public methods
    #   * +:noundefined+ - include public methods (see Module#undef_method)
    #   * +:nooverridden+ - include public methods
    #   * a string - only include methods containing this string (may
    #     be used multiple times)
    #   * a regexp - only include methods matching this regexp (may
    #     be used multiple times)
    #
    # The default (if options is nil or omitted) is given by
    # #default_lookup_path_options.
    #
    def ls(*args)
      options = {:visibilities => Set[], :filters => Set[]}
      (Looksee.default_specifiers + args).each do |arg|
        case arg
        when String, Regexp
          options[:filters] << arg
        when :public, :protected, :private, :undefined, :overridden
          options[:visibilities].add(arg)
        when :nopublic, :noprotected, :noprivate, :noundefined, :nooverridden
          visibility = arg.to_s.sub(/\Ano/, '').to_sym
          options[:visibilities].delete(visibility)
        else
          raise ArgumentError, "invalid specifier: #{arg.inspect}"
        end
      end
      lookup_path = LookupPath.new(self)
      Inspector.new(lookup_path, options)
    end

    def self.rename(name)  # :nodoc:
      name = name[:ls] if name.is_a?(Hash)
      alias_method name, :ls
      remove_method :ls
    end
  end

  #
  # Rename the #ls method, added to every object. Example:
  #
  #     rename :_ls
  #
  # This renames Looksee's #ls method to #_ls.
  #
  # For backward compatibility, the old-style invocation is also
  # supported. Please note this is deprecated.
  #
  #     rename :ls => :_ls
  #
  def self.rename(name)
    ObjectMixin.rename(name)
  end

  name = ENV['LOOKSEE_METHOD'] and
    rename name

  Object.send :include, ObjectMixin
end
