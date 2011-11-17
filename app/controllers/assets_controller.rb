class AssetsController < ApplicationController
  include Hydra::Assets
  include Hull::AssetsControllerHelper
end
