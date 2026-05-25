namespace :products do
  desc "Assign first category to all products with no category"
  task port_legacy_products: :environment do
    first_category = Category.order(:id).first

    if first_category.nil?
      puts "No categories found. Create one first."
      exit
    end

    products = Product.where(category_id: nil, sub_category_id: nil)

    if products.empty?
      puts "No legacy products found."
    else
      count = products.update_all(category_id: first_category.id)
      first_category.recalculate_products_count!
      puts "Assigned '#{first_category.name}' to #{count} product(s)."
    end
  end
end
