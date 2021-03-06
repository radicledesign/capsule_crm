class CapsuleCRM::Party
  include CapsuleCRM::Taggable

  include CapsuleCRM::Associations::HasMany

  has_many :histories, class_name: 'CapsuleCRM::History', source: :party
  has_many :tasks, class_name: 'CapsuleCRM::Task', source: :party

  def self.all(options = {})
    attributes = CapsuleCRM::Connection.get('/api/party', options)
    init_collection(attributes['parties'])
  end

  def self.find(id)
    attributes = CapsuleCRM::Connection.get("/api/party/#{id}")
    party_classes[attributes.keys.first].constantize.new(
      attributes[attributes.keys.first]
    )
  end

  private

  def self.init_collection(collection)
    CapsuleCRM::ResultsProxy.new(
      collection.map do |key, value|
        [collection[key]].flatten.map do |attrs|
          party_classes[key].constantize.new(attrs)
        end.flatten
      end.flatten
    )
  end

  def self.party_classes
    {
      person:       'CapsuleCRM::Person',
      organisation: 'CapsuleCRM::Organization'
    }.stringify_keys
  end
end
