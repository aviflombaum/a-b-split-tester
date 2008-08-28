# remember to include AbSplitTestControllerMethods in ApplicationController
module AbSplitTestHelper
  def ab_google_analytics_urchin_tracker
    if @ab_split_test_treatment
      google_analytics_urchin_tracker(request.request_uri + @ab_split_test_treatment)
    end
  end
end

ActionView::Base.send :include, AbSplitTestHelper