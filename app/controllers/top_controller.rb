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
  end

  def list
    if params[:user].blank? || params[:repo].blank?
      redirect_to root_path
      return
    end
    @user = params[:user]
    @repo = params[:repo]
    @repo_name = "#{@user}/#{@repo}"
    data = URI.parse("https://api.github.com/repos/#{@repo_name}/contents/docs").read
    @files = ActiveSupport::JSON.decode data
  end

  # https://api.github.com/repos/fmy/qiita_docs/git/blobs/72ce993fba8ce7dfef2c2b93628e6fa7628a75f3?access_token=ea47a81fa25aa27a0dce31aad11b600eb55e276d

  def post

    body = Base64.decode64("IyB0ZXN0CmFhYQoKW2dvb2dsZV0oaHR0cHM6Ly9nb29nbGUuY29tLykK ")

    body << "この投稿は[Github :point_right: Qiita](https://github2qiita.herokuapp.com/)から投稿されました。"

    client = Qiita::Client.new(access_token: current_user.token)
    client.connection.response :logger
    client.post("/api/v2/items",
      title: "Test",
      body: body,
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
