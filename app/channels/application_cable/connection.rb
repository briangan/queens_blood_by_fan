module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user
    
    def connect
      self.current_user = find_verified_user
    end

    def disconnect
      # Any cleanup work needed when the cable connection is cut.
      # close(reason: nil, reconnect: true)
    end

    private
      def find_verified_user
        if verified_user = env['warden'].user
          verified_user
        else
          # You can find the reject_unauthorized_connection method here -> https://github.com/rails/rails/blob/master/actioncable/lib/action_cable/connection/authorization.rb
          reject_unauthorized_connection
        end
      end
  end
end
