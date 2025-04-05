require 'faker'

# Clear existing data
User.destroy_all
Organization.destroy_all
Vendor.destroy_all
Product.destroy_all
Branch.destroy_all
Storage.destroy_all

# Create Organizations
organizations = []
3.times do |i|
  organizations << Organization.create!(
    name: Faker::Company.name,
    tax_id: Faker::Company.ein,
    address: Faker::Address.street_address,
    city: Faker::Address.city,
    state: Faker::Address.state_abbr,
    zip_code: Faker::Address.zip_code,
    country: 'US'
  )
end

# Create Admin User
User.create!(
  email: 'admin@fleetpanda.com',
  phone: Faker::PhoneNumber.cell_phone.gsub(/[^+\d\s-]/, ''),  # Removes invalid characters,
  first_name: 'Admin',
  last_name: 'User',
  password: 'password123',
  password_confirmation: 'password123',
  organization: organizations.first
)

# Create Regular Users
20.times do |i|
  User.create!(
    email: Faker::Internet.email,
    phone: Faker::PhoneNumber.cell_phone.gsub(/[^+\d\s-]/, ''),
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    password: 'password123',
    password_confirmation: 'password123',
    organization: organizations.sample
  )
end

# Create Vendors
15.times do |i|
  Vendor.create!(
    name: Faker::Company.name,
    contact_email: Faker::Internet.email,
    contact_phone: Faker::PhoneNumber.phone_number.gsub(/[^+\d\s-]/, ''),
    address: Faker::Address.street_address,
    city: Faker::Address.city,
    state: Faker::Address.state_abbr,
    zip_code: Faker::Address.zip_code,
    country: 'US',
    organization: organizations.sample,
    preferred: i == 0 # Make first vendor preferred
  )
end

# Create Products
products = %w[Gasoline Diesel Ethanol Biodiesel Propane].map do |name|
  Product.create!(
    name: name,
    description: "#{name} fuel product",
    product_code: "FP-#{rand(1000..9999)}",
    price_per_unit: rand(2.0..5.0).round(2),
    unit: 'gallon'
  )
end

# Create Branches with Storages
organizations.each do |org|
  3.times do |i|
    branch = Branch.create!(
      name: "#{org.name} Branch #{i+1}",
      address: Faker::Address.street_address,
      city: Faker::Address.city,
      state: Faker::Address.state_abbr,
      zip_code: Faker::Address.zip_code,
      country: 'US',
      organization: org
    )

    # Create Storages for each branch
    2.times do |j|
      storage = Storage.create!(
        name: "Storage #{j+1}",
        location: "Location #{j+1}",
        capacity: rand(1000..5000),
        capacity_unit: 'gallon',
        branch: branch
      )

      # Add products to storage
      products.sample(3).each do |product|
        StorageProduct.create!(
          storage: storage,
          product: product,
          current_quantity: rand(100..storage.capacity)
        )
      end
    end

    # Create Trucks for each branch
    5.times do |k|
      Truck.create!(
        license_plate: "#{Faker::Vehicle.license_plate}",
        make: Faker::Vehicle.make,
        model: Faker::Vehicle.model,
        year: rand(2010..2023),
        branch: branch
      )
    end
  end
end

# Create Contracts
organizations.each do |org|
  org.vendors.each do |vendor|
    Contract.create!(
      organization: org,
      vendor: vendor,
      start_date: Date.today - rand(30..60),
      end_date: Date.today + rand(180..365),
      terms: Faker::Lorem.paragraphs(number: 3).join("\n\n"),
      status: ['draft', 'active', 'expired'].sample
    )
  end
end

# Create Delivery Orders
50.times do |i|
  branch = Branch.all.sample
  # status =  DeliveryOrder.statuses.keys.sample.to_s

  # puts "Creating order with status: #{status}"

  order = DeliveryOrder.create!(
    order_number: "ORD-#{Time.current.strftime('%Y%m%d')}-#{SecureRandom.hex(4).upcase}",
    branch: branch,
    vendor: branch.organization.vendors.sample,
    created_by: branch.organization.users.sample,
    delivery_date: Date.today + rand(1..14),
    # status: DeliveryOrder.statuses.keys.sample,
    status: %w[draft submitted in_progress delivered canceled].sample,
    delivery_instructions: Faker::Lorem.sentence
  )

  # Add items to order
  rand(1..5).times do
    product = products.sample
    OrderItem.create!(
      delivery_order: order,
      product: product,
      quantity: rand(100..1000),
      price_per_unit: product.price_per_unit * rand(0.9..1.1).round(2),
      unit: product.unit,
      notes: Faker::Lorem.sentence
    )
  end

  # Add some chat messages
  rand(0..5).times do
    OrderChat.create!(
      delivery_order: order,
      user: order.branch.organization.users.sample,
      message: Faker::Lorem.paragraph
    )
  end

  # Add some documents
  # if rand > 0.7
  #   Document.create!(
  #     documentable: order,
  #     document_type: ['contract', 'invoice', 'receipt'].sample,
  #     original_filename: "document_#{i}.pdf",
  #     content_type: 'application/pdf',
  #     uploaded_by: order.created_by
  #   )
  # end
end

puts "Seeding completed successfully!"
puts "#{Organization.count} organizations created"
puts "#{User.count} users created"
puts "#{Vendor.count} vendors created"
puts "#{Product.count} products created"
puts "#{Branch.count} branches created"
puts "#{Storage.count} storages created"
puts "#{Truck.count} trucks created"
puts "#{Contract.count} contracts created"
puts "#{DeliveryOrder.count} delivery orders created"