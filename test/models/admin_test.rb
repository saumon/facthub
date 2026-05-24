require "test_helper"

class AdminTest < ActiveSupport::TestCase
  test "valid admin with email and password" do
    admin = Admin.new(email: "newadmin@example.com", password: "password123")
    assert admin.valid?
  end

  test "invalid without email" do
    admin = Admin.new(email: nil, password: "password123")
    assert_not admin.valid?
    assert admin.errors[:email].any?
  end

  test "encrypted_password is set after saving" do
    admin = Admin.create!(email: "test@example.com", password: "password123")
    assert_not_nil admin.encrypted_password
    assert_not_equal "password123", admin.encrypted_password
  end

  test "devise modules include database_authenticatable" do
    assert Admin.devise_modules.include?(:database_authenticatable)
  end

  test "devise modules include timeoutable" do
    assert Admin.devise_modules.include?(:timeoutable)
  end
end
