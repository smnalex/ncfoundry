require "cfoundry/v2/model"
require "cfoundry/v2/helper"

module CFoundry::V2
  class Space < Model
    extend Helper

    attribute :name, :string
    to_one    :organization
    to_many   :developers, :as => :user
    to_many   :managers, :as => :user
    to_many   :auditors, :as => :user
    to_many   :apps
    to_many   :domains
    to_many   :service_instances
    to_many   :services
    to_many   :routes

    to_many_support   :developers
    to_many_support   :managers
    to_many_support   :auditors
    to_many_support   :apps
    to_many_support   :domains
    to_many_support   :service_instances
    to_many_support   :services

    scoped_to_organization

    queryable_by :name, :organization_guid, :developer_guid, :app_guid
  end
end
