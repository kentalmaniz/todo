require 'xcodeproj'

project_path = 'todo.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first

# Check if FirebaseAuth is already added
already_added = target.package_product_dependencies.any? { |dep| dep.product_name == 'FirebaseAuth' }

unless already_added
  # Find the existing firebase-ios-sdk package reference
  pkg_ref = project.root_object.package_references.find { |pr| pr.repositoryURL.include?('firebase-ios-sdk') }
  
  if pkg_ref
    # Create the Product Dependency object
    product_dep = project.new(Xcodeproj::Project::Object::XCSwiftPackageProductDependency)
    product_dep.package = pkg_ref
    product_dep.product_name = 'FirebaseAuth'
    
    # Add to target
    target.package_product_dependencies << product_dep
    
    # Create BuildFile and add to Frameworks phase
    build_file = project.new(Xcodeproj::Project::Object::PBXBuildFile)
    build_file.product_ref = product_dep
    target.frameworks_build_phase.files << build_file
    
    project.save
    puts "Successfully added FirebaseAuth to project."
  else
    puts "Error: Could not find firebase-ios-sdk package in the project."
  end
else
  puts "FirebaseAuth is already in the project."
end
