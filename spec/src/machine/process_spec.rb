# frozen_string_literal: true

RSpec.describe Machine::Process do
  let(:define_command) { [%w[DEFINE ManualReview BackgroundCheck DocumentSigning]] }
  let(:define_command_wrong) { [%w[DEFINE CosmicReview]] }

  let(:stats_command) { define_command + [%w[STATS]] }
  let(:create_command) { [%w[CREATE renat@aomega.co], %w[CREATE renat@aomega.co]] }

  let(:advance_command) { define_command + create_command + [%w[ADVANCE renat@aomega.co]] }
  let(:advance_command_last_stage) do
    define_command + create_command + [%w[ADVANCE renat@aomega.co DocumentSigning], %w[ADVANCE renat@aomega.co]]
  end

  let(:decide_command) do
    define_command + create_command + [%w[ADVANCE renat@aomega.co DocumentSigning], %w[DECIDE renat@aomega.co 1]]
  end
  let(:decide_command_rejected) { define_command + create_command + [%w[DECIDE renat@aomega.co 0]] }
  let(:decide_command_wrong) { define_command + create_command + [%w[DECIDE wrong@mail.com 1]] }

  let(:output1) { File.readlines(file_out(1)).map(&:strip!) }
  let(:output2) { File.readlines(file_out(2)).map(&:strip!) }

  context 'with input1.txt file' do
    let(:commands) { Machine::Commands.perform(File.readlines(file_in)).result }
    let(:run) { described_class.perform commands }

    it { expect(run.success?).to be_truthy }
    it { expect(run.result).to be_kind_of Array }
    it { expect(run.result).to eq output1 }
  end

  context 'with input2.txt file' do
    let(:commands) { Machine::Commands.perform(File.readlines(file_in(2))).result }
    let(:run) { described_class.perform commands }

    it { expect(run.success?).to be_truthy }
    it { expect(run.result).to be_kind_of Array }
    it { expect(run.result).to eq output2 }
  end

  context 'with DEFINE command' do
    let(:wrong) { described_class.perform(define_command_wrong) }

    it { expect(wrong.success?).to be_falsey }
    it { expect(wrong.errors[:define].count).to eq 1 }
    it { expect(wrong.errors[:define].shift).to include "Wrong Stage value 'CosmicReview'" }
  end

  context 'with CREATE command' do
    let(:create) { described_class.perform(create_command) }

    it { expect(create.success?).to be_truthy }
    it { expect(create.result.first).to eq 'CREATE renat@aomega.co' }
    it { expect(create.result.last).to eq 'Duplicate applicant' }
  end

  context 'with ADVANCE command' do
    let(:create) { described_class.perform(advance_command) }
    let(:create_last) { described_class.perform(advance_command_last_stage) }

    it { expect(create.success?).to be_truthy }
    it { expect(create.result.last).to eq 'ADVANCE renat@aomega.co' }

    it { expect(create_last.success?).to be_truthy }
    it { expect(create_last.result.last).to eq 'Already in DocumentSigning' }
  end

  context 'with DECIDE command' do
    let(:decide) { described_class.perform(decide_command) }
    let(:decide_rejected) { described_class.perform(decide_command_rejected) }
    let(:decide_wrong) { described_class.perform(decide_command_wrong) }

    it { expect(decide.success?).to be_truthy }
    it { expect(decide.result.last).to eq 'Hired renat@aomega.co' }

    it { expect(decide_rejected.success?).to be_truthy }
    it { expect(decide_rejected.result.last).to eq 'Rejected renat@aomega.co' }

    it { expect(decide_wrong.success?).to be_truthy }
    it { expect(decide_wrong.result.last).to eq 'Failed to decide for wrong@mail.com' }
  end

  context 'with STATS command' do
    let(:stats) { described_class.perform(stats_command) }

    it { expect(stats.success?).to be_truthy }
    it { expect(stats.result.last).to eq 'ManualReview 0 BackgroundCheck 0 DocumentSigning 0 Hired 0 Rejected 0' }
  end
end
