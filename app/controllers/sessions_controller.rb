class SessionsController < ApplicationController

	def callback
		auth = request.env["omniauth.auth"]
		user = User.find_by_provider_and_uid(auth['provider'], auth['uid']) || User.create_with_omniauth(auth)
    session[:user_id] = user.id
    user, repo = session[:repo_name].split('/')
    redirect_to "/list?user=#{user}&repo=#{repo}"
	end

	def destroy
    session[:user_id] = nil
    redirect_to root_path
  end
end
