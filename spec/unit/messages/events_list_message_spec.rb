require 'spec_helper'
require 'messages/events_list_message'

module VCAP::CloudController
  RSpec.describe EventsListMessage do
    describe '.from_params' do
      let(:params) do
        {}
      end

      it 'returns the correct EventsListMessage' do
        message = EventsListMessage.from_params(params)

        expect(message).to be_a(EventsListMessage)
      end
    end

    describe 'fields' do
      it 'accepts an empty set' do
        message = EventsListMessage.from_params({})
        expect(message).to be_valid
      end

      it 'accepts a set of fields' do
        message = EventsListMessage.from_params({
          types: ['audit.app.create'],
          target_guids: ['guid1', 'guid2'],
          space_guids: ['guid3', 'guid4'],
          organization_guids: ['guid5', 'guid6'],
          created_at: { lt: Time.now.iso8601 },
        })
        expect(message).to be_valid
      end

      it 'does not accept a field not in this set' do
        message = EventsListMessage.from_params({ foobar: 'pants' })

        expect(message).not_to be_valid
        expect(message.errors[:base][0]).to include("Unknown query parameter(s): 'foobar'")
      end

      context 'validations' do
        it 'validates the types filter' do
          message = EventsListMessage.from_params({ types: 123 })
          expect(message).not_to be_valid
          expect(message.errors[:types]).to include('must be an array')
        end

        it 'validates the target_guids filter' do
          message = EventsListMessage.from_params({ target_guids: 123 })
          expect(message).not_to be_valid
          expect(message.errors[:target_guids]).to include('must be an array')
        end

        it 'validates the space_guids filter' do
          message = EventsListMessage.from_params({ space_guids: 123 })
          expect(message).not_to be_valid
          expect(message.errors[:space_guids]).to include('must be an array')
        end

        it 'validates the organization_guids filter' do
          message = EventsListMessage.from_params({ organization_guids: 123 })
          expect(message).not_to be_valid
          expect(message.errors[:organization_guids]).to include('must be an array')
        end

        context 'validates the created_at filter' do
          it 'requires a hash' do
            message = EventsListMessage.from_params({ created_at: Time.now.iso8601 })
            expect(message).not_to be_valid
            expect(message.errors[:created_at]).to include('comparison operator and timestamp must be specified')
          end

          it 'requires a valid comparison operator' do
            message = EventsListMessage.from_params({ created_at: { garbage: Time.now.iso8601 } })
            expect(message).not_to be_valid
            expect(message.errors[:created_at]).to include("Invalid comparison operator: 'garbage'")
          end

          it 'requires a valid comparison operator' do
            message = EventsListMessage.from_params({ created_at: { garbage: Time.now.iso8601 } })
            expect(message).not_to be_valid
            expect(message.errors[:created_at]).to include("Invalid comparison operator: 'garbage'")
          end

          it 'requires a valid timestamp' do
            message = EventsListMessage.from_params({ created_at: { gt: 123 } })
            expect(message).not_to be_valid
            expect(message.errors[:created_at]).to include("Invalid timestamp format: '123'")
          end

          it 'allows the lt operator' do
            message = EventsListMessage.from_params({ created_at: { lt: Time.now.iso8601 } })
            expect(message).to be_valid
          end

          it 'allows the lte operator' do
            message = EventsListMessage.from_params({ created_at: { lte: Time.now.iso8601 } })
            expect(message).to be_valid
          end

          it 'allows the gt operator' do
            message = EventsListMessage.from_params({ created_at: { gt: Time.now.iso8601 } })
            expect(message).to be_valid
          end

          it 'allows the gte operator' do
            message = EventsListMessage.from_params({ created_at: { gte: Time.now.iso8601 } })
            expect(message).to be_valid
          end
        end
      end
    end
  end
end
