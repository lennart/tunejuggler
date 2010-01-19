RELEVANCE_THRESHOLD = (ENV["RELEVANCE_THRESHOLD"] || 0.5).to_f
Indexer.index
helpers do
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


get "/collections/:id/tracks.json" do |id|
  c = Collection.find(id)
  [c, *c.songs].to_json
end

post "/collections.json" do 
  json = JSON.parse(request.body.read.to_s)
  c = Collection.create json
  c.to_json
end

put "/collections/:id/tracks.json" do |id|
  data = request.body.read.to_s
  json = JSON.parse(data)
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

    results
  else
    results
  end.to_json
end

