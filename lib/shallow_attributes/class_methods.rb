module ShallowAttributes
  # Abstract class for value classes. Provides some helper methods for
  # working with class methods.
  #
  # @abstract
  #
  # @since 0.1.0
  module ClassMethods
    # Returns hash which contain default values for each attribute
    #
    # @private
    #
    # @return [Hash] hash with default values
    #
    # @since 0.1.0
    def default_values
      if superclass.respond_to?(:default_values)
        @default_values.merge!(superclass.default_values) { |_, v, _| v }
      else
        @default_values
      end
    end

    # Returns array of all attributes which should be present
    #
    # @private
    #
    # @return [Array] hash with default values
    #
    # @since 0.1.0
    def presents_attributes
      @presents_attributes
    end

    # Returns all class attributes.
    #
    #
    # @example Create new User instance
    #   class User
    #     include ShallowAttributes
    #     attribute :name, String
    #     attribute :last_name, String
    #     attribute :age, Integer
    #   end
    #
    #   User.attributes # => [:name, :last_name, :age]
    #
    # @return [Hash]
    #
    # @since 0.1.0
    def attributes
      default_values.keys
    end

    # Define attribute with specific type and default value
    # for current class.
    #
    # @param [String, Symbol] name the attribute name
    # @param [String, Symbol] type the type of attribute
    # @param [hash] options the attribute options
    # @option options [Object] :default default value for attribute
    # @option options [Class] :of class of array elems
    # @option options [boolean] :allow_nil cast `nil` to integer or float
    #
    # @example Create new User instance
    #   class User
    #     include ShallowAttributes
    #     attribute :name, String, default: 'Anton'
    #   end
    #
    #   User.new              # => #<User @attributes={:name=>"Anton"}, @name="Anton">
    #   User.new(name: 'ben') # => #<User @attributes={:name=>"Ben"}, @name="Ben">
    #
    # @return [Object]
    #
    # @since 0.1.0
    def attribute(name, type, options = {})
      options[:default] ||= [] if type == Array

      @presents_attributes ||= []
      @default_values ||= {}

      @default_values[name] = options.delete(:default)
      @presents_attributes << name if options.delete(:present)

      initialize_setter(name, type, options)
      initialize_getter(name)
    end

    private

    # Define setter method for each attribute.
    #
    # @private
    #
    # @param [String, Symbol] name the attribute name
    # @param [String, Symbol] type the type of attribute
    # @param [hash] options the attribute options
    #
    # @return [Object]
    #
    # @since 0.1.0
    def initialize_setter(name, type, options)
      module_eval <<-EOS, __FILE__, __LINE__ + 1
        def #{name}=(value)
          @#{name} = if value.is_a?(#{type}) && !value.is_a?(Array)
            value
          else
            ShallowAttributes::Type.coerce(#{type}, value, #{options})
          end

          @attributes[:#{name}] = @#{name}
        end
      EOS
    end

    # Define getter method for each attribute.
    #
    # @private
    #
    # @param [String, Symbol] name the attribute name
    #
    # @return [Object]
    #
    # @since 0.1.0
    def initialize_getter(name)
      attr_reader name
    end
  end
end
