require "webpacker/configuration"

additional_packages = ""
example_source = "typescript"

# Additional configuration is required for React projects
package_json = Rails.root.join("package.json")
if File.exist?(package_json)
  package = JSON.parse(File.read(package_json))
  package["dependencies"] ||= {}

  if package["dependencies"].keys.include?("react")
    additional_packages = "@types/react @types/react-dom"
    example_source = "react"
  end
end

say "Copying typescript loader to config/webpack/loaders"
copy_file "#{__dir__}/loaders/typescript.js", Rails.root.join("config/webpack/loaders/typescript.js").to_s

say "Adding typescript loader to config/webpack/environment.js"
insert_into_file Rails.root.join("config/webpack/environment.js").to_s,
  "const typescript =  require('./loaders/typescript')\n",
  after: "require('@rails/webpacker')\n"

insert_into_file Rails.root.join("config/webpack/environment.js").to_s,
  "environment.loaders.append('typescript', typescript)\n",
  before: "module.exports"

say "Copying tsconfig.json to the Rails root directory for typescript"
copy_file "#{__dir__}/examples/#{example_source}/tsconfig.json", "tsconfig.json"

say "Updating webpack paths to include .ts file extension"
insert_into_file Webpacker.config.config_path, "    - .ts\n", after: /extensions:\n/

say "Updating webpack paths to include .tsx file extension"
insert_into_file Webpacker.config.config_path, "    - .tsx\n", after: /extensions:\n/

say "Copying the example entry file to #{Webpacker.config.source_entry_path}"
copy_file "#{__dir__}/examples/typescript/hello_typescript.ts",
  "#{Webpacker.config.source_entry_path}/hello_typescript.ts"

say "Installing all typescript dependencies"
run "yarn add typescript ts-loader@3.5.0 #{additional_packages}"

say "Webpacker now supports typescript 🎉", :green
