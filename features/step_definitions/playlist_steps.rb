When /^I add a Song to the playlist$/ do
  s = SearchResult.first
  c = Collection.first
  json = s.to_json
  put "/collections/#{c.id}/tracks.json", {}, :input => json
end

Then /^I should get the Playlist with all Tracks in return$/ do
  last_response.should be_ok
  json = JSON.parse(last_response.body)
  collection = json.shift
  collection["id"].should == Collection.first.id
  collection.should have_key("title")
  songs = json
  song = songs.first
  song["id"].should == Song.first.id
  song.should have_key("title")
  song.should have_key("tags")
  song["tags"].should be_kind_of(Array)
  (song["tags"].size > 1).should be_true
end

Given /^It's my birthday$/ do
end

When /^I create a playlist named "([^\"]*)"$/ do |title|
  @title = title
  post "/collections.json", {}, :input => { :title => @title }.to_json
end

Then /^I should get a Collection with an id in return$/ do
  last_response.should be_ok
  json = JSON.parse last_response.body
  json["id"].should_not be_nil
  json["title"].should == @title
end

Given /^a song exists with a title of "([^\"]*)"$/ do |title|
  c = Collection.first
  s = Factory(:song, :title => title)
  c.add_song s
end


When /^I want to see the playlist with tracks$/ do
  get "/collections/#{Collection.first.id}/tracks.json"
end

