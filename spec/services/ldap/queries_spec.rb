require 'rails_helper'

RSpec.describe Ldap::Queries, type: :service do
  describe '.library_staff' do
    before do
      entry1 = Net::LDAP::Entry.new('CN=drseuss,OU=Users,OU=University Library,DC=AD,DC=UCSD,DC=EDU')
      entry1['SAMAccountName'] = 'drseuss'
      entry2 = Net::LDAP::Entry.new('CN=nonadmin,OU=Users,OU=University Library,DC=AD,DC=UCSD,DC=EDU')
      entry2['SAMAccountName'] = ''
      mock_ldap_validation
      allow(mock_ldap_connection).to receive(:search).and_yield(entry1).and_yield(entry2)
    end

    it 'returns an empty string with no match' do
      expect(described_class.library_staff('nonadmin')).to eq('')
    end

    it 'returns the SAMAccountName for the given user with a match' do
      expect(described_class.library_staff('drseuss')).to eq('')
    end
  end

  describe '.hifive_group' do
    before do
      entry1 = Net::LDAP::Entry.new('CN=drseuss,OU=Users,OU=University Library,DC=AD,DC=UCSD,DC=EDU')
      entry1['SAMAccountName'] = 'drseuss'
      entry2 = Net::LDAP::Entry.new('CN=nonadmin,OU=Users,OU=University Library,DC=AD,DC=UCSD,DC=EDU')
      entry2['SAMAccountName'] = ''
      mock_ldap_validation
      allow(mock_ldap_connection).to receive(:search).and_yield(entry1).and_yield(entry2)
    end

    it 'returns an empty string with no match' do
      expect(described_class.hifive_group('nonadmin')).to eq('')
    end

    it 'returns the SAMAccountName for the given user with a match' do
      expect(described_class.hifive_group('drseuss')).to eq('')
    end
  end

  describe '.employees' do
    before do
      entry1 = Net::LDAP::Entry.new('CN=aemployee,OU=Users,OU=University Library,DC=AD,DC=UCSD,DC=EDU')
      entry1['cn'] = 'aemployee'
      entry1['displayName'] = ['Employee, A']
      entry1['givenName'] = ['A']
      entry1['sn'] = ['Employee']
      entry1['mail'] = ['aemployee@ucsd.edu']
      entry1['manager'] = ['CN=bigboss1,OU=Users,OU=University Library,DC=AD,DC=UCSD,DC=EDU']
      entry1['whenChanged'] = ['20181130172427.0Z']
      entry1['SAMAccountName'] = 'aemployee'
      entry2 = Net::LDAP::Entry.new('CN=zbestemployee,OU=Users,OU=University Library,DC=AD,DC=UCSD,DC=EDU')
      entry2['cn'] = 'zbestemployee'
      entry2['displayName'] = ["Zbestemployee, The"]
      entry2['givenName'] = ['The']
      entry2['sn'] = ['Zbestemployee']
      entry2['mail'] = ['zbestemployee@ucsd.edu']
      entry2['manager'] = ['CN=bigboss2,OU=Users,OU=University Library,DC=AD,DC=UCSD,DC=EDU']
      entry2['whenChanged'] = ['20181130172427.0Z']
      entry2['SAMAccountName'] = 'zbestemployee'
      mock_ldap_validation
      allow(mock_ldap_connection).to receive(:search).and_yield(entry1).and_yield(entry2)
    end

    it 'returns all entries' do
      described_class.employees
      expect(Employee.count).to eq(2)
    end
  end

  describe '.validate_ldap_response' do
    it 'raises an error with a non-zero exit code' do
      operation_result = OpenStruct.new(:code => 1, :message => 'Something terrible happened')
      allow(mock_ldap_connection).to receive(:get_operation_result).and_return(operation_result)
      expect{ described_class.validate_ldap_response }.to raise_error(RuntimeError).
        with_message("Response Code: Operations Error\nMessage: Something terrible happened\n")
    end

    it 'returns nil with a zero exit code' do
      operation_result = OpenStruct.new(:code => 0, :message => 'LDAP here, all is well')
      allow(mock_ldap_connection).to receive(:get_operation_result).and_return(operation_result)
      expect{ described_class.validate_ldap_response }.not_to raise_error
    end
  end
end
