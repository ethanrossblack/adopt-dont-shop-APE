require 'rails_helper'

RSpec.describe "Admin Applications Show Page" do
  before(:each) do
    @shelter = Shelter.create!(name: "Aurora shelter", city: "Aurora, CO", foster_program: false, rank: 9)
    
    @lucille = @shelter.pets.create!(adoptable: true, age: 1, breed: "Sphynx", name: "Lucille Bald")
    @whiskers = @shelter.pets.create!(adoptable: true, age: 5, breed: "Kitty", name: "Whiskers")

    @paul_app = Application.create!(name: "Paul", street: "1960 Penny Lane", city: "Bedfordshire", state: "UK", zip: "48J77", description: "I still believe love is all you need.  I don't know a better message than that.", status: "Pending")
    @penny_lane_app = Application.create!(name: "Penny Lane", street: "555 McCartney", city: "Hollywood", state: "CA", zip: "90210", description: "Strawberry Fields Forever", status: "Pending")
    
    @paul_pet = ApplicationPet.create!(application_id: @paul_app.id, pet_id: @lucille.id, status: "Pending")
    @penny_lane_pet = ApplicationPet.create!(application_id: @penny_lane_app.id, pet_id: @whiskers.id, status: "Pending")
  end

  describe "As a visitor" do
    context "accepted applications" do
      describe "when I visit an admin application show page" do
        it "for every pet that the application is for, I see a button to approve the applicaiton for that specific pet" do
          visit "/admin/applications/#{@paul_app.id}"

          expect(page).to have_content(@lucille.name)
          expect(page).to have_button("Approve")

          visit "/admin/applications/#{@penny_lane_app.id}"
          
          expect(page).to have_content(@whiskers.name)
          expect(page).to have_button("Approve")
        end

        it "when I click that button it links back to the admin application show page" do
          visit "/admin/applications/#{@paul_app.id}"
          
          click_button "Approve" 
          expect(page).to have_current_path("/admin/applications/#{@paul_app.id}")

          visit "/admin/applications/#{@penny_lane_app.id}"

          click_button "Approve" 
          expect(page).to have_current_path("/admin/applications/#{@penny_lane_app.id}")
        end

        it "and next to the pet that I approved, I do not see a button to approve this pet but do see an indicator that they have been approved" do
          visit "/admin/applications/#{@paul_app.id}"
          
          click_button "Approve" 
          expect(page).to have_content("Approved")
          
          visit "/admin/applications/#{@penny_lane_app.id}"

          click_button "Approve" 
          expect(page).to have_content("Approved")
        end
      end
    end

    context "rejected applications" do
      describe "when I visit an admin application show page" do
        it "for every pet that the application is for, I see a button to reject the applicaiton for that specific pet" do
          visit "/admin/applications/#{@paul_app.id}"
        
          visit "/admin/applications/#{@paul_app.id}"

          expect(page).to have_content(@lucille.name)
          expect(page).to have_button("Reject")

          visit "/admin/applications/#{@penny_lane_app.id}"
          
          expect(page).to have_content(@whiskers.name)
          expect(page).to have_button("Reject")
        end
        
        it "when I click that button it links back to the admin application show page" do
          visit "/admin/applications/#{@paul_app.id}"
          
          click_button "Reject" 
          expect(page).to have_current_path("/admin/applications/#{@paul_app.id}")

          visit "/admin/applications/#{@penny_lane_app.id}"

          click_button "Reject" 
          expect(page).to have_current_path("/admin/applications/#{@penny_lane_app.id}")

        end
 
        it "and next to the pet that I rejected, I do not see a button to reject this pet but do see an indicator that they have been approved" do
          visit "/admin/applications/#{@paul_app.id}"
          
          click_button "Reject" 
          expect(page).to have_content("Rejected")
          
          visit "/admin/applications/#{@penny_lane_app.id}"

          click_button "Reject" 
          expect(page).to have_content("Rejected")

        end
      end
    end

    describe "When there are two applications in the system for the same pet" do
      before(:each) do
        @penny_app_lucille_pet = ApplicationPet.create!(application_id: @penny_lane_app.id, pet_id: @lucille.id, status: "Pending")
      end

      describe "When I visit the admin application show page for one of the applications and I approve or reject the pet for that application" do

        describe "When I visit the other application's admin show page" do

          it "Then I do not see that the pet has been accepted or rejected for that application" do

            visit "/admin/applications/#{@paul_app.id}"

            within("div#app_pet_#{@paul_pet.id}") do
              expect(page).to have_content("Pet Name: Lucille")
              expect(page).to have_button("Approve")
              expect(page).to have_button("Reject")
              
              click_button "Approve"
              
              expect(page).to have_content("Approved")
              expect(page).to_not have_button("Reject")
              expect(page).to_not have_button("Approve")
            end

            visit "/admin/applications/#{@penny_lane_app.id}"

            within("div#app_pet_#{@penny_app_lucille_pet.id}") do
              expect(page).to have_content("Pet Name: Lucille")
              expect(page).to_not have_content("Rejected")
            end
          end

          it "And instead I see buttons to approve or reject the pet for this specific application" do
            visit "/admin/applications/#{@paul_app.id}"

            within("div#app_pet_#{@paul_pet.id}") do
              expect(page).to have_content("Pet Name: Lucille")
              expect(page).to have_button("Approve")
              expect(page).to have_button("Reject")
              
              click_button "Approve"
              
              expect(page).to have_content("Approved")
              expect(page).to_not have_button("Reject")
              expect(page).to_not have_button("Approve")
            end

            visit "/admin/applications/#{@penny_lane_app.id}"

            within("div#app_pet_#{@penny_app_lucille_pet.id}") do
              expect(page).to have_content("Pet Name: Lucille")
              expect(page).to have_button("Approve")
              expect(page).to have_button("Reject")
            end
          end
        end
      end

    end
  end
end