require 'crud_model/delegation'

module CrudModel
  module Proxy # FIXME to Wrapper
    extend ActiveSupport::Concern

    included do
      attr_accessor :wrapped
    end

    module ClassMethods

      # FIXME change interface
      def delegate_model(*args)
        options = args.extract_options!
        raise ArgumentError, ":to is required" unless options[:to]

        delegated_methods.replace(args)
        delegate *all_delegated_methods(args), :to => options[:to]
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
  end
end
