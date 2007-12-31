module SeleniumOnRails
  module Paths

    # SeleniumOnRails was working around Rails not supporting absolute paths for layout templates.
    # The work-around was failing w/ Rails 2.0, but Rails now supports absolute paths for layout templates.
    def layout_path
      Pathname.new view_path('layout')
    end

  end
end
