# encoding: UTF-8

require 'redmine'

###################
# 1/ Initialisation
Rails.logger.info 'o=>'
Rails.logger.info 'o=>Starting Redmine Smile Project Enumerations Custom Field Format plugin for Redmine'
Rails.logger.info "o=>Application user : #{ENV['USER']}"


plugin_name = :redmine_smile_project_enumerations_custom_field_format
# plugin_root = File.dirname(__FILE__)

# lib/not_reloaded
require_relative 'lib/smile_tools'

Redmine::Plugin.register plugin_name do
  ########################
  # 2/ Plugin informations
  name 'Redmine - Smile - Project Enumerations Custom Field Format'
  author 'Jérôme BATAILLE, Stéphane PARUNAKIAN'
  author_url "mailto:Jerome BATAILLE <redmine-support@smile.fr>?subject=#{plugin_name}"
  description 'Adds a new Custom Field Format that stores its values in project enumerations'
  url "https://github.com/Smile-SA/#{plugin_name}"
  version '1.3.15'
  requires_redmine :version_or_higher => '3.4'


  #######################
  # 2.1/ Plugin home page
  settings :default => HashWithIndifferentAccess.new(
    ),
    :partial => "settings/#{plugin_name}"

  project_module :issue_tracking do
    permission :manage_project_enumerations, {
      :projects => :settings,
      :project_project_list_values => [:index, :new, :create, :edit, :update, :update_each, :destroy],
      :project_project_enumerations => [:index, :new, :create, :edit, :update, :update_each, :destroy]
    },
    :require => :member
  end
end # Redmine::Plugin.register ...


#################################
# 3/ Plugin internal informations
# To keep after plugin register
this_plugin = Redmine::Plugin::find(plugin_name.to_s)
plugin_version = '?.?'
# Root relative to application root
plugin_rel_root = '.'
plugin_id = 0
if this_plugin
  plugin_version  = this_plugin.version
  plugin_id       = this_plugin.__id__
  plugin_rel_root = 'plugins/' + this_plugin.id.to_s
end


###############
# 4/ Dispatcher
#Executed each time the classes are reloaded
rails_dispatcher = Rails.configuration


def prepend_in(dest, mixin_module)
  return if dest.include? mixin_module

  # Rails.logger.info "o=>#{dest}.prepend #{mixin_module}"
  dest.send(:prepend, mixin_module)
end

###############
# 5/ to_prepare
# Executed after Rails initialization
# rails_dispatcher.to_prepare do
  Rails.logger.info "o=>"
  Rails.logger.info "o=>\\__ #{plugin_name} V#{plugin_version}"

  SmileTools.reset_override_count(plugin_name)

  SmileTools.trace_override "                                plugin  #{plugin_name} V#{plugin_version}",
    false,
    plugin_name


  #########################################
  # 5.1/ List of files required dynamically
  # Manage dependencies
  # To put here if we want recent source files reloaded
  # Outside of to_prepare, file changed => reloaded,
  # but with primary loaded source code
  required = [
    # lib/
    'lib/redmine/field_format/project_enumeration_format',
    'lib/redmine/field_format/project_list_value_format',
    "lib/#{plugin_name}/hooks",

    # lib/controllers
    'lib/smile/controllers/projects_controller_override',

    # lib/helpers
    'lib/smile/helpers/projects_helper_override',

    # lib/models
    'lib/smile/models/project_override',
    'lib/smile/models/custom_field_override',
  ]

    # **** 6.1/ Controllers ****
    Rails.logger.info "o=>----- CONTROLLERS"
    prepend_in(ProjectsController, Smile::Controllers::ProjectsControllerOverride)
  
    #***********************
    # **** 6.2/ Helpers ****
    Rails.logger.info "o=>----- HELPERS"
    prepend_in(ProjectsHelper, Smile::Helpers::ProjectsHelperOverride)
  
    #**********************
    # **** 6.3/ Models ****
    Rails.logger.info "o=>----- MODELS"
    prepend_in(Project, Smile::Models::ProjectOverride)
    prepend_in(CustomField, Smile::Models::CustomFieldOverride)


  ##########################
  # 5.3/ Static requirements
  Rails.logger.debug "o=>require"
  required.each{ |p|
    # Never reloaded
    Rails.logger.debug "o=>  #{plugin_rel_root + p}"
    require_relative p
  }
  # END -- Manage dependencies


  ##############
  # 6/ Overrides

  #***************************
  # **** 6.1/ Controllers ****
  Rails.logger.info "o=>----- CONTROLLERS"
  prepend_in(ProjectsController, Smile::Controllers::ProjectsControllerOverride)

  #***********************
  # **** 6.2/ Helpers ****
  Rails.logger.info "o=>----- HELPERS"
  prepend_in(ProjectsHelper, Smile::Helpers::ProjectsHelperOverride)

  #**********************
  # **** 6.3/ Models ****
  Rails.logger.info "o=>----- MODELS"
  prepend_in(Project, Smile::Models::ProjectOverride)
  prepend_in(CustomField, Smile::Models::CustomFieldOverride)


  # keep traces if classes / modules are reloaded
  SmileTools.enable_traces(false, plugin_name)

  Rails.logger.info 'o=>/--'
# end
