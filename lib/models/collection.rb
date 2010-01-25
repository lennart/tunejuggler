migration "Create Collection table" do
  database.create_table :collections do
    primary_key :id
    String :title
    String :user
    String :tags
    Time :created_at
    Time :updated_at
  end

end
class Collection < Sequel::Model
  plugin :timestamps, :update_on_create => true
  one_to_many :songs
    
  def to_json *args
    json = {:id => self.id, :title => self.title}
    %w{user}.each do |a|
      value = self.method(a.to_sym).call
      json[a.to_sym] = value if value
    end
    if self.tags
      json[:tags] = self.tags.split(",")
    end
    json.to_json
  end

  def tags= new_tags
    if new_tags.kind_of?(Array)
      self["tags"] = new_tags.map {|t| t.gsub(/,/," ")}.join(",")
    else
      self["tags"] = new_tags
    end
  end

  def save!
    raise unless self.save
  end
end
