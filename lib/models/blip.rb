class Blip < Hash
  include ::CouchRest::CastedModel
  class AttributeError < RuntimeError
  end
  property :message
  property :uid
  property :time, :cast_as => "Time"
  property :user
  property :reblip_id
  property :title
  property :source
  property :url
  property :video_id
  property :embed_url
  include DuckTypedDesignDoc
  ducktype_traits :uid, :time, :user
  include ::CouchRest::Validation
  include CouchRest::Callbacks
  include MorphableDocument
  include HasArtist

  view_by :uid, :ducktype => true
  view_by :url
  view_by :video_id
  view_by :date_and_title, :map => <<MAP
function(doc) {
  if (#{ducktype_traits_js}) {
    emit([new Date(doc['time']),doc['title']],1);
  }
}
MAP
  view_by :date_and_user, :map => <<MAP
function(doc) {
  if (#{ducktype_traits_js}) {
    emit([new Date(doc['time']),doc['user']],1);
  }
}
MAP

  validates_presence_of :uid
  validates_with_method :uid_valid?
#  validates_with_method :artist_present?
  validates_presence_of :time
  validates_presence_of :user
  validates_presence_of :title
  validates_presence_of :source
  #timestamps!


  def blip_time(format = :timestamp)
    if format == :timestamp
      self["time"].nil? ? nil : self["time"].to_i
    else
      self["time"]
    end
  end

  def blip_time= new_age
    return if new_age.blank?
    if new_age
      self["time"] = if new_age.kind_of?(Integer) or new_age.to_i != 0
        Time.at new_age.to_i
      elsif new_age.kind_of? String
        Time.parse new_age
      else
        raise "Cannot use this: #{new_age} as Blip Time"
      end
    end
  end

  def blip_id= new_id
    self["uid"] = new_id.to_i unless new_id.blank?
  end

  def uid_valid?
    return false if self["uid"] == 0
    true
  end

  def artist_present?
    return false if self.written_by.empty?
    true
  end





  def initialize blip = {}
    raw_to_blip blip, {"time" => "unixTime", 
      "user" => "ownerId",
      "uid" => "id",
      "reblip_id" => "reblipId"
    }
    case blip.delete("type")
    when "youtubeVideo" then
      blip["video_id"] ||= blip.delete("url")
      blip["source"] = "YouTube"
      blip["embed_url"] = "http://"+YouTubeVideo::YOUTUBE+"/v/#{blip["video_id"]}&feature=youtube_gdata"
    when "songUrl" then
      blip["source"] = "HTTP"
    end
    %w{thumbplayLink genre owner toId via viaUrl replyId status insTime}.each do |key|
      blip.delete key
    end
    super blip
  end

end
