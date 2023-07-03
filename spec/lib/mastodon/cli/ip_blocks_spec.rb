# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/cli/ip_blocks'

describe Mastodon::CLI::IpBlocks do
  let(:cli) { described_class.new }

  describe '.exit_on_failure?' do
    it 'returns true' do
      expect(described_class.exit_on_failure?).to be true
    end
  end

  describe '#add' do
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

    shared_examples 'ip address blocking' do
      it 'blocks all specified IP addresses' do
        cli.invoke(:add, ip_list, options)

        blocked_ip_addresses = IpBlock.where(ip: ip_list).pluck(:ip)
        expected_ip_addresses = ip_list.map { |ip| IPAddr.new(ip) }

        expect(blocked_ip_addresses).to match_array(expected_ip_addresses)
      end

      it 'sets the severity for all blocked IP addresses' do
        cli.invoke(:add, ip_list, options)

        blocked_ips_severity = IpBlock.where(ip: ip_list).pluck(:severity).all?(options[:severity])

        expect(blocked_ips_severity).to be(true)
      end

      it 'displays a success message with a summary' do
        expect { cli.invoke(:add, ip_list, options) }.to output(
          a_string_including("Added #{ip_list.size}, skipped 0, failed 0")
        ).to_stdout
      end
    end

    context 'with valid IP addresses' do
      include_examples 'ip address blocking'
    end

    context 'when a specified IP address is already blocked' do
      let!(:blocked_ip) { IpBlock.create(ip: ip_list.last, severity: options[:severity]) }

      it 'skips the already blocked IP address' do
        allow(IpBlock).to receive(:new).and_call_original

        cli.invoke(:add, ip_list, options)

        expect(IpBlock).to_not have_received(:new).with(ip: ip_list.last)
      end

      it 'displays the correct summary' do
        expect { cli.invoke(:add, ip_list, options) }.to output(
          a_string_including("#{ip_list.last} is already blocked\nAdded #{ip_list.size - 1}, skipped 1, failed 0")
        ).to_stdout
      end

      context 'with --force option' do
        let!(:blocked_ip) { IpBlock.create(ip: ip_list.last, severity: 'no_access') }
        let(:options) { { severity: 'sign_up_requires_approval', force: true } }

        it 'overwrites the existing IP block record' do
          expect { cli.invoke(:add, ip_list, options) }
            .to change { blocked_ip.reload.severity }
            .from('no_access')
            .to('sign_up_requires_approval')
        end

        include_examples 'ip address blocking'
      end
    end

    context 'when a specified IP address is invalid' do
      let(:ip_list) { ['320.15.175.0', '9.5.105.255', '0.0.0.0'] }

      it 'displays the correct summary' do
        expect { cli.invoke(:add, ip_list, options) }.to output(
          a_string_including("#{ip_list.first} is invalid\nAdded #{ip_list.size - 1}, skipped 0, failed 1")
        ).to_stdout
      end
    end

    context 'with --comment option' do
      let(:options) { { severity: 'no_access', comment: 'Spam' } }

      include_examples 'ip address blocking'
    end

    context 'with --duration option' do
      let(:options) { { severity: 'no_access', duration: 10.days } }

      include_examples 'ip address blocking'
    end

    context 'with "sign_up_requires_approval" severity' do
      let(:options) { { severity: 'sign_up_requires_approval' } }

      include_examples 'ip address blocking'
    end

    context 'with "sign_up_block" severity' do
      let(:options) { { severity: 'sign_up_block' } }

      include_examples 'ip address blocking'
    end

    context 'when a specified IP address fails to be blocked' do
      let(:ip_address) { '127.0.0.1' }
      let(:ip_block) { instance_double(IpBlock, ip: ip_address, save: false) }

      before do
        allow(IpBlock).to receive(:new).and_return(ip_block)
        allow(ip_block).to receive(:severity=)
        allow(ip_block).to receive(:expires_in=)
      end

      it 'displays an error message' do
        expect { cli.invoke(:add, [ip_address], options) }
          .to output(
            a_string_including("#{ip_address} could not be saved")
          ).to_stdout
      end
    end

    context 'when no IP address is provided' do
      it 'exits with an error message' do
        expect { cli.add }.to output(
          a_string_including('No IP(s) given')
        ).to_stdout
          .and raise_error(SystemExit)
      end
    end
  end

  describe '#remove' do
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

      before do
        ip_list.each { |ip| IpBlock.create(ip: ip, severity: :no_access) }
      end

      it 'removes exact IP blocks' do
        cli.invoke(:remove, ip_list)

        expect(IpBlock.where(ip: ip_list)).to_not exist
      end

      it 'displays success message with a summary' do
        expect { cli.invoke(:remove, ip_list) }.to output(
          a_string_including("Removed #{ip_list.size}, skipped 0")
        ).to_stdout
      end
    end

    context 'with --force option' do
      let!(:first_ip_range_block) { IpBlock.create(ip: '192.168.0.0/24', severity: :no_access) }
      let!(:second_ip_range_block) { IpBlock.create(ip: '10.0.0.0/16', severity: :no_access) }
      let!(:third_ip_range_block) { IpBlock.create(ip: '172.16.0.0/20', severity: :no_access) }
      let(:arguments) { ['192.168.0.5', '10.0.1.50'] }
      let(:options) { { force: true } }

      it 'removes blocks for IP ranges that cover given IP(s)' do
        cli.invoke(:remove, arguments, options)

        expect(IpBlock.where(id: [first_ip_range_block.id, second_ip_range_block.id])).to_not exist
      end

      it 'does not remove other IP ranges' do
        cli.invoke(:remove, arguments, options)

        expect(IpBlock.where(id: third_ip_range_block.id)).to exist
      end
    end

    context 'when a specified IP address is not blocked' do
      let(:unblocked_ip) { '192.0.2.1' }

      it 'skips the IP address' do
        expect { cli.invoke(:remove, [unblocked_ip]) }.to output(
          a_string_including("#{unblocked_ip} is not yet blocked")
        ).to_stdout
      end

      it 'displays the summary correctly' do
        expect { cli.invoke(:remove, [unblocked_ip]) }.to output(
          a_string_including('Removed 0, skipped 1')
        ).to_stdout
      end
    end

    context 'when a specified IP address is invalid' do
      let(:invalid_ip) { '320.15.175.0' }

      it 'skips the invalid IP address' do
        expect { cli.invoke(:remove, [invalid_ip]) }.to output(
          a_string_including("#{invalid_ip} is invalid")
        ).to_stdout
      end

      it 'displays the summary correctly' do
        expect { cli.invoke(:remove, [invalid_ip]) }.to output(
          a_string_including('Removed 0, skipped 1')
        ).to_stdout
      end
    end

    context 'when no IP address is provided' do
      it 'exits with an error message' do
        expect { cli.remove }.to output(
          a_string_including('No IP(s) given')
        ).to_stdout
          .and raise_error(SystemExit)
      end
    end
  end

  describe '#export' do
    let(:first_ip_range_block) { IpBlock.create(ip: '192.168.0.0/24', severity: :no_access) }
    let(:second_ip_range_block) { IpBlock.create(ip: '10.0.0.0/16', severity: :no_access) }
    let(:third_ip_range_block) { IpBlock.create(ip: '127.0.0.1', severity: :sign_up_block) }

    context 'when --format option is set to "plain"' do
      let(:options) { { format: 'plain' } }

      it 'exports blocked IPs with "no_access" severity in plain format' do
        expect { cli.invoke(:export, nil, options) }.to output(
          a_string_including("#{first_ip_range_block.ip}/#{first_ip_range_block.ip.prefix}\n#{second_ip_range_block.ip}/#{second_ip_range_block.ip.prefix}")
        ).to_stdout
      end

      it 'does not export bloked IPs with different severities' do
        expect { cli.invoke(:export, nil, options) }.to_not output(
          a_string_including("#{third_ip_range_block.ip}/#{first_ip_range_block.ip.prefix}")
        ).to_stdout
      end
    end

    context 'when --format option is set to "nginx"' do
      let(:options) { { format: 'nginx' } }

      it 'exports blocked IPs with "no_access" severity in plain format' do
        expect { cli.invoke(:export, nil, options) }.to output(
          a_string_including("deny #{first_ip_range_block.ip}/#{first_ip_range_block.ip.prefix};\ndeny #{second_ip_range_block.ip}/#{second_ip_range_block.ip.prefix};")
        ).to_stdout
      end

      it 'does not export bloked IPs with different severities' do
        expect { cli.invoke(:export, nil, options) }.to_not output(
          a_string_including("deny #{third_ip_range_block.ip}/#{first_ip_range_block.ip.prefix};")
        ).to_stdout
      end
    end

    context 'when --format option is not provided' do
      it 'exports blocked IPs in plain format by default' do
        expect { cli.export }.to output(
          a_string_including("#{first_ip_range_block.ip}/#{first_ip_range_block.ip.prefix}\n#{second_ip_range_block.ip}/#{second_ip_range_block.ip.prefix}")
        ).to_stdout
      end
    end
  end
end
