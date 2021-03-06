module Fog
  module Compute
    class Hyperv
      class Real
        def set_vm_network_adapter(options = {})
          requires_one options, :vm_name, :management_os
          run_shell('Set-VMNetworkAdapter', options)
        end
      end
    end
  end
end
