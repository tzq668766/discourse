class Auth::TwitterAuthenticator < Auth::Authenticator

  def name
    "twitter"
  end

  # TODO twitter provides all sorts of extra info, like website/bio etc.
  #  it may be worth considering pulling some of it in.
  def after_authenticate(auth_token)

    result = Auth::Result.new

    data = auth_token[:info]

    result.username = screen_name = data["nickname"]
    result.name = name = data["name"]
    twitter_user_id = auth_token["uid"]

    result.extra_data = {
      twitter_user_id: twitter_user_id,
      twitter_screen_name: screen_name
    }

    user_info = TwitterUserInfo.where(twitter_user_id: twitter_user_id).first

    result.user = user_info.try(:user)

    result
  end

  def after_create_account(user, auth)
    data = auth[:extra_data]
    TwitterUserInfo.create(
      user_id: user.id,
      screen_name: data[:twitter_screen_name],
      twitter_user_id: data[:twitter_user_id]
    )
  end

end
