require 'pp'
describe "A Track of a Playlist" do
  before do
    Song.dataset.delete
  end

  it "should store everything else than 'id' as json" do
    a = Song.create(:title => "Blurbiboy", :artist => "NewShit", :duration => 15, :video_id => "jkl233")
    json = JSON.parse(a.to_json)
    json["artist"].should == "NewShit"
    json["title"].should == "Blurbiboy"
  end

  it "should return parsed JSON content" do
    song = Factory.build(:song)
    song.save.should be_true
    song = Song.first
    song.content.should be_kind_of(Hash)
    song.content.should have_key("artist")
    song.content.should have_key("title")
  end

  it "should create a Song" do
    Factory(:song)
    Song.first.should_not be_nil
  end
end
