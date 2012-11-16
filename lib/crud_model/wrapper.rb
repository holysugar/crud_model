require 'active_attr'

module CrudModel
  module Wrapper
    extend ActiveSupport::Concern

    included do
      include ActiveAttr::Model
      include Validator
      include ActiveRecordInterface

      attr_accessor :wrapped
    end

    module DelegationMethods
      attr_accessor :delegated_methods

      def define_delegates(methods, to)
        delegated_methods.replace(methods)
        delegate *all_delegated_methods(methods), :to => to
      end

      def delegated_methods
        @_delegated_methods ||= []
      end

      private
      def all_delegated_methods(methods)
        delegate_methods = methods.dup
        delegate_methods += delegate_methods.map{|attr| "#{attr}=".to_sym }
        delegate_methods += [:id, :persisted?, :new_record?]
        delegate_methods
      end
    end

    module ControllerMethods
      attr_accessor :wrap_class

      def wrap(model_object)
        new.tap do |i|
          i.wrapped = model_object
        end
      end

      def wrap_all(model_objects)
        model_objects.map{|o| wrap(o) }
      end

      # controller interfaces

      # for index action
      def all
        wrap_all(wrap_class.all)
      end

      # for show, edit, update, delete action
      def find(id)
        wrap(wrap_class.find(id))
      end

      private
      def define_wrap_class(to, options = {})
        case to
        when Class
          self.wrap_class = to
        when Symbol
          self.wrap_class = to.to_s.classify.constantize
        else
          self.wrap_class = to.class
        end

        define_wrap_alias(self.wrap_class) unless options[:alias] === false
      end

      def define_wrap_alias(klass)
        method = klass.to_s.underscore
        alias_method method      , :wrapped
        alias_method "#{method}=", :wrapped=
      end
    end

    module Validator
      extend ActiveSupport::Concern

      def validate_delegations
        if wrapped.invalid?
          self.class.delegated_methods.each do |name|
            if (errors = wrapped.errors[name]).present?
              errors.each do |error_message|
                self.errors.add name, error_message
              end
            end
          end
        end
      end

      included do
        validate :validate_delegations # FIXME how to suppress if want?
      end
    end

    module ActiveRecordInterface
      extend ActiveSupport::Concern

      # for new, create
      def initialize(attributes = {})
        self.wrapped = self.class.wrap_class.new(attributes)
      end

      def attributes=(attributes)
        wrapped.attributes = attributes.slice(*self.class.delegated_methods)
      end

      def update_attributes(attributes, &block)
        self.attributes = attributes
        save
      end

      def save
        run_callbacks :save do
          return false unless valid?
          wrapped.save
        end
      end

      included do
        extend ActiveModel::Callbacks
        define_model_callbacks :save
      end
    end

    module ClassMethods
      include ControllerMethods
      include DelegationMethods

      # FIXME change interface
      def delegate_model(*args)
        options = args.extract_options!
        raise ArgumentError, ":to is required" unless options[:to]

        define_wrap_class(options[:class] || options[:to])
        define_delegates(args, options[:to])
      end

    end


  end
end
