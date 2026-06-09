# encoding: utf-8

User.find_or_create_by!(email_address: "admin@depot.com") do |u|
  u.name                  = "Admin User"
  u.password              = "password123"
  u.password_confirmation = "password123"
  u.role                  = "admin"
end

User.find_or_create_by!(email_address: "alice@example.com") do |u|
  u.name                  = "Alice Smith"
  u.password              = "password123"
  u.password_confirmation = "password123"
  u.role                  = "user"
end

books       = Category.find_or_create_by!(name: "Books")
fiction     = Category.find_or_create_by!(name: "Fiction",     parent: books)
non_fiction = Category.find_or_create_by!(name: "Non-Fiction", parent: books)

[
  {
    title:       'Programming Ruby 3.3 (5th Edition)',
    description: '<p>The definitive Ruby reference covering Ruby 3.3.</p>',
    price:       33.95,
    permalink:   'programming-ruby-3-edition',
    image:       'ruby5.jpg',
    category:    non_fiction
  },
  {
    title:       'Rails Scales!',
    description: '<p>Practical techniques for Rails performance and growth.</p>',
    price:       30.95,
    permalink:   'rails-scales-performance-guide',
    image:       'cprpo.jpg',
    category:    non_fiction
  },
  {
    title:       'Modern Front-End Development for Rails, Second Edition',
    description: '<p>Hotwire, Stimulus, Turbo, and React for Rails.</p>',
    price:       28.95,
    permalink:   'modern-front-end-rails-second',
    image:       'nrclient2.jpg',
    category:    non_fiction
  }
].each do |attrs|
  product = Product.find_or_create_by!(permalink: attrs[:permalink]) do |p|
    p.title       = attrs[:title]
    p.description = attrs[:description]
    p.price       = attrs[:price]
    p.category    = attrs[:category]
  end

  unless product.images.attached?
    product.images.attach(
      io:       File.open(Rails.root.join('db', 'images', attrs[:image])),
      filename: attrs[:image]
    )
  end
end