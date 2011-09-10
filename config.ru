ENV['ARCHIVIST_ASSETS_PATH'] = "webpages"
ENV['ARCHIVIST_SNAPSHOTS_PATH'] = "public/snapshots"

ENV['DATABASE_URL'] = 'postgres://archivist:archivist@localhost/news-archivist'
ENV['OPENID_URI'] = 'http://archiloque-openid.myopenid.com/'
ENV['GRAPHICS_MAGICK_PATH'] = "/usr/local/bin"
ENV['PHANTOMJS_PATH'] = "/Applications/phantomjs.app/Contents/MacOS/phantomjs"

require './news-memory'
run NewsMemory::Server

