# frozen_string_literal: true

RSpec.describe Machine::Commands do
  context 'with correct input file' do
    let(:run) { described_class.perform File.readlines(file_in) }

    it { expect(run.success?).to be_truthy }
    it { expect(run.result).to be_kind_of Array }
  end

  context 'with correct input file' do
    let(:run) { described_class.perform File.readlines(file_in_wrong) }

    it { expect(run.success?).to be_falsey }
    it { expect(run.errors.count).to eq 1 }
    it { expect(run.errors[:command].shift).to include "Wrong Command 'KREATE'" }
  end
end
