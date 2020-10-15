require 'configatron'

configatron.amqp.lims_id = 'SQSCP'

configatron.team_name = 'LIMS and Informatics'
configatron.team_url = 'http://www.sanger.ac.uk/science/groups/production-software-development'

configatron.accession_samples = false

configatron.accession do |accession|
  accession.url = 'http://localhost:9999/accession_service/'
  accession.view_url = 'http://localhost:9999/view_accession/'
  accession.ega.user = 'ega_accession_login'
  accession.ega.password = 'ega_accession_password'
  accession.ena.user = 'era_accession_login'
  accession.ena.password = 'era_accession_password'
end

configatron.admin_email = 'admin@test.com'
configatron.ssr_emails = ['ssr@example.com']

configatron.authentication = ENV.fetch('AUTH', 'local')

configatron.pmb_api = 'http://localhost:9292/v1'
configatron.register_printers_automatically = true

configatron.default_policy_text = 'https://www.example.com/'
configatron.default_policy_title = 'Default Policy Title'
configatron.fluidigm_data.source = 'directory'
configatron.fluidigm_data.directory = "#{Rails.root}/data/fluidigm"
configatron.irods_audience = 'http://localhost:3000'
configatron.mail_prefix = '[DEVELOPMENT]'
configatron.phix_tag.tag_map_id = 888
configatron.r_and_d_division = 'RandD'
configatron.site_url = 'localhost:3000'
configatron.sta_plate_purpose_name = 'STA'
configatron.taxon_lookup_url = 'http://eutils.ncbi.nlm.nih.gov/entrez/eutils/'
configatron.swipecard_pmb_template = 'swipecard_barcode_template'

configatron.help_link_base_url = 'https://ssg-confluence.internal.sanger.ac.uk/display/PSDPUB'

configatron.external_applications = [
  ['High Throughput Pipeline', 'http://www.example.com'],
  ['Generic Lims', 'http://www.example.com'],
  ['Gatekeeper', 'http://www.example.com']
]

configatron.help_link_base_url = 'http://wwww.example.com'

if Rails.env.development? || Rails.env.profile?

  configatron.asset_audits_url = 'http://localhost:3014/process_plates/new'

  configatron.invalid_policy_url_domains = []

  configatron.delayed_job.study_report_priority = 100
  configatron.delayed_job.submission_process_priority = 0

  configatron.disable_accession_check = true
  configatron.disable_api_authentication = true

  configatron.ldap_port = 13890
  configatron.ldap_secure_port = 6360
  configatron.ldap_server = 'localhost'

  configatron.pipelines_url = 'http://localhost:3000'

  configatron.plate_barcode_service = 'http://localhost:3011'
  configatron.plate_volume_files = "#{Rails.root}/data/plate_volume/"

  configatron.proxy = 'http://example.com'

  configatron.taxon_lookup_url = 'http://eutils.ncbi.nlm.nih.gov/entrez/eutils/'

  configatron.tecan_precision = 2
  configatron.beckman_precision = 2
  configatron.hamilton_precision = 2
  configatron.uploaded_spreadsheet.max_number_of_samples = 384

  configatron.data_sharing_contact.name = 'John Doe'
  configatron.data_sharing_contact.email = 'foo'
  configatron.accession_local_key = 'abc'
  configatron.sequencescape_email = 'sequencescape@example.com'
  configatron.default_email_domain = 'example.com'
  configatron.run_information_url = 'http://example.com/'
  configatron.sso_logout_url = 'https://example.com/logout'
  configatron.run_data_by_batch_id_url = 'http://example.com/search?query='
  configatron.sequencing_admin_email = 'admin@example.com'
  configatron.api.authorisation_code = 'development'
  configatron.api.flush_response_at = 32768

  configatron.register_printers_automatically = false

  configatron.tube_rack_scans_microservice_url = 'http://localhost:5000/tube_rack/'

  # Feature toggles
  configatron.enable_report_fails = true

  configatron.sprint_url = 'http://sprint.psd.sanger.ac.uk/'
end

if Rails.env.test? || Rails.env.cucumber?

  configatron.barcode_images_url = 'http://example.com/deliberately_broken_url'
  configatron.invalid_policy_url_domains = ['internal.example.com', 'invalid.example.com']

  configatron.disable_accession_check = false
  configatron.disable_api_authentication = true
  configatron.disable_web_proxy = true

  configatron.ldap_port = 389
  configatron.ldap_secure_port = 636
  configatron.ldap_server = 'ldap.internal.sanger.ac.uk'

  configatron.plate_barcode_service = 'http://localhost:9998/plate_barcode_service/'
  configatron.plate_volume_files = "#{Rails.root}/test/data/plate_volume/"

  configatron.taxon_lookup_url = 'http://eutils.ncbi.nlm.nih.gov/entrez/eutils/'

  configatron.tecan_precision = 1
  configatron.beckman_precision = 2
  configatron.hamilton_precision = 2
  configatron.uploaded_spreadsheet.max_number_of_samples = 380

  configatron.data_sharing_contact.name = 'John Doe'
  configatron.data_sharing_contact.email = 'foo'
  configatron.accession_local_key = 'abc'
  configatron.sequencescape_email = 'sequencescape@example.com'
  configatron.default_email_domain = 'example.com'
  configatron.run_information_url = 'http://example.com/'
  configatron.sso_logout_url = 'https://example.com/logout'
  configatron.run_data_by_batch_id_url = 'http://example.com/search?query='
  configatron.sequencing_admin_email = 'admin@example.com'
  configatron.api.authorisation_code = 'cucumber'
  configatron.api.flush_response_at = 32768

  configatron.register_printers_automatically = false

  configatron.tube_rack_scans_microservice_url = 'http://localhost:5000/tube_rack/'
end
