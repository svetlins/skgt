require 'skgt'
require 'json'

file = open 'cache', 'w'

file.write JSON::dump(Skgt::build_cache)

file.close
