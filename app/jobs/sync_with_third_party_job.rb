class SyncWithThirdPartyJob < ApplicationJob
    queue_as :default
  
    def perform(integration_id, syncable_type, syncable_id)
      integration = ThirdPartyIntegration.find(integration_id)
      syncable = syncable_type.constantize.find(syncable_id)
      
      sync_log = integration.sync_logs.create!(
        syncable: syncable,
        status: :pending
      )
      
      begin
        # Implement actual sync logic based on the integration type
        case integration.name.downcase
        when 'erp_system'
          sync_with_erp(integration, syncable)
        when 'accounting_system'
          sync_with_accounting(integration, syncable)
        else
          raise "Unknown integration type: #{integration.name}"
        end
        
        sync_log.update(status: :success, response: 'Sync completed successfully')
      rescue => e
        sync_log.update(status: :failed, response: e.message)
        raise e # Re-raise to allow retry mechanism
      end
    end
  
    private
  
    def sync_with_erp(integration, syncable)
      # Implement ERP system specific sync logic
      # Example using HTTParty for API calls
      response = HTTParty.post(
        "#{integration.base_url}/api/orders",
        headers: {
          'Authorization' => "Bearer #{integration.api_key}",
          'Content-Type' => 'application/json'
        },
        body: syncable.to_json(include: :order_items)
      )
      
      unless response.success?
        raise "ERP Sync failed: #{response.body}"
      end
    end
  
    def sync_with_accounting(integration, syncable)
      # Implement accounting system specific sync logic
      # Similar to sync_with_erp but with accounting system specifics
    end
  end