require 'spec_helper'

describe ItemNameChanger do
  include SetupItemNameChanger

  it { should be }

  describe '.delegate_model' do
    it { should delegate(:name).to(:item) }
    it { should delegate(:name=).to(:item) }
    it { should delegate(:id).to(:item) }
    it { should delegate(:persisted?).to(:item) }
    it { should delegate(:new_record?).to(:item) }
  end

  describe '.wrap_class' do
    subject { ItemNameChanger.wrap_class }
    it { should == Item }
  end

  it { Item.all.should have(3).items }

  describe '.all' do
    subject { ItemNameChanger.all }
    it { should have(3).items }
    specify { subject.should be_all{|o| o.is_a? ItemNameChanger }}
    specify { subject.should be_all{|o| o.item.is_a? Item }}
  end

  describe '.find' do
    subject { ItemNameChanger.find(1) }
    it { should be_a ItemNameChanger }
    it { should be_persisted }
    describe '#item' do
      subject { ItemNameChanger.find(1).item }
      its(:id) { should == 1 }
    end
  end

  describe '.new' do
    context 'with attributes :name => "xxx"' do
      subject { ItemNameChanger.new(name: 'xxx') }
      describe ".name" do
        specify { subject.name.should == 'xxx' }
      end
      describe ".item.name" do
        specify { subject.item.name.should == 'xxx' }
      end
      it { should_not be_persisted }
    end
  end

  describe '.wrap' do
    context 'with Item.find(2)' do
      subject { ItemNameChanger.wrap(Item.find(2)) }
      it { should be_a ItemNameChanger }
      describe "#id" do
        specify { subject.id.should == 2 }
      end
    end
  end

  describe '.wrap_all' do
    context 'with Item.all' do
      subject { ItemNameChanger.wrap_all(Item.all) }
      it { should be_a Array }
      describe 'first' do
        specify { subject.first.should be_a ItemNameChanger }
        specify ".item" do
          subject.first.item.should be_a Item
        end
      end
    end
  end

  describe '#attributes=' do
    let(:obj) { ItemNameChanger.find(1) }
    let(:attrs) { {name: 'xxx', price: 999, omg: '???' } }
    before { obj.attributes = attrs }
    subject { obj }

    specify "name is delegated to item" do
      obj.item.name.should == 'xxx'
    end
    specify "price is not delegated to item" do
      obj.item.price.should_not == 999
    end
  end

  describe '#update_attributes' do
    let(:obj) { ItemNameChanger.find(1) }
    let(:attrs) { {name: 'xxx', price: 999, omg: '???' } }
    before { obj.update_attributes(attrs) }
    subject { obj.item.reload }

    specify "name is delegated to item" do
      subject.name.should == 'xxx'
    end
    specify "price is not delegated to item" do
      subject.price.should_not == 999
    end
  end

  describe '#save' do
    let(:obj) { ItemNameChanger.find(1) }

    context 'when valid' do
      before do
        obj.name = 'xxx'
      end
      subject { obj.save }

      it { should be_true }
      specify "name is delegated to item" do
        ItemNameChanger.find(1).name.should == 'xxx'
      end
    end

    context 'when invalid' do
      before do
        obj.name = ''
      end
      subject { obj.save }

      it { should be_false }
      specify "name is not saved" do
        ItemNameChanger.find(1).name.should_not == ''
      end

      describe 'errors' do
        before { obj.save }
        subject { obj.errors }

        it { should have(1).item }
        specify { subject[:name].should_not be_empty }

      end
    end
  end

end
