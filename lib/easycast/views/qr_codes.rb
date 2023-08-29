module Easycast
  module Views
    #
    # Remote view, providing the context to remote.mustache
    #
    class QrCodes < View

      def title
        "QR Codes | Easycast"
      end

      def body_class
        "qr-codes"
      end

      def main_script
        "jQuery(function(){ showQRCodes(); });"
      end

    end
  end
end
