class Document < ApplicationRecord
    belongs_to :documentable, polymorphic: true
    belongs_to :uploaded_by, class_name: 'User'
  
    mount_uploader :file, DocumentUploader
  
    validates :file, presence: true
  end