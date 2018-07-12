class S3Check < OkComputer::Check
  def check
    bucket = Stock._get_s3_bucket
    if bucket.exists?
      mark_message "bucket=#{bucket.name} exist."
    else
      mark_failure
      mark_message "bucket=#{bucket.name} not found."
    end
  rescue => e
    mark_failure
    mark_message "bucket=#{bucket.name} access error. #{e.message}"
  end
end

OkComputer::Registry.register "s3", S3Check.new
