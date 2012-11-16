require 'spec_helper'

class DelegateLogic
  include CrudModel::Delegation
  delegate_model :name, :to => :item
  attr_accessor :item
end

describe DelegateLogic do
  describe '.delegate_model' do
    it { should delegate(:name).to(:item) }
    it { should delegate(:name=).to(:item) }
    it { should delegate(:id).to(:item) }
    it { should delegate(:persisted?).to(:item) }
    it { should delegate(:new_record?).to(:item) }
  end

end
