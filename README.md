tuneJuggler
===========

Finally lets you  

* list user's __blip.fm__ feed and timeline  
* perform locally cached searches to 
    * __youtube__
    * already shown blips
* build playlists from 
    * search results
    * blips
    * (hopefully soon) direct **HTTP** links
    * (hopefully soon) _local and local_ network files

Requirements
------------

* ruby _(should be running on 1.9 as well, but untested up to now)_
* redis _(to manage search index updates asynchronously)_
* sadly lots of gems, namely
    * resque
    * sinatra
    * ferret
    * youtube-g
    * sequel
    * sinatra-sequel
    * libxml-ruby
    * json

Getting started
---------------
fire up a passenger, thin, webrick or mongrel to run the tunejuggler using `config.ru`. To start the indexer (which is needed to cache the results) run `QUEUE=* rake resque:work`

What **tuneJuggler** isn't
--------------------------

A frontend. This is just a simple webservice, that is hopefully **RESTful**.  
[FrancisVarga](http://github.com/FrancisVarga) is right now writing a frontend in __ActionScript 3__ using the __Flex 4 SDK__, 
but the API for __tuneJuggler__ is really simple and can be hooked up with almost anything that speaks
__HTTP__ and handles __JSON__. 

Usage
-----

__POST__ 

* `/search.json`  
    Search locally, or if necessary over at youtube  
    __body__ `:query` => search_string

* `/collections.json`  
    Create a new Collection in the Database  
    * __body__ JSON-encoded Collection-Object  
         __Properties:__ 
         * title:String
         * tags:Array  

__PUT__

* `/collections/:id/tracks.json`  
    Add a Song to an existing Collection  
     * __body__ JSON-encoded Song-Object
         __Properties:__
         * title:String
         * tags:Array
         * artist:String  
         _(Note: you can optionally supply any other properties you want to store along with the song)_

__GET__

* `/blip/:user.json`  
    List a DJ's recent blips  
    __params__ `:user` => __blip.fm__ DJ username

* `/blip/timeline/:user.json`  
    List a DJ's timeline (own and his favorite DJ's blips)  
    __params__ `:user` => __blip.fm__ DJ username

