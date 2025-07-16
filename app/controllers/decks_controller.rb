class DecksController < InheritedResources::Base

  private

    def deck_params
      params.require(:deck).permit(:name)
    end

end
