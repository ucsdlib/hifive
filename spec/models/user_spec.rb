require 'rails_helper'

RSpec.describe User, type: :model do
  let(:auth_hash) { OmniAuth::AuthHash.new({
    provider: 'google_oauth2',
    uid: '1',
    info: { 'email' => 'test@ucsd.edu', 'name' => 'Dr. Seuss' }
  })}

  let(:invalid_auth_hash_missing_info) { OmniAuth::AuthHash.new({
    provider: 'google_oauth2',
    uid: 'test'
  })}
  describe "#developer?" do
    it 'should return true when provider is developer' do
      auth_hash.provider = 'developer'
      auth_hash.uid = '1'
      user = User.find_or_create_for_developer(auth_hash)
      expect(user.developer?).to be true
    end

    it 'should return false when provider is google_oauth2' do
      user = User.find_or_create_for_google_oauth2(auth_hash)
      expect(user.developer?).to be false
    end


  end

  describe ".find_or_create_for_developer" do
    it "should create a User for first time user" do
      auth_hash.provider = 'developer'
      auth_hash.uid = '1'
      user = User.find_or_create_for_developer(auth_hash)

      expect(user).to be_persisted
      expect(user.provider).to eq("developer")
      expect(user.uid).to eq("1")
      expect(user.full_name).to eq("developer")
    end

    it "should reuse an existing User if the access token matches" do
      auth_hash.provider = 'developer'
      auth_hash.uid = '1'

      user = User.find_or_create_for_developer(auth_hash)

      expect(User.count).to be(1)
    end
  end

  describe ".find_or_create_for_google_oauth2" do
    it "should create a User when a user is first authenticated" do
      user = User.find_or_create_for_google_oauth2(auth_hash)
      expect(user).to be_persisted
      expect(user.provider).to eq("google_oauth2")
      expect(user.uid).to eq("1")
      expect(user.email).to eq('test@ucsd.edu')
      expect(user.full_name).to eq('Dr. Seuss')
    end

    it 'should not persist a shib response with bad or missing information' do
      User.find_or_create_for_google_oauth2(invalid_auth_hash_missing_info)
      expect(User.find_by(uid: 'test', provider: 'google_oauth2')).to be nil
    end
  end

  describe '.administrator?' do
    context 'user is not in group' do
      it 'returns false' do
        user = User.find_or_create_for_google_oauth2(auth_hash)
        allow(Ldap::Queries).to receive(:hifive_group).with(user.uid).and_return('')
        expect(User.administrator?(user.uid)).to be false
      end
    end
    context 'user is in group' do
      it 'returns true' do
        user = User.find_or_create_for_google_oauth2(auth_hash)
        allow(Ldap::Queries).to receive(:hifive_group).with(user.uid).and_return(user.uid)
        expect(User.administrator?(user.uid)).to be true
      end
    end
  end

  describe '.employee_uid' do
    context 'when google-oauth uid is a number' do
      before(:all) do
        @employee = Employee.create(email: 'test@ucsd.edu',
                                    uid: 'test', name: 'Dr. Seuss', display_name: 'Dr.', manager: 'manager1')
        @employee.save!
      end
      after(:all) do
        @employee.delete
      end

      it 'converts google-oauth uid to AD uid' do
        uid = described_class.employee_uid(auth_hash.info.email, auth_hash.uid)
        expect(uid).to eq(@employee.uid)
      end
    end
  end
end
