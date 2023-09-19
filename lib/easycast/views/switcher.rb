module Easycast
  module Views
    #
    # Switcher view, providing the context to switcher.mustache
    #
    class Switcher < View

      def title
        "Switcher | Easycast"
      end

      def body_class
        "switcher"
      end

      def source_folders
        Easycast.each_scenes_folder.map do |folder|
          current = Easycast.current_scenes_folder.readlink.expand_path
          {
            css_class: (folder.expand_path == current.expand_path ? 'active' : nil),
            code: Digest::SHA1.hexdigest(folder.expand_path.to_s),
            name: folder.basename.to_s,
          }
        end
      end

      def restart_href
        "/restart"
      end

      def reboot_href
        "/reboot"
      end

      def upgrade_href
        "/upgrade"
      end

      def main_script
        "jQuery(function(){ refresh(#{state_json}, refreshSwitcher); });"
      end

    end
  end
end
