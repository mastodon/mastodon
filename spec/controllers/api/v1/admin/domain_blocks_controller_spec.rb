require 'rails_helper'

RSpec.describe Api::V1::Admin::DomainBlocksController, type: :controller do
  render_views

  let(:role)   { UserRole.find_by(name: 'Admin') }
  let(:user)   { Fabricate(:user, role: role) }
  let(:scopes) { 'admin:read admin:write' }
  let(:token)  { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }

  before do
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  shared_examples 'forbidden for wrong scope' do |wrong_scope|
    let(:scopes) { wrong_scope }

    it 'returns http forbidden' do
      subject

      expect(response).to have_http_status(403)
    end
  end

  shared_examples 'forbidden for wrong role' do |wrong_role|
    let(:role) { UserRole.find_by(name: wrong_role) }

    it 'returns http forbidden' do
      subject

      expect(response).to have_http_status(403)
    end
  end

  describe 'GET #index' do
    let!(:block) { Fabricate(:domain_block) }

    before do
      get :index
    end

    it_behaves_like 'forbidden for wrong scope', 'write:statuses'
    it_behaves_like 'forbidden for wrong role', ''
    it_behaves_like 'forbidden for wrong role', 'Moderator'

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end

    it 'returns the expected domain blocks' do
      json = body_as_json
      expect(json.length).to eq 1
      expect(json[0][:id].to_i).to eq block.id
    end
  end

  describe 'GET #show' do
    let!(:block) { Fabricate(:domain_block) }

    before do
      get :show, params: { id: block.id }
    end

    it_behaves_like 'forbidden for wrong scope', 'write:statuses'
    it_behaves_like 'forbidden for wrong role', ''
    it_behaves_like 'forbidden for wrong role', 'Moderator'

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end

    it 'returns expected domain name' do
      json = body_as_json
      expect(json[:domain]).to eq block.domain
    end
  end

  describe 'PUT #update' do
    let!(:remote_account) { Fabricate(:account, domain: 'example.com') }
    let(:domain_block)    { Fabricate(:domain_block, domain: 'example.com', severity: original_severity) }

    before do
      BlockDomainService.new.call(domain_block)
    end

    let(:subject) do
      post :update, params: { id: domain_block.id, domain: 'example.com', severity: new_severity }
    end

    context 'downgrading a domain suspension to silence' do
      let(:original_severity) { 'suspend' }
      let(:new_severity)      { 'silence' }

      it 'changes the block severity' do
        expect { subject }.to change { domain_block.reload.severity }.from('suspend').to('silence')
      end

      it 'undoes individual suspensions' do
        expect { subject }.to change { remote_account.reload.suspended? }.from(true).to(false)
      end

      it 'performs individual silences' do
        expect { subject }.to change { remote_account.reload.silenced? }.from(false).to(true)
      end
    end

    context 'upgrading a domain silence to suspend' do
      let(:original_severity) { 'silence' }
      let(:new_severity)      { 'suspend' }

      it 'changes the block severity' do
        expect { subject }.to change { domain_block.reload.severity }.from('silence').to('suspend')
      end

      it 'undoes individual silences' do
        expect { subject }.to change { remote_account.reload.silenced? }.from(true).to(false)
      end

      it 'performs individual suspends' do
        expect { subject }.to change { remote_account.reload.suspended? }.from(false).to(true)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:block) { Fabricate(:domain_block) }

    before do
      delete :destroy, params: { id: block.id }
    end

    it_behaves_like 'forbidden for wrong scope', 'write:statuses'
    it_behaves_like 'forbidden for wrong role', ''
    it_behaves_like 'forbidden for wrong role', 'Moderator'

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end

    it 'deletes the block' do
      expect(DomainBlock.find_by(id: block.id)).to be_nil
    end
  end

  describe 'POST #create' do
    let(:existing_block_domain) { 'example.com' }
    let(:params) { { domain: 'foo.bar.com', severity: :silence } }
    let!(:block) { Fabricate(:domain_block, domain: existing_block_domain, severity: :suspend) }

    subject do
      post :create, params: params
    end

    it_behaves_like 'forbidden for wrong scope', 'write:statuses'
    it_behaves_like 'forbidden for wrong role', ''
    it_behaves_like 'forbidden for wrong role', 'Moderator'

    it 'creates a domain block and returns expected domain name', :aggregate_failures do
      subject

      expect(response).to have_http_status(200)
      expect(body_as_json[:domain]).to eq 'foo.bar.com'
      expect(DomainBlock.find_by(domain: 'foo.bar.com')).to_not be_nil
    end

    context 'when a looser domain block already exists on a higher level domain' do
      let(:params) { { domain: 'foo.bar.com', severity: :suspend } }

      before do
        Fabricate(:domain_block, domain: 'bar.com', severity: :silence)
      end

      it 'creates a domain block with the expected domain name and severity', :aggregate_failures do
        subject

        body = body_as_json

        expect(response).to have_http_status(200)
        expect(body).to match a_hash_including(
          {
            domain: 'foo.bar.com',
            severity: 'suspend',
          }
        )

        expect(DomainBlock.find_by(domain: 'foo.bar.com')).to be_present
      end
    end

    context 'when a domain block already exists on the same domain' do
      before do
        Fabricate(:domain_block, domain: 'foo.bar.com', severity: :silence)
      end

      it 'returns existing domain block in error', :aggregate_failures do
        subject

        expect(response).to have_http_status(422)
        expect(body_as_json[:existing_domain_block][:domain]).to eq('foo.bar.com')
      end
    end

    context 'when a stricter domain block already exists on a higher level domain' do
      let(:existing_block_domain) { 'bar.com' }

      it 'returns http unprocessable entity with existing domain block in error', :aggregate_reblogs do
        subject

        expect(response).to have_http_status(422)
        expect(body_as_json[:existing_domain_block][:domain]).to eq existing_block_domain
      end
    end
  end
end
