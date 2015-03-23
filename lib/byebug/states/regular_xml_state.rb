module Byebug
  class RegularXmlState < RegularState

    def frame_mark(pos)
      (frame == pos).to_s
    end

  end
end
