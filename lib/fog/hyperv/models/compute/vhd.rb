module Fog
  module Compute
    class Hyperv
      class Vhd < Fog::Hyperv::Model
        identity :disk_identifier

        attribute :attached
        attribute :block_size
        attribute :computer_name
        attribute :disk
        attribute :file_size
        attribute :is_deleted
        attribute :minimum_size
        attribute :path, type: :string, default: 'New Disk'
        attribute :pool_name
        attribute :size, type: :integer, default: 343_597_383_68
        attribute :vhd_format, type: :enum, values: [:Unknown, nil, :VHD, :VHDX, :VHDSet]
        attribute :vhd_type, type: :enum, values: [:Unknown, nil, :Fixed, :Dynamic, :Differencing]
        # TODO? VM Snapshots?
        #

        # def identity_name
        #   :disk_identifier unless disk_identifier
        #   :disk_number if disk
        #   :path
        # end

        def real_path
          requires :path, :computer_name

          ret = path
          ret += '.vhdx' unless ret.downcase.end_with? '.vhdx'
          ret = host.virtual_hard_disk_path + '\\' + ret unless ret.downcase.start_with? host.virtual_hard_disk_path.downcase
          ret
        end

        def unc_path
          "\\\\#{computer_name || '.'}\\#{real_path.tr ':', '$'}"
        end

        def host
          requires :computer_name

          @host ||= begin
            ret = parent
            ret = service.hosts.get computer_name unless ret
            ret = ret.parent unless ret.is_a?(Host)
            ret
          end
        end

        def save
          requires :path, :computer_name, :size

          data = \
            if persisted?
              # Can't change much of a VHD
              attributes
            else
              service.new_vhd(
                computer_name: computer_name,
                path: real_path,

                block_size_bytes: block_size,
                size_bytes: size,

                _return_fields: self.class.attributes,
                _json_depth: 1
              )
            end

          merge_attributes(data)
          @old = dup
          self
        end

        def reload
          requires :computer_name
          requires_one :path, :disk

          data = service.get_vhd(
            computer_name: computer_name,
            path: path,
            disk_number: disk
          )
          merge_attributes(data.attributes)
          @old = data
          self
        end

        def destroy
          requires :path, :disk_identifier

          service.remove_item(
            path: unc_path
          )
        end
      end
    end
  end
end
