# Copyright 2016 Liqwyd Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Top level module for the core Cyclid code.
module Cyclid
  # Module for the Cyclid API
  module API
    # Module for Cyclid Plugins
    module Plugins
      # Base class for Source plugins
      class Source < Base
        # Return the 'human' name for the plugin type
        def self.human_name
          'source'
        end

        # Process the source to produce a copy of the remote code in a
        # directory in the working directory
        def checkout(_transport, _ctx, _source = {})
          false
        end
      end
    end
  end
end

require_rel 'source/*.rb'
