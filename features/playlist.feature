Feature: Build a Playlist
  
  Scenario: Someone wants to see the party playlist
    Given a collection exists with a title of "Partytime"
    Given a song exists with a title of "Paul Kalkbrenner - Sky & Sand"
    When I want to see the playlist with tracks
    Then I should get the Playlist with all Tracks in return

  Scenario: Partytime at our house
    Given a collection exists with a title of "Partytime"
    Given a search result exists with a title of "Paul Kalkbrenner - Sky & Sand"
    When I add a Song to the playlist
    Then I should get the Playlist with all Tracks in return

  Scenario: There is an upcoming party
    Given It's my birthday
    When I create a playlist named "Lenni's Birthday Party Playlist"
    Then I should get a Collection with an id in return
