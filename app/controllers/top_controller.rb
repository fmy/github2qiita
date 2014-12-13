class TopController < ApplicationController
  require 'open-uri'
  require "qiita"

  def index
    referer = request.headers[:referer]
    #referer = 'https://github.com/fmy/qiita_docs'
    if /https:\/\/github\.com/ !~ referer
      render text: "error\nreferer: #{referer}"
      return
    end
    session[:repo_name] = referer.split('github.com/')[1]
  end

  def list
    @repo_name = session[:repo_name]
    data = URI.parse("https://api.github.com/repos/#{@repo_name}/contents/docs").read
    @files = ActiveSupport::JSON.decode data
  end

  def post
    client = Qiita::Client.new(access_token: current_user.token)
    client.connection.response :logger
    client.post("/api/v2/items",
      title: "Test",
      body: "Qiita APIでのテスト投稿",
      tweet: false,
      coediting: false,
      gist: false,
      private: false,
      tags: [
        {
          name: "test",
          versions: ["1.0.0"]
        }
      ]
    )
  end
end
