class AddTemplateFieldToPromotions < ActiveRecord::Migration
  def self.up
    add_column :promotions, :header, :string
    add_column :promotions, :image1, :string
    add_column :promotions, :image2, :string
    add_column :promotions, :thumbnail_image, :string
    add_column :promotions, :body1, :text
    add_column :promotions, :body2, :text
    
    Promotion.all.each do |p|
      p.header = p.name
      p.image1 = p.image
      p.image2 = p.image
      p.thumbnail_image = p.image
      p.body1  = p.description
      p.body2  = "" 
      p.save
    end
  end

  def self.down
    Promotion.all.each do |p|
      p.description = p.body1.to_s + p.body2.to_s
      p.image = p.image1
      p.save
    end
    
    remove_column :promotions, :body2
    remove_column :promotions, :body1
    remove_column :promotions, :thumbnail_image
    remove_column :promotions, :image2
    remove_column :promotions, :image1
    remove_column :promotions, :header
  end
end
