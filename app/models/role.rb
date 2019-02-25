# == Schema Information
#
# Table name: roles
#
#  id         :integer          not null, primary key
#  deleted_at :datetime
#  desc       :string(255)
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_roles_on_deleted_at  (deleted_at)
#

class Role < ActiveRecord::Base
  acts_as_paranoid
  has_and_belongs_to_many :resources, join_table: 'role_resources'
  has_and_belongs_to_many :users, join_table: 'user_roles'
  has_many :user_roles
  validates_presence_of :name
  ROLES = {super_admin: '超级管理员', group_admin: '后勤管理员', normal_admin: '后勤', regional_manager: '大区总监',
           project_manager: '项目经理', project_user: '项目专员', agency: '代理商'}





  class << self
    def load!
      ROLES.each do |key, value|
        Role.create name: value, desc: key unless Role.find_by(name: key).present?
      end
    end

    def write_config file_path
      hash_roles = {}
      self.all.each do |role|
        hash_target = {}
        role.resources.group_by{|r| r.target}.each do |target, resources|
          hash_resources = {}
          resources.each do |resource|
            hash_resources[resource.action] = resource.name
          end
          hash_target[target] = hash_resources
        end
        hash_roles[role.desc] = hash_target
      end
      File.open file_path, 'a+' do |file|
        file.puts hash_roles.to_yaml
      end
    end

  end



end
