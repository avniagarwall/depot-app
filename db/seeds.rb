# encoding: utf-8

LineItem.delete_all
Order.delete_all
Product.delete_all
Category.delete_all
User.delete_all

User.create!(
  name: "Admin User",
  email_address: "admin@depot.com",
  password: "password123",
  password_confirmation: "password123",
  role: "admin"
)

User.create!(
  name: "Alice Smith",
  email_address: "alice@example.com",
  password: "password123",
  password_confirmation: "password123",
  role: "user"
)

product = Product.new(
  title: 'Programming Ruby 3.3 (5th Edition)',
  description: '<p>The definitive Ruby reference covering Ruby 3.3.</p>',
  price: 33.95,
  discount_price: 0.00,
  permalink: 'programming-ruby-3-edition'
)
product.images.attach(
  io: File.open(Rails.root.join('db', 'images', 'ruby5.jpg')),
  filename: 'ruby5.jpg'
)
product.save!

product = Product.new(
  title: 'Rails Scales!',
  description: '<p>Practical techniques for Rails performance and growth.</p>',
  price: 30.95,
  discount_price: 0.00,
  permalink: 'rails-scales-performance-guide'
)
product.images.attach(
  io: File.open(Rails.root.join('db', 'images', 'cprpo.jpg')),
  filename: 'cprpo.jpg'
)
product.save!

product = Product.new(
  title: 'Modern Front-End Development for Rails, Second Edition',
  description: '<p>Hotwire, Stimulus, Turbo, and React for Rails.</p>',
  price: 28.95,
  discount_price: 0.00,
  permalink: 'modern-front-end-rails-second'
)
product.images.attach(
  io: File.open(Rails.root.join('db', 'images', 'nrclient2.jpg')),
  filename: 'nrclient2.jpg'
)
product.save!

books = Category.create!(name: "Books")
Category.create!(name: "Fiction",     parent: books)
Category.create!(name: "Non-Fiction", parent: books)
