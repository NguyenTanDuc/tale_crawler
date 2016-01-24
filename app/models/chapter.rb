class Chapter < ActiveRecord::Base
  belongs_to :tale

  validate :chapter_uniqueness

  def chapter_uniqueness
    content_text_first_line = content_text.try(:slice, 0..50)
    if chapter.present? && title.present?
      chapter_in_db = Chapter.find_by(chapter: chapter, title: title, tale_id: tale.id)
      if chapter_in_db.blank?
        return true
      else
        errors.add(:chapter, "chapter already crawled")
      end
    else
      chapters_in_db = Chapter.where(tale_id: tale.id)
      flag = true
      chapters_in_db.each do |chapter_in_db|
        if chapter_in_db.content_text.try(:slice, 0..100).include?(content_text_first_line)
          flag = false
          break
        end
      end
      if flag == false
        errors.add(:chapter, "chapter already crawled")
      else
        return true
      end
    end
  end
end
