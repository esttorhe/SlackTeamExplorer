require 'keyring_liberator'
require 'keyring'
require 'name_whisperer'
require 'shellwords'

module Pod
  class Command
    class Keys
      class Rm < Keys
        self.summary = 'Remove a key-value pair from a project.'

        self.description = <<-DESC
            Remove a key, and it's value from a project

            A second optional operator can be done to force a project name.
        DESC

        self.arguments = [CLAide::Argument.new('key', true), CLAide::Argument.new('project_name', false)]

        def initialize(argv)
          @key_name = argv.shift_argument
          @project_name = argv.shift_argument
          super
        end

        def validate!
          super
          verify_podfile_exists!
          help! 'A key name is required for lookup.' unless @key_name
        end

        def run
          keyring = get_current_keyring
          unless keyring
            raise Informative, 'Could not find a project to remove the key from.'
          end

          if keyring.keys.include? @key_name
            keyring.save(@key_name, '')
            keyring.keys.delete @key_name
            CocoaPodsKeys::KeyringLiberator.save_keyring(keyring)

            prefix = CocoaPodsKeys::Keyring.keychain_prefix
            login = prefix + keyring.name
            delete_generic = `security delete-generic-password -a #{@key_name.shellescape} -l #{login.shellescape} 2>&1`

            if delete_generic.include? 'security: SecKeychainSearchCopyNext: The specified item could not be found in the keychain.'
              raise Informative, "Removed value for #{@key_name}, but could not delete from Keychain."
            elsif delete_generic.include? 'password has been deleted.'
              raise Informative, "Removed value for #{@key_name}, and deleted associated key in Keychain."
            else
              raise Informative, "Removed value for #{@key_name}."
            end
          else
            raise Informative, "Could not find key named #{@key_name}."
          end
        end

        def get_current_keyring
          current_dir = Pathname.pwd
          keyring = CocoaPodsKeys::KeyringLiberator.get_keyring current_dir
          if !keyring && @project_name
            return CocoaPodsKeys::KeyringLiberator.get_keyring_named @project_name
          end
          keyring
        end
      end
    end
  end
end
