# frozen_string_literal: true

require 'spec_helper'

describe Warden::JWTAuth::TokenEncoder do
  include_context 'configuration'

  describe '#call(payload)' do
    let(:payload) { { 'foo' => 'bar' } }
    let(:token) { described_class.new.call(payload) }
    let(:decoded_payload) do
      JWT.decode(token, secret, true, algorithn: 'HS256')[0]
    end

    it 'encodes given payload using HS256 algorithm and secret as key' do
      expect { decoded_payload }.not_to raise_error
    end

    it 'merges in provided payload' do
      expect(decoded_payload['foo']).to eq('bar')
    end

    it 'adds an `iat` claim with the issue time' do
      iat = decoded_payload['iat']

      expect(Time.at(iat).to_date).to eq(Date.today)
    end

    it 'adds an `exp` claim with configured expiration time' do
      exp = decoded_payload['exp']

      expect(Time.at(exp)).to be_within(10).of(Time.now + expiration_time)
    end

    it 'adds a `jti` claim with a random unique id' do
      expect(decoded_payload['jti']).not_to be_nil
    end

    it 'when merging provided payload overrides automatic payload' do
      payload['jti'] = 'unique'

      expect(decoded_payload['jti']).to eq('unique')
    end
  end
end
