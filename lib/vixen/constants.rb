module Vixen::Constants
  extend FFI::Library

  VixHandle = enum( :invalid, 0 )

  VixHandleType = enum( :none,                0,
                        :host,                2,
                        :vm,                  3,
                        :network,             5,
                        :job,                 6,
                        :snapshot,            7,
                        :property_list,       9,
                        :metadata_container, 11 )

  VixPropertyType = enum( :any,     0,
                          :integer, 1,
                          :string,  2,
                          :bool,    3,
                          :handle,  4,
                          :int64,   5,
                          :blob,    6 )

  VixError = enum( :ok, 0 )

  VixPropertyId = enum( :none,                                     0,
                        :meta_data_container,                      2,
                        :host_hosttype,                           50,
                        :host_api_version,                        51,
                        :vm_num_vcpus,                           101,
                        :vm_vmx_pathname,                        103,
                        :vm_vmteam_pathname,                     105,
                        :vm_memory_size,                         106,
                        :vm_read_only,                           107,
                        :vm_name,                                108,
                        :vm_guestos,                             109,
                        :vm_in_vmteam,                           128,
                        :vm_power_state,                         129,
                        :vm_tools_state,                         152,
                        :vm_is_running,                          196,
                        :vm_supported_features,                  197,
                        :vm_ssl_error,                           293,
                        :job_result_error_code,                 3000,
                        :job_result_vm_in_group,                3001,
                        :job_result_user_message,               3002,
                        :job_result_exit_code,                  3004,
                        :job_result_command_output,             3005,
                        :job_result_handle,                     3010,
                        :job_result_guest_object_exists,        3011,
                        :job_result_guest_program_elapsed_time, 3017,
                        :job_result_guest_program_exit_code,    3018,
                        :job_result_item_name,                  3035,
                        :job_result_found_item_description,     3036,
                        :job_result_shared_folder_const,        3046,
                        :job_result_shared_folder_host,         3048,
                        :job_result_shared_folder_flags,        3049,
                        :job_result_process_id,                 3051,
                        :job_result_process_owner,              3052,
                        :job_result_process_command,            3053,
                        :job_result_file_flags,                 3054,
                        :job_result_process_start_time,         3055,
                        :job_result_vm_variable_string,         3056,
                        :job_result_process_being_debugged,     3057,
                        :job_result_screen_image_size,          3058,
                        :job_result_screen_image_data,          3059,
                        :job_result_file_size,                  3061,
                        :job_result_file_mod_time,              3062,
                        :job_result_extra_error_info,           3084,
                        :found_item_location,                   4010,
                        :snapshot_displayname,                  4200,
                        :snapshot_description,                  4201,
                        :snapshot_powerstate,                   4205,
                        :guest_sharedfolders_shares_path,       4525,
                        :vm_encryption_password,                7001 )

  VixEventType = enum( :job_completed, 2,
                       :job_progress,  3,
                       :find_item,     8 )

  VixFileAttributes = enum( :directory, 1,
                            :symlink,   2 )

  VixHostOptions = enum( :verify_ssl_cert, 0x4000 )

  VixServiceProvider = enum( :default,                    1,
                             :vmware_server,              2,
                             :vmware_workstation,         3,
                             :vmare_player,               4,
                             :vmware_vi_server,          10,
                             :vmware_workstation_shared, 11 )

  VixApiVersion = enum( :api_version, -1 )

  VixFindItemType = enum( :running_vms,    1,
                          :registered_vms, 4 )

  VixVMOpenOptions = enum( :normal, 0x0 )
end
