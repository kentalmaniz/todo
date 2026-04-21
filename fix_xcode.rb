require 'xcodeproj'
project_path = 'todo.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Access the main target
target = project.targets.first

# Check if AuthViews.swift exists in the main group
main_group = project.main_group['todo']
auth_views_ref = main_group.files.find { |file| file.path == 'AuthViews.swift' }

if auth_views_ref.nil?
  auth_views_ref = main_group.new_file('AuthViews.swift')
end

# Check if AuthViews is in the sources build phase
sources_build_phase = target.source_build_phase
unless sources_build_phase.files_references.include?(auth_views_ref)
  sources_build_phase.add_file_reference(auth_views_ref)
end

# Check if GoogleService-Info.plist exists in the main group
plist_ref = main_group.files.find { |file| file.path == 'GoogleService-Info.plist' }

if plist_ref.nil?
  plist_ref = main_group.new_file('GoogleService-Info.plist')
end

# Check if GoogleService-Info.plist is in the resources build phase
resources_build_phase = target.resources_build_phase
unless resources_build_phase.files_references.include?(plist_ref)
  resources_build_phase.add_file_reference(plist_ref)
end

project.save
puts "Successfully added AuthViews.swift and GoogleService-Info.plist to Xcode project."
