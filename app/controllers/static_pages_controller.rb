class StaticPagesController < ApplicationController
  def contact
  end

  def tester
    redirect_to root_path, notice: 'StaticPagesController: No such tester defined.'
  end
end
