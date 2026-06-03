namespace :products do
  desc "Assign first category to all products without a category"
  task port_legacy_products: :environment do
    first_category = Category.first

    if first_category.nil?
      puts "No categories found. Please create at least one category first."
      next
    end

    products = Product.where(category_id: nil)
    count    = products.count

    if count.zero?
      puts "No legacy products found."
      next
    end

    products.update_all(category_id: first_category.id)
    puts "Assigned '#{first_category.name}' to #{count} product(s)."
  end
end