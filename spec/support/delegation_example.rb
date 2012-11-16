#require 'active_support/all' # FIXME
require 'active_record'
require 'active_attr'
require 'crud_model/delegation'

module SetupItemNameChanger
  def self.included(klass)
    klass.class_eval do
      before(:all) do
        ActiveRecord::Migration.suppress_messages do
          ActiveRecord::Schema.define(:version => 1) do
            create_table :items do |t|
              t.column :name    , :string
              t.column :price   , :integer
              t.column :sales_at, :datetime
              t.timestamps
            end
          end
        end
        Item.create(name: 'ace', price: 100, sales_at: 1.day.from_now)
        Item.create(name: 'bat', price: 200, sales_at: 1.day.from_now)
        Item.create(name: 'car', price: 300, sales_at: 1.day.from_now)
      end
      after(:all) do
        ActiveRecord::Base.connection.tables.each do |table|
          ActiveRecord::Base.connection.drop_table(table)
        end
      end
    end
  end
end

class Item < ActiveRecord::Base
  attr_accessible :name, :price, :sales_at
  validates :name, :length => { :in => 3..10 }
  validates :price, :numericality => { :greater_than => 0 }
end


class ItemNameChanger
  include ActiveAttr::Model
  include CrudModel::Delegation
  delegate_model :name, :to => :item
  delegate :id, :persisted?, :name, :name=, :to => :item

  extend ActiveModel::Callbacks
  define_model_callbacks :save

  attr_accessor :wrapped
  alias item  wrapped
  alias item= wrapped=

  def self.wrap(model_object)
    new.tap do |i|
      i.wrapped = model_object
    end
  end

  # self.wrap_all(attr_name: objects)
  def self.wrap_all(model_objects)
    model_objects.map{|o| wrap(o) }
  end

  def self.model_class
    Item
  end

  def self.delegated_methods
    [:name]
  end

  # for index
  def self.all
    wrap_all(model_class.all)
  end

  # for show, edit, update, delete
  def self.find(id)
    wrap(model_class.find(id))
  end

  # for new, create
  def initialize(attributes = {})
    self.wrapped = self.class.model_class.new(attributes)
  end

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

  validate :validate_delegations


  # validate do
  #   self.class.delegations.each do |var, attr_names|
  #     # FIXME validation scope
  #     model = send(var)
  #     if model.invalid?
  #       attr_names.each do |name|
  #         if (errors = model.errors[name]).present?
  #           errors.each do |error_message|
  #             self.errors.add name, error_message
  #           end
  #         end
  #       end
  #     end
  #   end
  # end

  def attributes=(attributes)
    self.class.delegations.each do |var, keys|
      # FIXME validation scope
      model = send(var)
      model.attributes = attributes.slice(*keys)
    end
  end

  # FIXME how can i do static meta generation?
  def update_attributes(attributes, &block)
    self.attributes = attributes
    save
  end

  def save
    run_callbacks :save do
      return false unless valid?

      self.class.delegations.all? do |var, keys|
        send(var).save
      end
    end
  end

end

