describe "A Track of a Playlist" do
  it "should store everything else than 'id' as json" do
    a = Song.create(:title => "Blurbiboy", :artist => "NewShit", :duration => 15, :video_id => "jkl233")
    json = JSON.parse(a.to_json)
    json["artist"].should == "NewShit"
    json["title"].should == "Blurbiboy"
  end
end
