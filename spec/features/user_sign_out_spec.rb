feature 'User signs out' do
  scenario 'while being signed in' do
    sign_up
    sign_in
    click_button 'Sign out'
    expect(page).to have_content('goodbye!')
    expect(page).not_to have_content('alice@example.com')
  end

end
