module Vix::Constants
  extend FFI::Library

  VixHandle = enum( :invalid_handle, 0 )

  VixHandleType = enum( :handle_type_none,                0,
                        :handle_type_host,                2,
                        :handle_type_vm,                  3,
                        :handle_type_network,             5,
                        :handle_type_job,                 6,
                        :handle_type_snapshot,            7,
                        :handle_type_property_list,       9,
                        :handle_type_metadata_container, 11 )

  VixPropertyType = enum( :property_type_any,     0,
                          :property_type_integer, 1,
                          :property_type_string,  2,
                          :property_type_bool,    3,
                          :property_type_handle,  4,
                          :property_type_int64,   5,
                          :property_type_blob,    6 )
  
  VixPropertyId = enum( :property_none,                                     0,
                        :property_meta_data_container,                      2,
                        :property_host_hosttype,                           50,
                        :property_host_api_version,                        51,
                        :property_vm_num_vcpus,                           101,
                        :property_vm_vmx_pathname,                        103,
                        :property_vm_vmteam_pathname,                     105,
                        :property_vm_memory_size,                         106,
                        :property_vm_read_only,                           107,
                        :property_vm_name,                                108,
                        :property_vm_guestos,                             109,
                        :property_vm_in_vmteam,                           128,
                        :property_vm_power_state,                         129,
                        :property_vm_tools_state,                         152,
                        :property_vm_is_running,                          196,
                        :property_vm_supported_features,                  197,
                        :property_vm_ssl_error,                           293,
                        :property_job_result_error_code,                 3000,
                        :property_job_result_vm_in_group,                3001,
                        :property_job_result_user_message,               3002,
                        :property_job_result_exit_code,                  3004,
                        :property_job_result_command_output,             3005,
                        :property_job_result_handle,                     3010,
                        :property_job_result_guest_object_exists,        3011,
                        :property_job_result_guest_program_elapsed_time, 3017,
                        :property_job_result_guest_program_exit_code,    3018,
                        :property_job_result_item_name,                  3035,
                        :property_job_result_found_item_description,     3036,
                        :property_job_result_shared_folder_const,        3046,
                        :property_job_result_shared_folder_host,         3048,
                        :property_job_result_shared_folder_flags,        3049,
                        :property_job_result_process_id,                 3051,
                        :property_job_result_process_owner,              3052,
                        :property_job_result_process_command,            3053,
                        :property_job_result_file_flags,                 3054,
                        :property_job_result_process_start_time,         3055,
                        :property_job_result_vm_variable_string,         3056,
                        :property_job_result_process_being_debugged,     3057,
                        :property_job_result_screen_image_size,          3058,
                        :property_job_result_screen_image_data,          3059,
                        :property_job_result_file_size,                  3061,
                        :property_job_result_file_mod_time,              3062,
                        :property_job_result_extra_error_info,           3084,
                        :property_found_item_location,                   4010,
                        :property_snapshot_displayname,                  4200,
                        :property_snapshot_description,                  4201,
                        :property_snapshot_powerstate,                   4205,
                        :property_guest_sharedfolders_shares_path,       4525,
                        :property_vm_encryption_password,                7001 )

  VixEventType = enum( :event_type_job_completed, 2,
                       :event_type_job_progress,  3,
                       :event_type_find_item,     8 )

  VixFileAttributes = enum( :file_attributes_directory, 1,
                            :file_attributes_directory, 2 )

  VixHostOptions = enum( :hostoption_verify_ssl_cert, 0x4000 )

  VixServiceProvider = enum( :serviceprovider_default,                    1,
                             :serviceprovider_vmware_server,              2,
                             :serviceprovider_vmware_workstation,         3,
                             :serviceprovider_vmare_player,               4,
                             :serviceprovider_vmware_vi_server,          10,
                             :serviceprovider_vmware_workstation_shared, 11 )

  VixApiVersion = enum( :api_version, -1 )
end
