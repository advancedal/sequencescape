# frozen_string_literal: true

# Provides simple consistent records where multiple records are not needed.
module UatActions::StaticRecords
  # Swipecard code of the test user.
  # It gets hashed when persisted to the database, so we store it as a constant
  # here to allow us to access it in the integration suite tools.
  SWIPECARD_CODE = '__uat_test__'

  def self.study
    Study.create_with(
      state: 'active',
      study_metadata_attributes: {
        data_access_group: 'dag',
        study_type: StudyType.first,
        faculty_sponsor: faculty_sponsor,
        data_release_study_type: DataReleaseStudyType.default,
        study_description: 'A study generated for UAT',
        contaminated_human_dna: 'No',
        contains_human_dna: 'No',
        commercially_available: 'No',
        program: program
      }
    ).find_or_create_by!(name: 'UAT Study')
  end

  def self.project
    Project.find_or_create_by!(name: 'UAT Study')
  end

  def self.program
    Program.find_or_create_by!(name: 'UAT')
  end

  def self.user
    User.create_with(
      email: configatron.admin_email,
      first_name: 'Test',
      last_name: 'User',
      swipecard_code: SWIPECARD_CODE
    ).find_or_create_by(login: '__uat_test__')
  end

  def self.faculty_sponsor
    FacultySponsor.find_or_create_by!(name: 'UAT Faculty Sponsor')
  end
end