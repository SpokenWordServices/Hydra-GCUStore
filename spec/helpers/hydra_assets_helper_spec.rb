require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe HydraAssetsHelper do
  describe "delete_asset_link" do
    it "should generate a delete link and confirmation dialog" do
      generated_html = helper.delete_asset_link("__PID__", "whizbang")
      generated_html.should have_tag 'a.inline[href=#delete_dialog]',  "Delete this whizbang"
      generated_html.should have_tag 'div#delete_dialog' do
        with_tag "p", "Do you want to permanently delete this article from the repository?"
        with_tag "form[action=?]", url_for(:action => "destroy", :controller => "assets", :id => "__PID__", :method => "delete")  do
          with_tag "input[type=hidden][name=_method][value=delete]"
          with_tag "input[type=submit]"
        end
      end
    end
  end
end