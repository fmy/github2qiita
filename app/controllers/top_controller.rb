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

  def post
  end
end
