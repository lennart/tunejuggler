
load 'lib/models/you_tube_video.rb'
load 'lib/workers/indexer.rb'
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
  [c, c.songs].to_json
end

post "/collections.json" do 
  c = Collection.create JSON.parse(params)
  c.to_json
end

put "/collections/:id/tracks.json" do |id|
  c = Collection.find(id)
  s = Song.create JSON.parse(params)
  c.add_song s
  c.save
  [c, c.songs].to_json
end



post "/search.json" do 
  if (results = Search.query(params[:query])).empty?
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

