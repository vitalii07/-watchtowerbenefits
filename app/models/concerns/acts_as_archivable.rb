module ActsAsArchivable
  def archive!
    update! is_archived: true
  end

  def unarchive!
    update! is_archived: false
  end
end
