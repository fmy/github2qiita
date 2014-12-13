class TopController < ApplicationController
  def index
    @referer = request.headers[:referer]
    logger.info @referer
  end

  def post
  end
end
