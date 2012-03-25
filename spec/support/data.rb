u1 = User.create(:name => "Robert Johnson", :email => "bob@crossroads.com")
u2 = User.create(:name => "Miles Davis", :email => "miles@kindofblue.com")

a1 = Author.create(:full_name => "Kermit The Vonnegut", :nickname => "kvsoitgoes")
a2 = Author.create(:full_name => "Arthur Sees Clarck", :nickname => "strangewater")

t = Topic.create(:title => "Ponies", :description => "Lets talk about my ponies.")

# First Post {{{
p1 = t.posts.create(:owner => u1, :author => a1, :title => "My little pony", :contents => "Lorum ipsum dolor rainbow bright. I like dogs, dogs are awesome.")
f1 = p1.create_post_config(:is_visible => true, :is_open => false, :password => 'abcdefg123')
a1 = p1.create_account(:title => "Foo")
h1 = p1.account.create_history(:some_stuff => "Bar")
c1 = p1.comments.create(:contents => "I love it!", :nerf => "ratatat")
c1.ratings.create(:num_stars => 5)
c1.ratings.create(:num_stars => 5)
c1.ratings.create(:num_stars => 4)
c1.ratings.create(:num_stars => 3)
c1.ratings.create(:num_stars => 5)
c1.ratings.create(:num_stars => 5)

c2 = p1.comments.create(:contents => "I hate it!", :nerf => "whapaow")
c2.ratings.create(:num_stars => 3)
c2.ratings.create(:num_stars => 1)
c2.ratings.create(:num_stars => 4)
c2.ratings.create(:num_stars => 1)
c2.ratings.create(:num_stars => 1)
c2.ratings.create(:num_stars => 2)

c3 = p1.comments.create(:contents => "kthxbbq!!11!!!1!eleven!!", :nerf => "bonk")
c3.ratings.create(:num_stars => 0)
c3.ratings.create(:num_stars => 0)
c3.ratings.create(:num_stars => 1)
c3.ratings.create(:num_stars => 2)
c3.ratings.create(:num_stars => 1)
c3.ratings.create(:num_stars => 0)

t1 = Tag.create(:value => "funny")
t2 = Tag.create(:value => "wtf")
t3 = Tag.create(:value => "cats")

p1.tags << t1
p1.tags << t2
p1.tags << t3
p1.save

w1 = Widget.create(:value => "My Sidebar")
w2 = Widget.create(:value => "Photo Gallery")
w3 = Widget.create(:value => "Share & Like")

p1.widgets << w1
p1.widgets << w2
p1.widgets << w3
p1.save

n1 = Note.create(:value => "This is important")
n2 = Note.create(:value => "You've been warned")
n3 = Note.create(:value => "Don't forget")

p1.notes << n1
p1.notes << n2
p1.notes << n3
p1.save

c1 = Category.create(:title => "Umbrellas", :description => "Clown fart")
c2 = Category.create(:title => "Widgets", :description => "Humpty dumpty")
c3 = Category.create(:title => "Wombats", :description => "Slushy mushy")

s1 = Supercat.create(:post => p1, :category => c1, :ramblings => "zomg", :other_ramblings => "nerp")
s2 = Supercat.create(:post => p1, :category => c2, :ramblings => "why", :other_ramblings => "narp")
s3 = Supercat.create(:post => p1, :category => c3, :ramblings => "ohnoes", :other_ramblings => "blap")

s1.superkittens.create(:value => "Fluffy")
s1.superkittens.create(:value => "Buffy")
s1.superkittens.create(:value => "Fuzzy")

s2.superkittens.create(:value => "Hairball")
s2.superkittens.create(:value => "Crosseye")
s2.superkittens.create(:value => "Spot")

s3.superkittens.create(:value => "Dopey")
s3.superkittens.create(:value => "Sneezy")
s3.superkittens.create(:value => "Sleepy")
# }}}

# Product {{{
product1 = Product.create(:title => "Sticky Notes 5-Pak", :price => 5.99, :weight => 0.56)
shirt1 = Shirt.create(:title => "Fancy Shirt", :price => 48.95, :sleeve => 32, :collar => 15.5)
necklace1 = Necklace.create(:title => "Pearl Necklace", :price => 2995.99, :length => 18, :metal => "14k")

img1 = product1.images.create(:filename => "sticky.jpg")
img2 = product1.images.create(:filename => "notes.jpg")

img1 = shirt1.images.create(:filename => "02948u31.jpg")
img2 = shirt1.images.create(:filename => "zsif8327.jpg")

img1 = necklace1.images.create(:filename => "ae02x9f1.jpg")
img2 = necklace1.images.create(:filename => "cba9f912.jpg")

office = Section.create(:name => "Office", :num_employees => 2, :total_sales => "1234.56")
supplies = Section.create(:name => "Supplies", :num_employees => 1, :total_sales => "543.21")
mens = Section.create(:name => "Mens", :num_employees => 3, :total_sales => "11982.63")
apparel = Section.create(:name => "Apparel", :num_employees => 5, :total_sales => "1315.20")
accessories = Section.create(:name => "Accessories", :num_employees => 1, :total_sales => "8992.34")
jewelry = Section.create(:name => "Jewelry", :num_employees => 3, :total_sales => "25481.77")

product1.sections << office
product1.sections << supplies
product1.save

shirt1.sections << mens
shirt1.sections << apparel
shirt1.save

necklace1.sections << jewelry
necklace1.sections << accessories
necklace1.save
# }}}
