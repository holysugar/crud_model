#require 'active_support/all' # FIXME
require 'active_record'
require 'active_attr'
require 'crud_model/model_proxy'

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
  include CrudModel::ModelProxy
  delegate_model :name, :to => :item

  extend ActiveModel::Callbacks
  define_model_callbacks :save

  before_save :randomize_name
  def randomize_name
    self.name = 8.times.map{ [*('a'..'z')].sample }.join
  end

  delegate :id, :persisted?, :name, :name=, :to => :@item

  def self.wrap(model_object)
    new.tap do |i|
      i.item = model_object
    end
  end

  def self.wrap_all(model_objects)
    model_objects.map{|o| wrap(o) }
  end

  def self.model_class
    Item
  end

#  def self.delegations
#    {
#      :@item => [:name],
#    }
#  end

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
    @item = self.class.model_class.new(attributes)
  end

  validate do
    self.class.delegations.each do |var, attr_names|
      # FIXME validation scope
      model = instance_variable_get(var)
      if model.invalid?
        attr_names.each do |name|
          if (errors = model.errors[name]).present?
            errors.each do |error_message|
              self.errors.add name, error_message
            end
          end
        end
      end
    end
  end

  def attributes=(attributes)
    self.class.delegations.each do |var, keys|
      # FIXME validation scope
      model = instance_variable_get(var)
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
        instance_variable_get(var).save
      end
    end
  end

end

