describe "A Search Result" do
  it "should set correct attributes from raw blip" do
    raw_blip = 
{"reblipId"=>"", "artist"=>"Kings of Leon", "toId"=>"", "title"=>"King of the Rodeo (Rock in Rio)", "via"=>"YouTube", "unixTime"=>"1263484081", "url"=>"yJzN_WYIZMs", "viaUrl"=>"http://www.youtube.com/watch?v=yJzN_WYIZMs&feature=youtube_gdata", "id"=>"32182472", "bitrate"=>"", "thumbplayLink"=>"", "type"=>"youtubeVideo", "genre"=>"alternativepunk", "replyId"=>"", "insTime"=>"2010-01-14 15:48:01", "ownerId"=>"374032", "ownerUrlName"=>"lmaa", "status"=>"active", "message"=>"dap dap dap dap dap [reply]wir[/reply] dap dap dap [reply]misterque[/reply] dap [reply]ZackDolore[/reply] dap dap [reply]sinamagslaut[/reply] dap dap [reply]sk8y_kati[/reply] dap dap [reply]froileinwunder[/reply] dap dap [reply]Lischen[/reply] dap", "owner"=>{"lastBlipTime"=>"2010-01-20 05:24:04", "name"=>"", "updateTime"=>"2010-01-20 13:24:04", "timeZone"=>"Europe/Berlin", "profilePic"=>"http://pics02.bliptastic.com/374-374032.jpeg", "id"=>"374032", "insTime"=>"2009-05-30 00:36:41", "website"=>"http://lmaa.posterous.com", "countryAbbr"=>"de", "urlName"=>"lmaa", "listeners"=>"51", "status"=>"active"}}

    blip = SearchResult.find_or_create_blip raw_blip do |b|
      b
    end
    blip.title.should == "King of the Rodeo (Rock in Rio)"
    blip.artist.should == "Kings of Leon"
    blip.video_id.should == "yJzN_WYIZMs"
    blip.message == "dap dap dap dap dap [reply]wir[/reply] dap dap dap [reply]misterque[/reply] dap [reply]ZackDolore[/reply] dap dap [reply]sinamagslaut[/reply] dap dap [reply]sk8y_kati[/reply] dap dap [reply]froileinwunder[/reply] dap dap [reply]Lischen[/reply] dap"
    blip.user.should == "374032"
    blip.timestamp.should == "1263484081"
    blip.tags.should include("alternativepunk")
  end
end
