migration "Create Songs table" do
  database.create_table :songs do
    primary_key :id
    integer :position
    integer :collection_id
    text :json
  end
end

class Song < Sequel::Model
  many_to_one :collection
  def initialize *params 
    passed_keys = params.shift

    if passed_keys.is_a?(Hash) and passed_keys.has_key? :json
      super *(params.unshift(passed_keys))
    else
      super :json => params.unshift(passed_keys).to_json
    end
  end

  def content
    JSON.parse self.json
  end

  def to_json
    json = {:id => self.id}.merge(self.content)
    json.to_json
  end
end
