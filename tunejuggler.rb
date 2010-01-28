RELEVANCE_THRESHOLD = (ENV["RELEVANCE_THRESHOLD"] || 0.5).to_f
Indexer.index
helpers do
  def read_body_as_json
    begin
      JSON.parse request.body.read.to_s
    rescue JSON::ParserError
      halt [400, {:error => "invalid JSON"}.to_json]
    end
  end
end

get "/api.json" do
#  "/collections.json"
#  api = { :collections => 
#          { :tracks => {
#            :methods => %w{get post put}
#            :required_attributes => %w{} }
#          }, 
#            :methods => %w{post put}, 
#            :required_attributes => %w{title} }
#    }
#  CODE

end

get "/blip/timeline/:user.json" do |user|
  additions = []

  blips = SearchResult.fetch_blip_timeline(user) do |blip|
    if blip.new? and blip.save
      additions << blip
    end
    blip
  end
  unless additions.empty?
    Resque.enqueue Indexer, additions
  end
  blips.to_json
end

get "/blip/:user.json" do |user|
  additions = []

  blips = SearchResult.fetch_blip_feed(user) do |blip|
    if blip.new? and blip.save
      additions << blip
    end
    blip
  end
  unless additions.empty?
    Resque.enqueue Indexer, additions
  end
  blips.to_json
end

get "/collections/latest.json" do
  collection = Collection.order(:updated_at.desc).first
  halt [404, {:error => :not_found}.to_json] unless collection
  collection.to_json
end

get "/collections/:id/tracks.json" do |id|
  c = Collection.find(id)
  [c, *c.songs].to_json
end

get "/player/:id" do |video_id|
  haml :player, {}, :video_id => video_id
end

post "/collections.json" do 
  json = read_body_as_json
  c = Collection.create json
  response.status = 201
  c.to_json
end

put "/collections/:id.json" do |id|
  json = read_body_as_json
  collection = Collection.find(:id => id)
  halt [404, {:error => :not_found}.to_json] unless collection
  collection.merge(json)
  collection
end

get "/collections.json" do
  Collection.all.to_json
end

delete "/collections/:id.json" do |id|
  collection = Collection.find(:id => id)
  halt [404, {:error => :not_found}.to_json] unless collection
  {:result => collection.destroy}.to_json
end


post "/collections/:id/tracks.json" do |id|
  response.status = 201
end

put "/collections/:collection_id/tracks/:id.json" do |collection_id, id|
  json = read_body_as_json
  c = Collection.find(:id => id)
  halt [404, "Collection not found"] if c.nil?
  s = Song.new json
  halt [400, "Song data invalid"] unless s.save
  c.add_song s
  c.save
  [c,*c.songs].to_json
end

post "/search.json" do 
  string = params[:query]
  if (results = Search.query(string)).empty?
    additions = []

    results = Search.query_youtube(string) do |result|
      if result.new? and result.save
        additions << result 
      end
    end

    unless additions.empty?
      Resque.enqueue(Indexer,additions)
    end
    Son

    results
  else
    results
  end.to_json
end
