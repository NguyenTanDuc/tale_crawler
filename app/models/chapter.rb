class Chapter < ActiveRecord::Base
  belongs_to :tale

  validate :chapter_uniqueness

  def chapter_uniqueness
    content_text_first_line = content_text.try(:slice, 0..50)
    if chapter.present? && title.present?
      chapter_in_db = Chapter.find_by(tale_id: tale.id, chapter: chapter, title: title)
      if chapter_in_db.blank?
        return true
      else
        errors.add(:chapter, "chapter already crawled")
      end
    else
      chapters_in_db = Chapter.where(tale_id: tale.id)
      if chapters_in_db.last.try(:content_text).nil?
        return true
      else
        if chapters_in_db.last.content_text.slice(0..100).include?(content_text_first_line)
          errors.add(:chapter, "chapter already crawled")
        end
      end
    end
  end
end
