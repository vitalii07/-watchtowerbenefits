module FeatureMacros
  def login(user)
    visit root_path
    click_link 'Log In'
    fill_in 'email', with: user.email
    fill_in 'password', with: user.password
    click_button 'Login'

    expect(page).to have_content 'Logged in!'
    click_link 'Broker Dashboard'
  end

  def find_link_with_text(text)
    find(:xpath, "//a/span[text()='#{text}']")
  end

  def find_button_with_text(text)
    find(:xpath, "//button/span[text()='#{text}']")
  end

  # Upload a file to Dropzone.js
  def drop_in_dropzone(file_path)
    # Generate a fake input selector
    page.execute_script <<-JS
      fakeFileInput = window.$('<input/>').attr(
        {id: 'fakeFileInput', type:'file'}
      ).appendTo('body');
    JS
    # Attach the file to the fake input selector
    attach_file('fakeFileInput', file_path)
    # Add the file to a fileList array
    page.execute_script('var fileList = [fakeFileInput.get(0).files[0]]')
    # Trigger the fake drop event
    page.execute_script <<-JS
      var e = jQuery.Event('drop', { dataTransfer : { files : [fakeFileInput.get(0).files[0]] } });
      $('.wt-dropzone')[0].dropzone.listeners[0].events.drop(e);
    JS
  end
end