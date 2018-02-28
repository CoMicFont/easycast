require 'easycast'
require 'rspec'
require 'rack/test'

RSpec::Matchers.define :allow_cache do |hs|
  match do |actual|
    hs.all?{|h| not(actual[h].nil?) } && \
    (actual['Cache-Control'] =~ /public, max-age=3600, must-revalidate/)
  end
end

RSpec::Matchers.define :disallow_cache do
  match do |actual|
    actual['Cache-Control'] =~ /no-cache, no-store, max-age=0, must-revalidate/
  end
end
