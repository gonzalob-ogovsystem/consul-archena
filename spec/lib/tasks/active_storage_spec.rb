require "rails_helper"

describe "active storage tasks" do
  describe "migrate_from_paperclip" do
    let(:run_rake_task) do
      Rake::Task["active_storage:migrate_from_paperclip"].reenable
      Rake.application.invoke_task("active_storage:migrate_from_paperclip")
    end

    let(:storage_root) { ActiveStorage::Blob.service.root }
    before { FileUtils.rm_rf storage_root }

    it "migrates records and attachments" do
      document = create(:document,
                        attachment: nil,
                        paperclip_attachment: File.new("spec/fixtures/files/clippy.pdf"))

      expect(ActiveStorage::Attachment.count).to eq 0
      expect(ActiveStorage::Blob.count).to eq 0
      expect(test_storage_file_paths.count).to eq 0

      run_rake_task
      document.reload

      expect(ActiveStorage::Attachment.count).to eq 1
      expect(ActiveStorage::Blob.count).to eq 1
      expect(document.storage_attachment.filename).to eq "clippy.pdf"
      expect(test_storage_file_paths.count).to eq 1
      expect(storage_file_path(document)).to eq test_storage_file_paths.first
    end

    def test_storage_file_paths
      Dir.glob("#{storage_root}/**/*").select { |file_or_folder| File.file?(file_or_folder) }
    end

    def storage_file_path(record)
      ActiveStorage::Blob.service.path_for(record.storage_attachment.blob.key)
    end
  end
end
