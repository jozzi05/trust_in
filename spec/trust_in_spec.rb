# frozen_string_literal: true

require 'trust_in'

RSpec.shared_examples 'triggers vat evaluation with service data' do
  before do
    allow(Vat::CompanyStateService)
      .to receive(:fetch_details).with(evaluation.value).and_return(state: 'favorable', reason: 'company_opened')
  end

  it "assigns evaluation's state&reason based on the API response and a score to 100" do
    expect { update_score }
      .to change(evaluation, :state).to('favorable')
      .and change(evaluation, :reason).to('company_opened')
      .and change(evaluation, :score).to(100)
  end
end

RSpec.describe TrustIn do
  describe '#update_score' do
    let(:evaluations) { [evaluation] }

    context "when the evaluation type is 'SIREN'" do
      subject!(:update_score) { described_class.new(evaluations).update_score }

      context "with a <score> greater or equal to 50 AND the <state> is unconfirmed and the <reason> is 'unable_to_reach_api'" do
        let(:evaluation) { build(:evaluation, :siren, :unconfirmed, :unable_to_reach_api, score: 79) }

        it 'decreases the <score> of 5' do
          expect(evaluations.first.score).to eq(74)
        end
      end

      context 'with a <score> greater or equal to 50 AND the <state> is favorable' do
        let(:evaluation) { build(:evaluation, :siren, :favorable, :unable_to_reach_api, score: 79) }

        it 'decreases the <score> by 1' do
          expect(evaluations.first.score).to eq(78)
        end
      end

      context "when the <state> is unconfirmed and the <reason> is 'unable_to_reach_api'" do
        let(:evaluation) { build(:evaluation, :siren, :unconfirmed, :unable_to_reach_api, score: 37) }

        it 'decreases the <score> of 1' do
          expect(evaluations.first.score).to eq(36)
        end
      end

      context 'when the <state> is favorable' do
        let(:evaluation) { build(:evaluation, :siren, :favorable, :company_opened, score: 28) }

        it 'decreases the <score> of 1' do
          expect(evaluations.first.score).to eq(27)
        end
      end

      context "when the <state> is 'unconfirmed' AND the <reason> is 'ongoing_database_update'" do
        let(:evaluation) { build(:evaluation, :siren, :unconfirmed, :ongoing_database_update, score: 42, value:) }

        context "when API returns <company state> as 'Actif'", vcr: { cassette_name: 'services/sirene-v3/actif' } do
          let(:value) { '832940670' }

          it 'assigns a <state> and a <reason> to the evaluation based on the API response and a <score> to 100' do
            expect(evaluations.first).to have_attributes(
              state: 'favorable',
              reason: 'company_opened',
              score: 100
            )
          end
        end

        context "when API returns <company state> as not 'Actif'", vcr: { cassette_name: 'services/sirene-v3/not_actif' } do
          let(:value) { '320878499' }

          it 'assigns a <state> and a <reason> to the evaluation based on the API response and a <score> to 100' do
            expect(evaluations.first).to have_attributes(
              state: 'unfavorable',
              reason: 'company_closed',
              score: 100
            )
          end
        end
      end

      context 'with a <score> equal to 0' do
        let(:evaluation) { build(:evaluation, :siren, :favorable, :company_opened, score: 0, value:) }

        context "when API returns <company state> as 'Actif'", vcr: { cassette_name: 'services/sirene-v3/actif' } do
          let(:value) { '832940670' }

          it 'assigns a <state> and a <reason> to the evaluation based on the API response and a <score> to 100' do
            expect(evaluations.first).to have_attributes(
              state: 'favorable',
              reason: 'company_opened',
              score: 100
            )
          end
        end

        context "when API returns <company state> as not 'Actif'", vcr: { cassette_name: 'services/sirene-v3/not_actif' } do
          let(:value) { '320878499' }

          it 'assigns a <state> and a <reason> to the evaluation based on the API response and a <score> to 100' do
            expect(evaluations.first).to have_attributes(
              state: 'unfavorable',
              reason: 'company_closed',
              score: 100
            )
          end
        end
      end

      context "with a <state> 'unfavorable'" do
        let(:evaluation) { build(:evaluation, :siren, :unfavorable, :company_closed) }

        it 'does not decrease its <score>' do
          expect { update_score }.not_to(change { evaluations.first.score })
        end
      end

      context "with a <state>'unfavorable' AND a <score> equal to 0" do
        let(:evaluation) { build(:evaluation, :siren, :unfavorable, :company_closed, score: 0) }

        it 'does not call the API' do
          expect(Net::HTTP).not_to receive(:get)
        end
      end
    end

    context "when the evaluation type is 'VAT'" do
      subject(:update_score) { described_class.new(evaluations).update_score }

      context 'with unfavorable state' do
        let(:evaluation) { build(:evaluation, :vat, :unfavorable) }

        it 'does nothing' do
          expect { update_score }.not_to change { evaluation }
        end
      end

      context 'with score equal zero' do
        let(:evaluation) { build(:evaluation, :vat, score: 0) }

        include_examples 'triggers vat evaluation with service data'
      end

      context 'with unconfirmed state and reason set to ongoing_database_update' do
        let(:evaluation) { build(:evaluation, :vat, :unconfirmed, :ongoing_database_update) }

        include_examples 'triggers vat evaluation with service data'
      end

      context 'with unconfirmed state and reason set to unable_to_reach_api' do
        let(:evaluation) { build(:evaluation, :vat, :unconfirmed, :unable_to_reach_api, score:) }

        context 'with score below 50' do
          let(:score) { 45 }

          it 'decreases score by 3' do
            expect { update_score }.to change(evaluation, :score).by(-3)
          end
        end

        context 'with score above or equal 50' do
          let(:score) { 50 }

          it 'decreases score by 1' do
            expect { update_score }.to change(evaluation, :score).by(-1)
          end
        end
      end

      context 'with favorable state' do
        let(:evaluation) { build(:evaluation, :vat, :unconfirmed, :unable_to_reach_api, score: 55) }

        it 'decreases score by 1' do
          expect { update_score }.to change(evaluation, :score).by(-1)
        end
      end
    end
  end
end
