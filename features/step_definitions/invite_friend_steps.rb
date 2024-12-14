When 'I click the invite button for {string}' do |world_name|
  within('tr', text: world_name) do
    click_button 'Invite'
  end
end

Then 'the invite modal should appear' do
  expect(page).to have_css('#invite-modal', visible: true)
end

Then 'the modal should contain the title {string}' do |title|
  within('#invite-modal') do
    expect(page).to have_content(title)
  end
end

Then 'the modal should have an email field' do
  within('#invite-modal') do
    expect(page).to have_field('Enter email to invite')
  end
end

Then 'the modal should have a {string} button' do |button_text|
  within('#invite-modal') do
    expect(page).to have_button(button_text)
  end
end

