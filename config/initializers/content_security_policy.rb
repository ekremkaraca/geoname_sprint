Rails.application.config.content_security_policy do |policy|
  policy.default_src :self
  policy.script_src :self
  policy.style_src :self, :unsafe_inline
  policy.img_src :self, :https, :data
  policy.font_src :self, :data
  policy.connect_src :self
  policy.object_src :none
  policy.base_uri :self
end

Rails.application.config.content_security_policy_report_only = true
