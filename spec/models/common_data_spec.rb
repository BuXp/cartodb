# coding: UTF-8
require_relative '../spec_helper'

describe CommonData do

  before(:each) do
    Typhoeus::Expectation.clear
    @common_data = CommonData.new
    @common_data.stubs(:config).with('protocol', 'https').returns('https')
    @common_data.stubs(:config).with('username').returns('common-data')
    @common_data.stubs(:config).with('host').returns('example.com')
    @common_data.stubs(:config).with('api_key').returns('wadus')
    @common_data.stubs(:config).with('format', 'shp').returns('shp')
    @common_data.stubs(:config).with('cache_endpoint').returns(nil)
  end

  after(:all) do
    Typhoeus::Expectation.clear
  end

  it 'should return empty datasets response for SQL API error response' do
    stub_api_response(503)

    @common_data.datasets.should eq CommonData::DATASETS_EMPTY
  end

  it 'should return empty datasets for invalid json' do
    stub_api_response(200, INVALID_JSON_RESPONSE)

    @common_data.datasets.should eq CommonData::DATASETS_EMPTY
  end

  it 'should return correct categories and datasets for default stub response' do
    stub_valid_api_response

    @common_data.datasets[:datasets].size.should eq 7
    @common_data.datasets[:categories].size.should eq 3
  end

  it 'should use SQL API V2 for export URLs if cache_endpoint is nil' do
    stub_valid_api_response
    @common_data.stubs(:config).with('cache_endpoint').returns(nil)

    @common_data.datasets[:datasets].first['url'].should match /^https:\/\/common-data\.example\.com\/api\/v2.*&format=shp$/
  end

  it 'should use the configured cache_endpoint host as export URL with the API V1' do
    stub_valid_api_response
    @common_data.stubs(:config).with('cache_endpoint').returns('https://example.com')

    @common_data.datasets[:datasets].first['url'].should match /^https:\/\/example\.com\/api\/v1.*&buster=[0-9]*$/
  end

  def stub_valid_api_response
    stub_api_response(200, VALID_JSON_RESPONSE)
  end

  def stub_api_response(code, body=nil)
    if body
      response = Typhoeus::Response.new(code: code, body: body)
    else
      response = Typhoeus::Response.new(code: code)
    end
    Typhoeus.stub(/common-data/).and_return(response)
  end

  VALID_JSON_RESPONSE = <<-response
{
  "rows": [
    {
      "name": "New York Counties",
      "tabname": "counties_ny",
      "description": "All the New York counties.",
      "source": null,
      "license": null,
      "rows": 62,
      "size": 65536,
      "created_at": 1410178186000,
      "updated_at": 1409229809000,
      "category": "Administrative regions",
      "category_image_url": "https://s3.amazonaws.com/common-data.cartodb.net/administrative.png"
    },
    {
      "name": "World borders",
      "tabname": "world_borders",
      "description": "World countries borders.",
      "source": null,
      "license": null,
      "rows": 246,
      "size": 450560,
      "created_at": 1410171354000,
      "updated_at": 1409210751000,
      "category": "Administrative regions",
      "category_image_url": "https://s3.amazonaws.com/common-data.cartodb.net/administrative.png"
    },
    {
      "name": "Urban Areas",
      "tabname": "table_50m_urban_area",
      "description": "Areas of human habitation.",
      "source": "[Natural Earth Data](http://naturalearthdata.com)",
      "license": null,
      "rows": 2143,
      "size": 1556480,
      "created_at": 1410178510000,
      "updated_at": 1409229825000,
      "category": "Cultural datasets",
      "category_image_url": "https://s3.amazonaws.com/common-data.cartodb.net/cultural_bkg.jpg"
    },
    {
      "name": "Populated places",
      "tabname": "ne_10m_populated_places_simple",
      "description": "Most populated places.",
      "source": "[Natural Earth Data](http://naturalearthdata.com)",
      "license": null,
      "rows": 7313,
      "size": 2588672,
      "created_at": 1410178589000,
      "updated_at": 1409932153000,
      "category": "Cultural datasets",
      "category_image_url": "https://s3.amazonaws.com/common-data.cartodb.net/cultural_bkg.jpg"
    },
    {
      "name": "World rivers",
      "tabname": "table_50m_rivers_lake_centerlines_with_scale_r",
      "description": "Most of the world rivers.",
      "source": "[Natural Earth Data](http://naturalearthdata.com)",
      "license": null,
      "rows": 1611,
      "size": 1163264,
      "created_at": 1410178639000,
      "updated_at": 1409229812000,
      "category": "Physical datasets",
      "category_image_url": "https://s3.amazonaws.com/common-data.cartodb.net/natural_bkg.jpg"
    },
    {
      "name": "NYC Subways",
      "tabname": "nyc_subway_entrance",
      "description": "All the NYC Subways.",
      "source": null,
      "license": null,
      "rows": 1904,
      "size": 417792,
      "created_at": 1410178717000,
      "updated_at": 1409210947000,
      "category": "Cultural datasets",
      "category_image_url": "https://s3.amazonaws.com/common-data.cartodb.net/cultural_bkg.jpg"
    },
    {
      "name": "European countries",
      "tabname": "european_countries",
      "description": "European countries geometries.",
      "source": null,
      "license": null,
      "rows": 46,
      "size": 245760,
      "created_at": 1410178782000,
      "updated_at": 1409229822000,
      "category": "Administrative regions",
      "category_image_url": "https://s3.amazonaws.com/common-data.cartodb.net/administrative.png"
    }
  ],
  "time": 0.009,
  "fields": {
    "name": {
      "type": "string"
    },
    "tabname": {
      "type": "string"
    },
    "description": {
      "type": "string"
    },
    "source": {
      "type": "string"
    },
    "license": {
      "type": "string"
    },
    "rows": {
      "type": "number"
    },
    "size": {
      "type": "number"
    },
    "created_at": {
      "type": "number"
    },
    "updated_at": {
      "type": "number"
    },
    "category": {
      "type": "string"
    },
    "category_image_url": {
      "type": "string"
    }
  },
  "total_rows": 7
}
  response

  INVALID_JSON_RESPONSE = '{'
end
