require 'rails_helper'
require 'spec_helper'

RSpec.describe "LayoutLinks", type: :request do
 
  describe "GET /" do
    it "works! (now write some real specs)" do
      get root_path
      expect(response).to have_http_status(200)
    end
  end
  
  describe "GET /contact_path" do
    it "works! (now write some real specs)" do
      get contact_path
      expect(response).to have_http_status(200)
    end
  end
  
  describe "GET /about_path" do
    it "works! (now write some real specs)" do
      get about_path
      expect(response).to have_http_status(200)
    end
  end

  
  describe "GET /help_path" do
    it "works! (now write some real specs)" do
      get help_path
      expect(response).to have_http_status(200)
    end
  end
  
  describe "GET /signup_path" do
    it "works! (now write some real specs)" do
      get signup_path
      expect(response).to have_http_status(200)
    end
  end
  
 
end
