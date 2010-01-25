describe "A Collection" do
  before :each do
    recreate_db
  end

  it "should add timestamp data when created" do
    params = Factory.attributes_for :collection
    collection = Collection.new params
    collection.save.should be_true
    collection.created_at.should be_kind_of(Time)
    collection.updated_at.should be_kind_of(Time)
  end
end
