migration "Create Collection table" do
  database.create_table :collections do
    primary_key :id
    String :title
    String :user
    String :tags
  end

end

class Collection < Sequel::Model
  one_to_many :songs
    
  def to_json
    json = {:id => self.id, :title => self.title}
    %w{user}.each do |a|
      value = self.method(a.to_sym).call
      json[a.to_sym] = value if value
    end
    if self.tags
      json[:tags] = self.tags.split(" ")
    end
    json.to_json
  end
end
