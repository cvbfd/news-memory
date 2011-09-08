ENV['ARCHIVIST_ASSETS_PATH'] = "../webpages"
ENV['ARCHIVIST_SNAPSHOTS_PATH'] = "../data/snapshots"

require './news-memory'
run NewsMemory::Server

