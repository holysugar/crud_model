
module CrudModel
  module ModelProxy
    extend ActiveSupport::Concern
    def proxymodel(name)
      send(name)
    end

    module ClassMethods
      def delegate_model(*args)
        options = args.extract_options!
        raise ArgumentError, ":to is required" unless options[:to]

        args += args.map{|attr| "#{attr}=".to_sym }
        if options.delete(:primary) || delegations.blank?
          args += [:id, :persisted?, :new_record?]
        end
        delegate *args, :to => options[:to]
        delegations[options[:to]] = args
      end

      def delegations
        @_delegations ||= {}
      end
    end
  end
end
