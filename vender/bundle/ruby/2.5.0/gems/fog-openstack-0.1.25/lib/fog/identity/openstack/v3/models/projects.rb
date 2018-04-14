require 'fog/openstack/models/collection'
require 'fog/identity/openstack/v3/models/project'

module Fog
  module Identity
    class OpenStack
      class V3
        class Projects < Fog::OpenStack::Collection
          model Fog::Identity::OpenStack::V3::Project

          def all(options = {})
            if service.openstack_cache_ttl > 0
              cached_project, expires = Fog::Identity::OpenStack::V3::Project.cache[{:token   => service.auth_token,
                                                                                     :options => options}]
              return cached_project if cached_project && expires > Time.now
            end

            project_to_cache = load_response(service.list_projects(options), 'projects')
            if service.openstack_cache_ttl > 0
              cache = Fog::Identity::OpenStack::V3::Project.cache
              cache[{:token => service.auth_token, :options => options}] = [project_to_cache,
                                                                            Time.now + service.openstack_cache_ttl]
              Fog::Identity::OpenStack::V3::Project.cache = cache
            end
            project_to_cache
          end

          def create(attributes)
            super(attributes)
          end

          def auth_projects(options = {})
            load(service.auth_projects(options).body['projects'])
          end

          def find_by_id(id, options = []) # options can include :subtree_as_ids, :subtree_as_list, :parents_as_ids, :parents_as_list
            if options.kind_of? Symbol # Deal with a single option being passed on its own
              options = [options]
            end

            if service.openstack_cache_ttl > 0
              cached_project, expires = Fog::Identity::OpenStack::V3::Project.cache[{:token   => service.auth_token,
                                                                                     :id      => id,
                                                                                     :options => options}]
              return cached_project if cached_project && expires > Time.now
            end
            project_hash = service.get_project(id, options).body['project']
            top_project = project_from_hash(project_hash, service)
            if options.include? :subtree_as_list
              top_project.subtree.map! { |proj_hash| project_from_hash(proj_hash['project'], service) }
            end
            if options.include? :parents_as_list
              top_project.parents.map! { |proj_hash| project_from_hash(proj_hash['project'], service) }
            end

            if service.openstack_cache_ttl > 0
              cache = Fog::Identity::OpenStack::V3::Project.cache
              cache[{:token => service.auth_token, :id => id, :options => options}] = [
                top_project, Time.now + service.openstack_cache_ttl
              ]
              Fog::Identity::OpenStack::V3::Project.cache = cache
            end
            top_project
          end

          private

          def project_from_hash(project_hash, service)
            Fog::Identity::OpenStack::V3::Project.new(project_hash.merge(:service => service))
          end
        end
      end
    end
  end
end
