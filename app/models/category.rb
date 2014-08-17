class Category
  include Mongoid::Document
  
  field :name,              type: String
  field :active,            type: Boolean, default:true
  field :order_id,          type: Integer
  
  belongs_to :parent, :class_name => "Category"
  has_many :subcategories, :class_name => "Category", :foreign_key=>"parent_id", :dependent => :destroy, :order=> "order_id ASC"
  
  has_many :work_orders

  validates_presence_of :name

  def self.create_by_name(name, order_id)
    Category.where(name: name).first || Category.create(name:name, order_id:order_id)
  end

  def create_child(name, order_id)
    child = self.subcategories.where(:name=>name).first || self.subcategories.create(name:name, order_id:order_id)
  end

  def have_child?
    self.subcategories.present?
  end

  def sub_categories
    self.subcategories.where(:active=>true).order_by("order_id ASC")
  end

  def full_name
    name = []    
    cat = Category.find(self.id)
    while cat.parent.present?
      name << cat.name
      cat = cat.parent
      break if cat.id == self.id
    end
    name << cat.name
    return name.reverse
  end

  def all_sub_categories
    sub_cat = []
    if self.have_child?
      self.sub_categories.each do |st_cat|
        sub_cat << st_cat.id.to_s
        if st_cat.have_child?
          st_cat.sub_categories.each do |nd_cat|
            sub_cat << nd_cat.id.to_s
            if nd_cat.have_child?
              nd_cat.sub_categories.each do |rd_cat|
                sub_cat << rd_cat.id.to_s
              end
            end
          end
        end
      end
    end
    Category.in(id:sub_cat)
  end

  def self.root_categories
    where(:parent_id=>nil, :active=> true).order_by("order_id ASC")
  end

  def self.all_categories
    categories = []
    Category.root_categories.each do |root_cat|
      categories = categories << root_cat
      categories = categories | root_cat.all_sub_categories
    end
    return categories
  end
end
