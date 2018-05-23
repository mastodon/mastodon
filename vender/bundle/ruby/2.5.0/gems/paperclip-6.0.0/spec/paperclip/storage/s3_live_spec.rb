require 'spec_helper'

unless ENV["S3_BUCKET"].blank?
  describe Paperclip::Storage::S3, 'Live S3' do
    context "when assigning an S3 attachment directly to another model" do
      before do
        rebuild_model styles: { thumb: "100x100", square: "32x32#" },
                      storage: :s3,
                      bucket: ENV["S3_BUCKET"],
                      path: ":class/:attachment/:id/:style.:extension",
                      s3_region: ENV["S3_REGION"],
                      s3_credentials: {
                        access_key_id: ENV['AWS_ACCESS_KEY_ID'],
                        secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
                      }

        @file = File.new(fixture_file("5k.png"))
      end

      it "does not raise any error" do
        @attachment = Dummy.new.avatar
        @attachment.assign(@file)
        @attachment.save

        @attachment2 = Dummy.new.avatar
        @attachment2.assign(@file)
        @attachment2.save
      end

      it "allows assignment from another S3 object" do
        @attachment = Dummy.new.avatar
        @attachment.assign(@file)
        @attachment.save

        @attachment2 = Dummy.new.avatar
        @attachment2.assign(@attachment)
        @attachment2.save
      end

      after { @file.close }
    end

    context "Generating an expiring url on a nonexistant attachment" do
      before do
        rebuild_model styles: { thumb: "100x100", square: "32x32#" },
                      storage: :s3,
                      bucket: ENV["S3_BUCKET"],
                      path: ":class/:attachment/:id/:style.:extension",
                      s3_region: ENV["S3_REGION"],
                      s3_credentials: {
                        access_key_id: ENV['AWS_ACCESS_KEY_ID'],
                        secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
                      }

        @dummy = Dummy.new
      end

      it "returns a missing url" do
        expect(@dummy.avatar.expiring_url).to eq @dummy.avatar.url
      end
    end

    context "Using S3 for real, an attachment with S3 storage" do
      before do
        rebuild_model styles: { thumb: "100x100", square: "32x32#" },
                      storage: :s3,
                      bucket: ENV["S3_BUCKET"],
                      path: ":class/:attachment/:id/:style.:extension",
                      s3_region: ENV["S3_REGION"],
                      s3_credentials: {
                        access_key_id: ENV['AWS_ACCESS_KEY_ID'],
                        secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
                      }

        Dummy.delete_all
        @dummy = Dummy.new
      end

      it "is extended by the S3 module" do
        assert Dummy.new.avatar.is_a?(Paperclip::Storage::S3)
      end

      context "when assigned" do
        before do
          @file = File.new(fixture_file('5k.png'), 'rb')
          @dummy.avatar = @file
        end

        after do
          @file.close
          @dummy.destroy
        end

        context "and saved" do
          before do
            @dummy.save
          end

          it "is on S3" do
            assert true
          end
        end
      end
    end

    context "An attachment that uses S3 for storage and has spaces in file name" do
      before do
        rebuild_model styles: { thumb: "100x100", square: "32x32#" },
          storage: :s3,
          bucket: ENV["S3_BUCKET"],
          s3_region: ENV["S3_REGION"],
          url: ":s3_domain_url",
          path: "/:class/:attachment/:id_partition/:style/:filename",
          s3_credentials: {
            access_key_id: ENV['AWS_ACCESS_KEY_ID'],
            secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
          }

        Dummy.delete_all
        @file = File.new(fixture_file('spaced file.png'), 'rb')
        @dummy = Dummy.new
        @dummy.avatar = @file
        @dummy.save
      end

      it "returns a replaced version for path" do
        assert_match /.+\/spaced_file\.png/, @dummy.avatar.path
      end

      it "returns a replaced version for url" do
        assert_match /.+\/spaced_file\.png/, @dummy.avatar.url
      end

      it "is accessible" do
        assert_success_response @dummy.avatar.url
      end

      it "is reprocessable" do
        assert @dummy.avatar.reprocess!
      end

      it "is destroyable" do
        url = @dummy.avatar.url
        @dummy.destroy
        assert_forbidden_response url
      end
    end

    context "An attachment that uses S3 for storage and uses AES256 encryption" do
      before do
        rebuild_model styles: { thumb: "100x100", square: "32x32#" },
                      storage: :s3,
                      bucket: ENV["S3_BUCKET"],
                      path: ":class/:attachment/:id/:style.:extension",
                      s3_region: ENV["S3_REGION"],
                      s3_credentials: {
                        access_key_id: ENV['AWS_ACCESS_KEY_ID'],
                        secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
                      },
                      s3_server_side_encryption: "AES256"
        Dummy.delete_all
        @dummy = Dummy.new
      end

      context "when assigned" do
        before do
          @file = File.new(fixture_file('5k.png'), 'rb')
          @dummy.avatar = @file
        end

        after do
          @file.close
          @dummy.destroy
        end

        context "and saved" do
          before do
            @dummy.save
          end

          it "is encrypted on S3" do
            assert @dummy.avatar.s3_object.server_side_encryption == "AES256"
          end
        end
      end
    end
  end
end
