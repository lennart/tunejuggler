class Indexer
  @queue = :index
  class << self

    def field_infos
        field_infos = Ferret::Index::FieldInfos.new(:term_vector => :no,
                                                    :store => :no, 
                                                    :index => :untokenized_omit_norms)
        field_infos.add_field(:title, :store => :yes, :index => :yes, :boost => 10.0)
        field_infos.add_field(:video_id, :store => :yes, :index => :yes, :boost => 15.0)
        field_infos.add_field(:tags, :store => :yes, :index => :yes, :boost => 0.1)
        field_infos.add_field(:doc_id, :store => :yes, :index => :no)
    end

    def index
      unless @index
        @index = Ferret::I.new(:path => INDEX_PATH, :field_infos => field_infos)
      end
      @index
    end


    def perform args
      additions = args
      additions.each do |result|
        index << {
          :video_id => result["video_id"],
          :doc_id => result["id"],
          :title => result["title"],
          :tags => result["tags"]
        } 
      end
      puts "Index contains #{index.size} documents"
    end
  end
end
