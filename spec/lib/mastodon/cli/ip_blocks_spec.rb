# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/cli/ip_blocks'

RSpec.describe Mastodon::CLI::IpBlocks do
  subject { cli.invoke(action, arguments, options) }

  let(:cli) { described_class.new }
  let(:arguments) { [] }
  let(:options) { {} }

  it_behaves_like 'CLI Command'

  describe '#add' do
    let(:action) { :add }
    let(:ip_list) do
      [
        '192.0.2.1',
        '172.16.0.1',
        '192.0.2.0/24',
        '172.16.0.0/16',
        '10.0.0.0/8',
        '2001:0db8:85a3:0000:0000:8a2e:0370:7334',
        'fe80::1',
        '::1',
        '2001:0db8::/32',
        'fe80::/10',
        '::/128',
      ]
    end
    let(:options) { { severity: 'no_access' } }
    let(:arguments) { ip_list }

    shared_examples 'ip address blocking' do
      def blocked_ip_addresses
        IpBlock.where(ip: ip_list).pluck(:ip)
      end

      def expected_ip_addresses
        ip_list.map { |ip| IPAddr.new(ip) }
      end

      def blocked_ips_severity
        IpBlock.where(ip: ip_list).pluck(:severity).all?(options[:severity])
      end

      it 'blocks and sets severity for ip address and displays summary' do
        expect { subject }
          .to output_results("Added #{ip_list.size}, skipped 0, failed 0")
        expect(blocked_ip_addresses)
          .to match_array(expected_ip_addresses)
        expect(blocked_ips_severity)
          .to be(true)
      end
    end

    context 'with valid IP addresses' do
      it_behaves_like 'ip address blocking'
    end

    context 'when a specified IP address is already blocked' do
      let!(:blocked_ip) { IpBlock.create(ip: ip_list.last, severity: options[:severity]) }
      let(:arguments) { ip_list }

      before { allow(IpBlock).to receive(:new).and_call_original }

      it 'skips already block ip and displays the correct summary' do
        expect { subject }
          .to output_results("#{ip_list.last} is already blocked\nAdded #{ip_list.size - 1}, skipped 1, failed 0")

        expect(IpBlock).to_not have_received(:new).with(ip: ip_list.last)
      end

      context 'with --force option' do
        let!(:blocked_ip) { IpBlock.create(ip: ip_list.last, severity: 'no_access') }
        let(:options) { { severity: 'sign_up_requires_approval', force: true } }

        it 'overwrites the existing IP block record' do
          expect { subject }
            .to output_results('Added 11')
            .and change { blocked_ip.reload.severity }
            .from('no_access')
            .to('sign_up_requires_approval')
        end

        it_behaves_like 'ip address blocking'
      end
    end

    context 'when a specified IP address is invalid' do
      let(:ip_list) { ['320.15.175.0', '9.5.105.255', '0.0.0.0'] }
      let(:arguments) { ip_list }

      it 'displays the correct summary' do
        expect { subject }
          .to output_results("#{ip_list.first} is invalid\nAdded #{ip_list.size - 1}, skipped 0, failed 1")
      end
    end

    context 'with --comment option' do
      let(:options) { { severity: 'no_access', comment: 'Spam' } }

      it_behaves_like 'ip address blocking'
    end

    context 'with --duration option' do
      let(:options) { { severity: 'no_access', duration: 10.days } }

      it_behaves_like 'ip address blocking'
    end

    context 'with "sign_up_requires_approval" severity' do
      let(:options) { { severity: 'sign_up_requires_approval' } }

      it_behaves_like 'ip address blocking'
    end

    context 'with "sign_up_block" severity' do
      let(:options) { { severity: 'sign_up_block' } }

      it_behaves_like 'ip address blocking'
    end

    context 'when a specified IP address fails to be blocked' do
      let(:ip_address) { '127.0.0.1' }
      let(:ip_block) { instance_double(IpBlock, ip: ip_address, save: false) }
      let(:arguments) { [ip_address] }

      before do
        allow(IpBlock).to receive(:new).and_return(ip_block)
        allow(ip_block).to receive(:severity=)
        allow(ip_block).to receive(:expires_in=)
      end

      it 'displays an error message' do
        expect { subject }
          .to output_results("#{ip_address} could not be saved")
      end
    end

    context 'when no IP address is provided' do
      let(:arguments) { [] }

      it 'exits with an error message' do
        expect { subject }
          .to raise_error(Thor::Error, 'No IP(s) given')
      end
    end
  end

  describe '#remove' do
    let(:action) { :remove }

    context 'when removing exact matches' do
      let(:ip_list) do
        [
          '192.0.2.1',
          '172.16.0.1',
          '192.0.2.0/24',
          '172.16.0.0/16',
          '10.0.0.0/8',
          '2001:0db8:85a3:0000:0000:8a2e:0370:7334',
          'fe80::1',
          '::1',
          '2001:0db8::/32',
          'fe80::/10',
          '::/128',
        ]
      end
      let(:arguments) { ip_list }

      before do
        ip_list.each { |ip| IpBlock.create(ip: ip, severity: :no_access) }
      end

      it 'removes exact ip blocks and displays success message with a summary' do
        expect { subject }
          .to output_results("Removed #{ip_list.size}, skipped 0")
        expect(IpBlock.where(ip: ip_list)).to_not exist
      end
    end

    context 'with --force option' do
      let!(:first_ip_range_block) { IpBlock.create(ip: '192.168.0.0/24', severity: :no_access) }
      let!(:second_ip_range_block) { IpBlock.create(ip: '10.0.0.0/16', severity: :no_access) }
      let!(:third_ip_range_block) { IpBlock.create(ip: '172.16.0.0/20', severity: :no_access) }
      let(:arguments) { ['192.168.0.5', '10.0.1.50'] }
      let(:options) { { force: true } }

      it 'removes blocks for IP ranges that cover given IP(s) and keeps other ranges' do
        expect { subject }
          .to output_results('Removed 2')

        expect(covered_ranges).to_not exist
        expect(other_ranges).to exist
      end

      def covered_ranges
        IpBlock.where(id: [first_ip_range_block.id, second_ip_range_block.id])
      end

      def other_ranges
        IpBlock.where(id: third_ip_range_block.id)
      end
    end

    context 'when a specified IP address is not blocked' do
      let(:unblocked_ip) { '192.0.2.1' }
      let(:arguments) { [unblocked_ip] }

      it 'skips the IP address and displays summary' do
        expect { subject }
          .to output_results(
            "#{unblocked_ip} is not yet blocked",
            'Removed 0, skipped 1'
          )
      end
    end

    context 'when a specified IP address is invalid' do
      let(:invalid_ip) { '320.15.175.0' }
      let(:arguments) { [invalid_ip] }

      it 'skips the invalid IP address and displays summary' do
        expect { subject }
          .to output_results(
            "#{invalid_ip} is invalid",
            'Removed 0, skipped 1'
          )
      end
    end

    context 'when no IP address is provided' do
      it 'exits with an error message' do
        expect { subject }
          .to raise_error(Thor::Error, 'No IP(s) given')
      end
    end
  end

  describe '#export' do
    let(:action) { :export }

    let(:first_ip_range_block) { IpBlock.create(ip: '192.168.0.0/24', severity: :no_access) }
    let(:second_ip_range_block) { IpBlock.create(ip: '10.0.0.0/16', severity: :no_access) }
    let(:third_ip_range_block) { IpBlock.create(ip: '127.0.0.1', severity: :sign_up_block) }

    context 'when --format option is set to "plain"' do
      let(:options) { { format: 'plain' } }

      it 'exports blocked IPs with "no_access" severity in plain format' do
        expect { subject }
          .to output_results("#{first_ip_range_block.ip}/#{first_ip_range_block.ip.prefix}\n#{second_ip_range_block.ip}/#{second_ip_range_block.ip.prefix}")
      end

      it 'does not export blocked IPs with different severities' do
        expect { subject }
          .to_not output_results("#{third_ip_range_block.ip}/#{first_ip_range_block.ip.prefix}")
      end
    end

    context 'when --format option is set to "nginx"' do
      let(:options) { { format: 'nginx' } }

      it 'exports blocked IPs with "no_access" severity in plain format' do
        expect { subject }
          .to output_results("deny #{first_ip_range_block.ip}/#{first_ip_range_block.ip.prefix};\ndeny #{second_ip_range_block.ip}/#{second_ip_range_block.ip.prefix};")
      end

      it 'does not export blocked IPs with different severities' do
        expect { subject }
          .to_not output_results("deny #{third_ip_range_block.ip}/#{first_ip_range_block.ip.prefix};")
      end
    end

    context 'when --format option is not provided' do
      it 'exports blocked IPs in plain format by default' do
        expect { subject }
          .to output_results("#{first_ip_range_block.ip}/#{first_ip_range_block.ip.prefix}\n#{second_ip_range_block.ip}/#{second_ip_range_block.ip.prefix}")
      end
    end
  end
end
