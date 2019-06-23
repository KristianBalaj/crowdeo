class StaticPagesController < ApplicationController
  def home
    @smth = ''
    begin
      @smth = $redis.get('test')
    rescue
      @smth = 'failed'
    end
  end
  def about
  end
end
