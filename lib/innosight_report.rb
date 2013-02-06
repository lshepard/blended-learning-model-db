class InnosightReport
  def initialize(data)
    @data = data
  end

  def pretty_column_names
    mappings.values
  end

  def value_rows
    @data[1..-1].map { |row_hash|
      mappings.map { |key, _| amend_data(key, row_hash[key]) }
    }
  end

  private

  def amend_data(key, value)
    if key == 'gradesserved'
      value.gsub('-', ' - ') # Avoid spreadsheet apps *cleverly* converting 6-12 into "June 2012"
    else
      value
    end
  end

  # TODO: This is largely duplicated in datatable.js's presentation code.  Unify these two.
  def mappings
    {
      'title'             => 'Name',
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
  end
end
