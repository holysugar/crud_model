
module CrudModel
  module Delegation
    extend ActiveSupport::Concern

    module ClassMethods
      def delegate_model(*args)
        options = args.extract_options!
        raise ArgumentError, ":to is required" unless options[:to]

        delegate_methods = args.dup
        delegate_methods += delegate_methods.map{|attr| "#{attr}=".to_sym }
        delegate_methods += [:id, :persisted?, :new_record?]

        delegations[options[:to]] = args
        delegate *delegate_methods, :to => options[:to]
      end

      def delegations
        @_delegations ||= {}
      end
    end
  end
end
