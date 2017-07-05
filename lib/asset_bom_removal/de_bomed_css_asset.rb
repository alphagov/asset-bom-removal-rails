# object that has enough of the Sprockets::Asset API to be
# used in the Sprockets::Utils::Gzip class without us needing
# to use the real class which needs more data
module AssetBomRemoval
  class DeBomedCssAsset
    attr_reader :file_name

    def initialize(file_name)
      @file_name = file_name
    end

    def content_type
      'text/css'
    end

    def charset
      source.encoding.to_s
    end

    def source
      @source ||= File.read(file_name)
    end
  end
end
