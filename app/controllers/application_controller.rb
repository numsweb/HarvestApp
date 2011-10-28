class ApplicationController < ActionController::Base
  protect_from_forgery
  @harvest=Harvest.new("numsweb", "s2000.coder@gmail.com", "polack")
  @harvest.do_connect
  GLOBAL_CONNECTION=@harvest
end
