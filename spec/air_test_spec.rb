# frozen_string_literal: true

RSpec.describe AirTest do
  it "has a version number" do
    expect(AirTest::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(AirTest).to be_a(Module)
  end
end
