def generate_measures_of_category(number, name)
  JSON.parse("
        [
            {
                \"Category\": {
                    \"Number\": #{number},
                    \"Name\": \"#{name}\"
                }
            }
        ]")
end

describe AirQualityGradeCalculator do
  let(:mock_epa_service) { instance_double('EpaService') }
  let(:mock_aqi_grader) { instance_double('AqiGrader') }
  let(:expected_measures) { generate_measures_of_category(1, 'Good') }
  let(:zipcode) { '90210' }

  before do
    allow(mock_epa_service).to receive(:get_measures_for_zipcode).and_return(expected_measures)
    subject.epa_service(mock_epa_service)
  end

  describe '#for_zipcode' do
    it 'asks the EPA Service for the AQI value for the zipcode supplied' do
      subject.for_zipcode(zipcode)
      expect(mock_epa_service).to have_received(:get_measures_for_zipcode).with(zipcode)
    end

    describe 'the least healthy measure is a category 1 ("Good")' do
      let(:expected_measures) { generate_measures_of_category(1, 'Good') }
      it('returns a grade of "A"') { expect(subject.for_zipcode(zipcode)).to eq 'A' }
    end

    describe 'the least healthy measure is a category 2 ("Moderate")' do
      let(:expected_measures) { generate_measures_of_category(2, 'Moderate') }
      it('returns a grade of "B"') { expect(subject.for_zipcode(zipcode)).to eq 'B' }
    end

    describe 'the least healthy measure is a category 3 ("Unhealthy for Sensitive")' do
      let(:expected_measures) { generate_measures_of_category(3, 'Unhealthy for Sensitive') }
      it('returns a grade of "C"') { expect(subject.for_zipcode(zipcode)).to eq 'C' }
    end

    describe 'the least healthy measure is a category 4 ("Unhealthy")' do
      let(:expected_measures) { generate_measures_of_category(4, 'Unhealthy') }
      it('returns a grade of "D"') { expect(subject.for_zipcode(zipcode)).to eq 'D' }
    end

    describe 'the least healthy measure is a category 5 ("Very Unhealthy")' do
      let(:expected_measures) { generate_measures_of_category(5, 'Very Unhealthy') }
      it('returns a grade of "E"') { expect(subject.for_zipcode(zipcode)).to eq 'E' }
    end

    describe 'the least healthy measure is a category 6 ("Hazardous")' do
      let(:expected_measures) { generate_measures_of_category(6, 'Hazardous') }
      it('returns a grade of "F"') { expect(subject.for_zipcode(zipcode)).to eq 'F' }
    end

    describe 'when the least healthy measure is not the first' do
      let(:expected_measures) {
        JSON.parse("
        [
            {
                \"Category\": {
                    \"Number\": 1,
                    \"Name\": \"Good\"
                }
            },
            {
                \"Category\": {
                    \"Number\": 6,
                    \"Name\": \"Hazardous\"
                }
            }
        ]")
      }
      it('returns the least healthy measure') { expect(subject.for_zipcode(zipcode)).to eq 'F'}
    end
  end
end