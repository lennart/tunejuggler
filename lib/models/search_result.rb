require 'net/http'
migration "Create Search Result table" do
  database.create_table :search_results do
    primary_key :id
    String :video_id, :unique => true
    String :title
    String :blip_id
    String :user
    String :url
    String :message
    String :timestamp
    String :artist
    String :embed_url
    String :tags
    integer :duration
  end
end

class SearchResult < Sequel::Model
  API_ROOT = URI.parse("http://api.blip.fm/blip/").freeze
  WEB_ROOT = URI.parse("http://beta.blip.fm/").freeze
  def to_json *args
    json = {:id => self.id, :title => self.title}
    %w{video_id blip_id artist embed_url duration url}.each do |a|
      value = self.method(a.to_sym).call
      json[a.to_sym] = value if value
    end
    if self.tags
      json[:tags] = self.tags
    end
    json.to_json
  end

  def save!
    raise unless self.save
  end

  def tags= new_tags
    if new_tags.kind_of?(Array)
      self[:tags] = tags.concat(new_tags.map {|t| t.gsub(/,/," ")}).join(",")
    else
      self[:tags] = tags.concat(new_tags.split(",")).join(",")
    end
    tags
  end

  def tags
    self[:tags] ? self[:tags].split(",") : []
  end

  class << self

    def fetch_blip_timeline username, always_save = true
      blip_list_parse = LibXML::XML::Parser.string web_perform("feed/#{username}")
      blip_list = blip_list_parse.parse.find_first("channel").find("//item")
      blip_list.map do |item|
        blip_uri = URI.parse URI.escape(item.find_first("link").content)
        blip_id = blip_uri.path.split("/")[4].to_i
        find_or_create_blip({"id" => blip_id}, always_save) do |blip|
          yield blip
        end
      end
    end

    def fetch_blip_feed username, offset = 0, always_save = true
      blips_raw = api_perform "getUserProfile.json", { :username => username, :offset => offset }
      blips = JSON.parse(blips_raw)["result"]["collection"]["Blip"]
      blips.select {|s| %w{youtubeVideo songUrl}.include?(s["type"]) }.map do |raw_blip|
        find_or_create_blip(raw_blip, always_save) do |blip|
          yield blip
        end
      end
    end

    def find_or_create_blip raw_blip, always_save = true
      blip = self[:blip_id => raw_blip["id"]]
      if blip
        yield blip
      else
        raw_blip = if raw_blip.has_key?("type")
                     raw_blip
                   else
                     raw_blip = fetch_raw_blip_by_id(raw_blip["id"])
                   end
        blip = case raw_blip["type"]
               when "youtubeVideo" then
                 if blip = self[:video_id => raw_blip["url"]]
                   blip.title = raw_blip["title"]
                   blip.blip_id = raw_blip["id"]
                   blip
                 else
                   self.new :title => raw_blip["title"], :blip_id => raw_blip["id"], :video_id => raw_blip["url"]
                 end
               when "songUrl" then
                 self.new :title => raw_blip["title"], :blip_id => raw_blip["id"], :url => raw_blip["url"]
               end
        blip.artist = raw_blip["artist"] unless raw_blip["artist"].blank?
        blip.tags = [raw_blip["genre"]] unless raw_blip["genre"].blank?
        blip.message = raw_blip["message"]
        blip.user = raw_blip["ownerId"]
        blip.timestamp = raw_blip["unixTime"]
        yield blip
        blip.save if always_save
        blip
      end
    end

    private

    def fetch_raw_blip_by_id id
      raw_blip = api_perform "getById.json", {:id => id}
      JSON.parse(raw_blip)["result"]["collection"]["Blip"].first
    end

    def web_perform path, query = {}
      url = web_root_url path, query
      perform url.host, url.path, url.query
    end

    def api_perform path, query = {}
      url = api_root_url path, query
      perform url.host, url.path, url.query
    end

    def perform host, path, query = ""
      Net::HTTP.start(host,80) do |http|
        http.get path+"?"+query.to_s
      end.body
    end

    def root_url kind, path_info, query = {}
      uri = case kind 
            when :api then
              URI.parse API_ROOT.to_s
            when :web then
              URI.parse WEB_ROOT.to_s
            else
              raise "Cannot Proceed without kind of root_url"
            end
      uri.query = query.map{|k,v| "#{URI.escape k.to_s}=#{URI.escape v.to_s}" }.join("&") unless query.empty?
      uri.path << path_info
      uri
    end

    #def raw_to_params raw_hash, mappings
    #  mappings.each do |classy,raw| 
    #    [classy, *raw_hash].each do |option|
    #      unless raw_hash.has_key?(option) and (value = raw_hash.delete(option)).blank?
    #        raw_hash[classy] ||= value unless value.blank?
    #      end
    #    end
    #  end
    #end

    def api_root_url path_info, query = {}
      root_url :api, path_info, query
    end

    def web_root_url path_info, query = {}
      root_url :web, path_info, query
    end
  end
end
