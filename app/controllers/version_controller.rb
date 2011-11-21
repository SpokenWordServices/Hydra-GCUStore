class VersionController < ApplicationController
  def index
    render :text=>"ActiveFedora: #{ActiveFedora::VERSION}\n" +
    "HydraHead: #{HydraHead::VERSION}"
  end
end
