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
      super :json => passed_keys.to_json, *params
    end
  end

  def method_missing id, *args
    if id.to_s =~ /\A(.*)=\Z/
      key = $1
      self[key] = *args
    end
  end

  def []= key, value
    unless %w{json id collection_id position}.include?(key.to_s)
      current_content = self.content
      current_content[key] = value
      self.content = current_content
    else
      if key == "tags"
        if value.kind_of?(Array)
          super key, value.map{|t| t.gsub(/,/," ")}.join(",")
        else
          super key, value
        end
      end

      super key, value
    end
  end

  def content
    begin
      JSON.parse self.json
    rescue JSON::ParserError
      return {}
    end
  end

  def content= attributes
    self.json = attributes.to_json
  end

  def to_json *args
    json = {:id => self.id}.merge(self.content)
    json.to_json
  end
end
