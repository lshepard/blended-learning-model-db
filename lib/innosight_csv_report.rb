require 'csv'

class InnosightCsvReport
  def initialize(data)
    @data = data
  end

  def to_csv
    CSV.generate do |csv|
      csv << pretty_column_names
      value_rows.each do |hash|
        csv << hash.values
      end
    end
  end

  def pretty_column_names
    # TODO: This is largely duplicated in datatable.js's presentation code.  Unify these two.
    mappings = {
      'title'             => 'Name',
      'source'            => 'Source',
      'detail'            => 'Detail',
      'url'               => 'URL',
      'hqstate'           => 'State',
      'type'              => 'Type',
      'focus'             => 'Focus',
      'firstyear'         => 'First Year of Operation',
      'blendedsubjects'   => 'Blended Subjects',
      'programmodels'     => 'Blended-learning Model',
      'postdate'          => 'Date Posted',
      'hqcity'            => 'City',
      'gradesserved'      => 'Grades Served',
      'frl'               => '% Free or Reduced Lunch',
      'minority'          => '% Black/ or Hispanic',
      'revenueperpupil'   => 'Revenue per Pupil',
      'blendedgrades'     => 'Blended Grades',
      'blendedenrollment' => 'Blended Enrollment',
      'content'           => 'Content',
      'sis'               => 'Student Information System',
      'othertools'        => 'Other Tools',
      'indylms'           => 'Independent LMS',
      'indygradebook'     => 'Independent Gradebook Grades',
      'indyassessment'    => 'Independent Assessment',
      'profdevel'         => 'Professional Development',
      'alltools'          => 'Edtech Tools',
      'renamedto'         => 'Now Profiled As',
    }

    column_names = @data.first.keys

    column_names.map { |column_name|
      mappings[column_name] || column_name
    }
  end

  def value_rows
    @data[1..-1]
  end
end
