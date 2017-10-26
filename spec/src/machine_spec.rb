# frozen_string_literal: true

RSpec.describe Machine do
  let(:run) { described_class.run(file_in, file_out) }

  it { run }
end
