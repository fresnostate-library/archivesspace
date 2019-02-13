require 'spec_helper'

describe 'Agent model' do

  it "allows agents to be created" do

    test_opts = {:names => [
                  {
                    "rules" => "local",
                    "primary_name" => "Magus Magoo Inc",
                    "sort_name" => "Magus Magoo Inc"
                  },
                  {
                    "rules" => "local",
                    "primary_name" => "Magus McGoo PTY LTD",
                    "sort_name" => "McGoo, M"
                  }
                ]}

    agent = AgentCorporateEntity.create_from_json(build(:json_agent_corporate_entity, test_opts))

    expect(AgentCorporateEntity[agent[:id]].name_corporate_entity.length).to eq(2)
  end


  it "allows agents to have a linked contact details" do

    contact_name = 'Business hours contact'

    test_opts = {:agent_contacts => [build(:json_agent_contact, :name => contact_name)]}

    agent = AgentCorporateEntity.create_from_json(build(:json_agent_corporate_entity, test_opts))

    expect(AgentCorporateEntity[agent[:id]].agent_contact.length).to eq(1)
    expect(AgentCorporateEntity[agent[:id]].agent_contact[0][:name]).to eq(contact_name)
  end


  it "requires a source to be set if an authority id is provided" do

    test_opts = {:names => [
                        {
                          "authority_id" => "wooo",
                          "primary_name" => "Magus Magoo Inc",
                          "sort_name" => "Magus Magoo Inc"
                        }
                      ]
                }

    expect {
      agent = AgentCorporateEntity.create_from_json(build(:json_agent_corporate_entity, test_opts))
     }.to raise_error(JSONModel::ValidationException)
  end

  it "returns the existing agent if an name authority id is already in place " do
    json =    build( :json_agent_corporate_entity,
                     :names => [build(:json_name_corporate_entity,
                     'authority_id' => 'thesame',
                     'source' => 'naf'
                                     )])
    json2 =    build( :json_agent_corporate_entity,
                     :names => [build(:json_name_corporate_entity,
                     'authority_id' => 'thesame',
                     'source' => 'naf'
                     )])
    a1 = AgentCorporateEntity.create_from_json(json)
    a2 = AgentCorporateEntity.ensure_exists(json2, nil)

    expect(a1).to eq(a2) # the names should still be the same as the first authority_id names
  end

  describe "slug tests" do
    it "sets primary_name as the slug value when configured to generate by name" do
      AppConfig[:auto_generate_slugs_with_id] = false 

      agent = AgentCorporateEntity.create_from_json(build(:json_agent_corporate_entity))

      agent_name = NameCorporateEntity.where(:agent_corporate_entity_id => agent[:id]).first

      expected_slug = agent_name[:primary_name].gsub(" ", "_")
                                               .gsub(/[&;?$<>#%{}|\\^~\[\]`\/@=:+,!]/, "")



      agent_rec = AgentCorporateEntity.where(:id => agent[:id]).first.update(:is_slug_auto => 1)

      expect(agent_rec[:slug]).to eq(expected_slug)
    end

    it "sets primary_name as the slug value when configured to generate by id" do
      AppConfig[:auto_generate_slugs_with_id] = true

      agent = AgentCorporateEntity.create_from_json(build(:json_agent_corporate_entity))

      agent_name = NameCorporateEntity.where(:agent_corporate_entity_id => agent[:id]).first

      expected_slug = agent_name[:primary_name].gsub(" ", "_")
                                               .gsub(/[&;?$<>#%{}|\\^~\[\]`\/@=:+,!]/, "")



      agent_rec = AgentCorporateEntity.where(:id => agent[:id]).first.update(:is_slug_auto => 1)

      expect(agent_rec[:slug]).to eq(expected_slug)
    end
  end    
end
