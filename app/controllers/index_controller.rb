class IndexController < ApplicationController
  def main
    #Set RTUser id session but this has te be changed in the future. Modify User table to save the id.
    @rtuser = Rtuser.find_by_EmailAddress(current_user.email)
    session[:rtuser_id] = @rtuser.id
  end
end
