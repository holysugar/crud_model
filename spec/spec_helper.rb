$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
end

ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => ':memory:')

def setup_db
  ActiveRecord::Migration.suppress_messages do
    ActiveRecord::Schema.define(:version => 1) do
      create_table :articles do |t|
        t.column :slug, :string
        t.column :title, :string
      end
    end
  end
end

def teardown_db
  ActiveRecord::Base.connection.tables.each do |table|
    ActiveRecord::Base.connection.drop_table(table)
  end
end

