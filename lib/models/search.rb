class Search
  class << self
    def query phrase
      results = []

      fields = [:title,:tags,:video_id, :doc_id, :artist,:blip_id,:user]
      query_parser = Ferret::QueryParser.new(:fields => fields, :default_field => :title)
      current_searcher = searcher
      parsed_query = query_parser.parse("title|tags|video_id|blip_id|artist|user:*#{phrase}*")
      current_searcher.search_each(parsed_query) do |id, score|
        doc_id = current_searcher[id][:doc_id]
        video = SearchResult[doc_id]
        puts "found #{id} with doc_id #{doc_id} and video #{video} and Score of #{score}"
#        puts current_searcher.explain(parsed_query,id).to_s
        if score > RELEVANCE_THRESHOLD
          results << video
        else
          puts "Omitting result for #{score} is lower than Relevance Threshold #{RELEVANCE_THRESHOLD}"
        end
      end
      results
    end


    def searcher
      reader = Ferret::Index::IndexReader.new(INDEX_PATH)
      Ferret::Search::Searcher.new(reader)
    end

    def prepare_query phrase
      query = phrase
      begin
        uri = URI.parse phrase
        params = Rack::Utils.parse_query(uri.query)
        case uri.host
        when /blip\.fm$/ then
          blocks = path.split("/")
          break unless blocks.shift == "profile"
          blocks.shift
          break unless blocks.shift == "blip"
          potential_id = blocks.shift
          query = potential_id if potential_id.to_i != 0
        when /youtube\.com/ then
          query = params["v"] if uri.host == "www.youtube.com"
        end
      rescue URI::InvalidURIError 
      end
      query
    end

    def query_youtube string
      client = YouTubeG::Client.new
      videos = client.videos_by(:query => string).videos
      videos.map do |v|
        v.video_id =~ /\/([^\/]*)\Z/
          video_id = $1
        if video = SearchResult[:video_id => video_id]
          video
        else
          params = {:video_id => video_id, 
            :title => v.title,
            :duration => v.duration,
            :embed_url => v.embed_url,
            :tags => v.keywords}
          video = SearchResult.new params

          yield video

          video.save
          video
        end
      end
    end

    def query_database string, limit = nil
    end
  end
end
