module Fog
  module Compute
    class Hyperv
      class Real
        def set_vm_switch(options = {})
          run_shell('Set-VMSwitch', options)
        end
      end
    end
  end
end
