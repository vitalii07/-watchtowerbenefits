module SourcesHelper
  def links_to_sources_for_document(document)
    document.sources.select{|source| source.file.present? }.map do |source|
      original_path = source.file.url(:original)
      path_with_correct_host = original_path.sub('s3.amazonaws.com', Paperclip::Attachment.default_options[:host_name])

      bucket_name = Paperclip::Attachment.default_options[:s3_credentials][:bucket]
      path_without_bucket_prefix = path_with_correct_host.sub("#{bucket_name}/sources", "sources")

      link_to source.file.original_filename, path_without_bucket_prefix
    end.join("<br>")
  end
end
