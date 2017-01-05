namespace :ota_searches do

  task :archive => :environment do

    Rails.logger.info "Archiving OTA Search into CSV and uploading into S3"

    aws = AWSService.new

      CSV.open("ota_search_archive.csv", "w") do |csv|
        csv << OTASearch.attribute_names
        OTASearch.where("created_at <= ? OR created_at is NULL", 3.days.ago.beginning_of_day).find_in_batches.with_index do |ota_searches_group, batch_no|
          Rails.logger.info "inserting records for batch #{batch_no} into csv"
          ota_searches_group.each do |ota|
            csv <<  ota.attributes.values
          end
        end
      end
      aws.upload_file("ota_search_archive.csv", "ota_search_archive_#{Time.now}.csv", "kaligo.logging/ota_search_archive")
      Rails.logger.info "File uploaded into S3"

    # Rails.logger.info "Deleting all batched records"
    # OTASearch.where("created_at <= ? OR created_at IS NULL", 3.days.ago.beginning_of_day).delete_all
    # Rails.logger.info "Batched records successfully deleted"
  end
end
