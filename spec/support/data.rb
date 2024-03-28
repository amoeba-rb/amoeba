# frozen_string_literal: true

u1 = User.create(name: 'Robert Johnson', email: 'bob@crossroads.com')
u2 = User.create(name: 'Miles Davis', email: 'miles@kindofblue.com')

a1 = Author.create(full_name: 'Kermit The Vonnegut', nickname: 'kvsoitgoes')
a2 = Author.create(full_name: 'Arthur Sees Clarck', nickname: 'strangewater')

t = Topic.create(title: 'Ponies', description: 'Lets talk about my ponies.')

# First Post {{{
p1 = t.posts.create(owner: u1, author: a1, title: 'My little pony',
                    contents: 'Lorum ipsum dolor rainbow bright. I like dogs, dogs are awesome.')
f1 = p1.create_post_config(is_visible: true, is_open: false, password: 'abcdefg123')
a1 = p1.create_account(title: 'Foo')
h1 = p1.account.create_history(some_stuff: 'Bar')
c1 = p1.comments.create(contents: 'I love it!', nerf: 'ratatat')
[5, 5, 4, 3, 5, 5].each { |stars| c1.ratings.create(num_stars: stars) }

c2 = p1.comments.create(contents: 'I hate it!', nerf: 'whapaow')
[3, 1, 4, 1, 1, 2].each { |stars| c2.ratings.create(num_stars: stars) }

c3 = p1.comments.create(contents: 'kthxbbq!!11!!!1!eleven!!', nerf: 'bonk')
[0, 0, 1, 2, 1, 0].each { |stars| c3.ratings.create(num_stars: stars) }

%w[funny wtf cats].each { |value| p1.tags << Tag.create(value: value) }

['My Sidebar', 'Photo Gallery', 'Share & Like'].each do |value|
  p1.widgets << Widget.create(value: value)
end

['This is important', "You've been warned", "Don't forget"].each do |value|
  p1.notes << Note.create(value: value)
end

p1.save

c1 = Category.create(title: 'Umbrellas', description: 'Clown fart')
c2 = Category.create(title: 'Widgets', description: 'Humpty dumpty')
c3 = Category.create(title: 'Wombats', description: 'Slushy mushy')

s1 = Supercat.create(post: p1, category: c1, ramblings: 'zomg', other_ramblings: 'nerp')
s2 = Supercat.create(post: p1, category: c2, ramblings: 'why', other_ramblings: 'narp')
s3 = Supercat.create(post: p1, category: c3, ramblings: 'ohnoes', other_ramblings: 'blap')

s1.superkittens.create(value: 'Fluffy')
s1.superkittens.create(value: 'Buffy')
s1.superkittens.create(value: 'Fuzzy')

s2.superkittens.create(value: 'Hairball')
s2.superkittens.create(value: 'Crosseye')
s2.superkittens.create(value: 'Spot')

s3.superkittens.create(value: 'Dopey')
s3.superkittens.create(value: 'Sneezy')
s3.superkittens.create(value: 'Sleepy')

p1.custom_things.create([{ value: [1, 2] }, { value: [] }, { value: [78] }])
# }}}

# Product {{{
product1 = Product.create(title: 'Sticky Notes 5-Pak', price: 5.99, weight: 0.56)
shirt1 = Shirt.create(title: 'Fancy Shirt', price: 48.95, sleeve: 32, collar: 15.5)
necklace1 = Necklace.create(title: 'Pearl Necklace', price: 2995.99, length: 18, metal: '14k')

img1 = product1.images.create(filename: 'sticky.jpg')
img2 = product1.images.create(filename: 'notes.jpg')

img1 = shirt1.images.create(filename: '02948u31.jpg')
img2 = shirt1.images.create(filename: 'zsif8327.jpg')

img1 = necklace1.images.create(filename: 'ae02x9f1.jpg')
img2 = necklace1.images.create(filename: 'cba9f912.jpg')

office = Section.create(name: 'Office', num_employees: 2, total_sales: '1234.56')
supplies = Section.create(name: 'Supplies', num_employees: 1, total_sales: '543.21')
mens = Section.create(name: 'Mens', num_employees: 3, total_sales: '11982.63')
apparel = Section.create(name: 'Apparel', num_employees: 5, total_sales: '1315.20')
accessories = Section.create(name: 'Accessories', num_employees: 1, total_sales: '8992.34')
jewelry = Section.create(name: 'Jewelry', num_employees: 3, total_sales: '25481.77')

product1.sections << office
product1.sections << supplies
product1.save

shirt1.sections << mens
shirt1.sections << apparel
shirt1.save

necklace1.sections << jewelry
necklace1.sections << accessories
necklace1.save

company = Company.create(name: 'ABC Industries')
employee = company.employees.create(name: 'Joe', ssn: '1111111111', salary: 10_000.0)
employee_address = employee.addresses.create(street: '123 My Street', unit: '103', city: 'Hollywood',
                                             state: 'CA', zip: '90210')
employee_address_2 = employee.addresses.create(street: '124 My Street', unit: '103', city: 'Follywood',
                                               state: 'CA', zip: '90210')
employee_photo = employee.photos.create(name: 'Portrait', size: 12_345)
customer = company.customers.create(email: 'my@email.address', password: 'password')
customer_address = customer.addresses.create(street: '321 My Street', unit: '301', city: 'Bollywood',
                                             state: 'IN', zip: '11111')
customer_address_2 = customer.addresses.create(street: '321 My Drive', unit: '311', city: 'Mollywood',
                                               state: 'IN', zip: '21111')
customer_photo = customer.photos.create(name: 'Mug Shot', size: 54_321)

# }}}
