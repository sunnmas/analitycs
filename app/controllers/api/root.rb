require 'grape-swagger'
module API
  class Root < Grape::API
    prefix 'api'
    format :json
    version 'v1', using: :path
    mount API::V1::Users

    add_swagger_documentation(
      api_version: 'v1',
      version: 'v1',
      hide_documentation_path: true,
      hide_format: true,
      format: :json,
      info: {
        title: "XZ API homepage",
        description: "Documentation for usage XZ api",
      }
    )
  end
end
