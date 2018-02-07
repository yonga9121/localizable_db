class Create<%= table_name.singularize.camelize %>Languages < ActiveRecord::Migration<%= migration_version %>

  def change
    create_table :<%= table_name.singularize %>_languages do |t|
<% migration_data.each do | key, value | -%>
<% if key.eql? :object_id -%>
      t.integer :object_id, index: true
<% elsif key.eql? :locale -%>
      t.string :locale, null: false, default: "<%= LocalizableDb::Languages::DEFAULT %>"
<% end -%>
<% end -%>
<% attributes.each do |attribute| -%>
      t.<%= attribute.type %> :<%= attribute.name %>
<% end -%>
    end
  end

end
