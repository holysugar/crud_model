#require 'active_support/all' # FIXME
require 'active_record'
require 'crud_model/proxy'

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
  include CrudModel::Proxy
  delegate_model :name, :to => :item
end

