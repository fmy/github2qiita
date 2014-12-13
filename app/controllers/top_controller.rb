class TopController < ApplicationController
  require 'open-uri'
  require "qiita"

  def index
    referer = request.headers[:referer]
    #referer = 'https://github.com/fmy/qiita_docs'
    if /https:\/\/github\.com/ !~ referer
      render :welcome
      return
    end
    session[:repo_name] = referer.split('github.com/')[1]
    redirect_to '/auth/qiita'
  end

  def list
    if params[:user].blank? || params[:repo].blank?
      redirect_to root_path
      return
    end
    @user = params[:user]
    @repo = params[:repo]
    @repo_name = "#{@user}/#{@repo}"
    data = URI.parse("https://api.github.com/repos/#{@repo_name}/contents/docs?access_token=ea47a81fa25aa27a0dce31aad11b600eb55e276d").read
    json = ActiveSupport::JSON.decode data
    @files = []
    json.each do |file|
      if /.*\.md/ =~ file['name']
        file['name'] = file['name'].split('.')[0]
        @files << file
      end
    end

  end

  # https://api.github.com/repos/fmy/qiita_docs/git/blobs/72ce993fba8ce7dfef2c2b93628e6fa7628a75f3?access_token=ea47a81fa25aa27a0dce31aad11b600eb55e276d

  # http://0.0.0.0:3000/post?user=fmy&repo=qiita_docs&file=72ce993fba8ce7dfef2c2b93628e6fa7628a75f3

  def post
    @user = params[:user]
    @repo = params[:repo]
    @file = params[:file]
    @title = params[:title]
    @repo_name = "#{@user}/#{@repo}"
    data = URI.parse("https://api.github.com/repos/#{@repo_name}/git/blobs/#{@file}?access_token=ea47a81fa25aa27a0dce31aad11b600eb55e276d").read

    @file = ActiveSupport::JSON.decode data

    body = Base64.decode64(@file['content']).force_encoding('UTF-8')
    body << "<br/> この投稿は[Github :point_right: Qiita](https://github2qiita.herokuapp.com/)から投稿されました。"

    logger.info(body)

    client = Qiita::Client.new(access_token: current_user.token)
    client.connection.response :logger
    client.post("/api/v2/items",
      title: @title,
      body: body,
      tweet: false,
      coediting: false,
      gist: false,
      private: false,
      tags: [
        {
          name: "Qiita",
          versions: ["1.0.0"]
        },
        {
          name: "Github",
          versions: ["1.0.0"]
        },
        {
          name: "hackathon",
          versions: ["1.0.0"]
        }
      ]
    )

    redirect_to "http://qiita.com/#{current_user.screen_name}"
  end
end
