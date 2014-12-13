Rails.application.config.middleware.use OmniAuth::Builder do
  provider :qiita, 'e43f70a43b73e50f39af688d5390c5aa995f85d4', '4475c04a886cddd9e5434802a524f080dab0350c',
  :scope => 'read_qiita read_qiita_team write_qiita write_qiita_team'
end